local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local Trove = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
local Net = require(ReplicatedStorage.packages.Net)
local module = require("./PassiveHandler")
local InputController = require(ReplicatedStorage.client.legacyControllers.InputController)
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local assets = require(ReplicatedStorage.shared.utils.assets)
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local mutations = require(ReplicatedStorage.shared.modules.fishing.mutations)
local fx = require(ReplicatedStorage.shared.modules.fx)
local remoteEvent = Net:RemoteEvent("SelectiveFish/ChooseFish")
local name = nil
local v = nil
local v2 = nil
local v3 = ""
local inputBeganConnection = nil
local SelectiveFishClient = {
	NoMock = true,
	new = function(p, config, env)
		task.spawn(ContentProvider.PreloadAsync, ContentProvider, { script.Animation, script.Sound, script.Show })
		local self = setmetatable({}, {
			__index = p
		})
		self.config = config
		self.trove = Trove.new()
		self.reelTrove = self.trove:Extend()
		self.env = env
		self.uid = game.HttpService:GenerateGUID(false)

		local function fitSphereToCamera(p2, p3, p4)
			local v4 = math.rad(p3) * 0.5

			if p4 < 1 then
				v4 = math.atan(p4 * math.tan(v4))
			end

			return p2 / math.sin(v4)
		end

		local function getCubeoidDiameter(data)
			return (math.sqrt(data.x ^ 2 + data.y ^ 2 + data.z ^ 2))
		end

		local function fitBoundingBoxToCamera(data, p2, p3)
			local v4 = math.sqrt(data.x ^ 2 + data.y ^ 2 + data.z ^ 2) / 2
			local v5 = math.rad(p2) * 0.5

			if p3 < 1 then
				v5 = math.atan(p3 * math.tan(v5))
			end

			return v4 / math.sin(v5)
		end

		self.trove:Connect(Net:RemoteEvent("SelectiveFish/SendFishSelection", -1).OnClientEvent, function(list, p2)
			local character = localPlayer.Character

			if not character then
				return
			end

			local track = character:FindFirstChild("Humanoid"):FindFirstChildOfClass("Animator"):LoadAnimation(script.Animation)
			track.Priority = Enum.AnimationPriority.Action4
			track:Play(0.25)
			local clone = script.FishSelection:Clone()
			local list2 = clone.List
			local timer = clone.Timer
			local position = timer.Position
			local header = clone.Header
			local position2 = header.Position
			local bar = timer.Bar
			timer.Position += UDim2.fromScale(0, 1)
			header.Position += UDim2.fromScale(0, -1)
			bar.Size = UDim2.fromScale(1, 1)
			bar.BackgroundColor3 = Color3.fromRGB(155, 255, 49)
			list2.Position = UDim2.fromScale(0.5, 1.5)
			clone.Parent = playerGui
			name = nil
			v = nil
			v2 = list
			local connections = {}

			for k, v4 in list do
				local v5 = {
					name = v4.Name,
					sub = {
						Weight = v4.Weight,
						Mutation = v4.Mutation,
						Shiny = v4.Shiny,
						Sparkling = v4.Sparkling
					}
				}
				local name2 = v4.Name
				local clone2 = script.Fish:Clone()
				local button = clone2.Button
				clone2.Name = k
				button.Frame._Name.Text = FischUtils.ItemDisplay(v5, {
					rich = true,
					rarity_color = true,
					hide_attributes = true
				})
				button.Frame.Attributes.Text = FischUtils.ItemDisplay(v5, {
					rich = true,
					rarity_color = true,
					hide_main = true
				})
				button.Frame.Attributes.Visible = button.Frame.Attributes.Text ~= ""
				button.GamepadIcon:SetAttribute(
					"ButtonKeyCode",
					k == 1 and "ButtonL1" or k == 2 and "ButtonR1" or false
				)
				local v6 = fish[v4.Name] ~= nil
				local clone3 = assets.getAsync(
					v6 and "fish" or "item",
					(`{v6 and v4.Shiny and "Shiny_" or ""}{v4.Name}`)
				):Clone()

				if clone3 and clone3:IsA("Folder") then
					clone3 = clone3:FindFirstChild(v4.Name)
				end

				if v6 and v4.Mutation ~= nil then
					mutations:MutateModel(clone3:FindFirstChildOfClass("Model") or clone3, v4.Mutation, v4)
				end

				clone3.Name = "viewmodel"
				clone3.Parent = button.vp
				local absoluteSize = button.vp.AbsoluteSize
				local camera = Instance.new("Camera", button.vp)
				camera.FieldOfView = 20
				button.vp.CurrentCamera = camera
				local v7 = absoluteSize.X / absoluteSize.Y
				local cFrame, size

				if clone3:FindFirstChild("Hitbox") then
					cFrame = clone3.Hitbox.CFrame
					size = clone3.Hitbox.Size
				else
					cFrame, size = clone3:GetBoundingBox()
				end

				local v8 = math.sqrt(size.x ^ 2 + size.y ^ 2 + size.z ^ 2) / 2
				local v9 = 0.1308996938995747

				if v7 < 1 then
					v9 = math.atan(v7 * math.tan(v9))
				end

				local v10 = v8 / math.sin(v9)
				camera.CFrame = CFrame.new(cFrame.p) * CFrame.Angles(0, 4.1887902047863905, 0) * CFrame.Angles(
					0.39269908169872414,
					0,
					0
				) * CFrame.new(0, 0, v10)
				clone2.Parent = list2
				local v12 = k
				connections[#connections + 1] = button.Activated:Once(function()
					name = name2
					v = v12
				end)
			end

			if v3 == "Gamepad" then
				inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
					if name then
						return
					end

					if input.KeyCode == Enum.KeyCode.ButtonL1 then
						v = 1
						name = list[v].Name
					elseif input.KeyCode == Enum.KeyCode.ButtonR1 then
						v = 2
						name = list[v].Name
					end
				end)
			end

			GeneralUtils.fastTween(list2, TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0.5, 0.5)
			})
			script.Show:Play()
			local lastTime = tick()
			local fastTween = GeneralUtils.fastTween(bar, TweenInfo.new(config.SelectTime, Enum.EasingStyle.Linear), {
				Size = UDim2.fromScale(0, 1),
				BackgroundColor3 = Color3.fromRGB(255, 47, 47)
			})
			local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)

			if playerGui.hud.Enabled then
				playerGui.hud.Enabled = false
			end

			if playerGui.backpack.Enabled then
				playerGui.backpack.Enabled = false
			end

			GeneralUtils.fastTween(timer, tweenInfo, {
				Position = position
			})
			GeneralUtils.fastTween(header, tweenInfo, {
				Position = position2
			})

			repeat
				task.wait()
			until tick() - lastTime >= config.SelectTime or name

			if name then
				for _, frame in list2:GetChildren() do
					if not (frame:IsA("Frame") and tonumber(frame.Name) == v) then
						continue
					end

					local button = frame:FindFirstChild("Button")

					if not button then
						continue
					end

					fx:PlaySound(script.Sound, playerGui, true)
					button.Size += UDim2.fromScale(0.35, 0.35)
					button.Rotation = 15
					GeneralUtils.fastTween(
						button,
						TweenInfo.new(0.75, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
						{
							Size = UDim2.fromScale(1, 1),
							Rotation = 0
						}
					)
				end
			end

			track:Stop(0.1)
			fastTween:Cancel()

			if not name then
				v = math.random(1, #list)
				name = list[v].Name
			end

			if inputBeganConnection and inputBeganConnection.Connected then
				inputBeganConnection:Disconnect()
				inputBeganConnection = nil
			end

			for _, connection in connections do
				if connection.Connected then
					connection:Disconnect()
				end
			end

			GeneralUtils.fastTween(timer, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Position = position + UDim2.fromScale(0, 1)
			})
			GeneralUtils.fastTween(header, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Position = position2 + UDim2.fromScale(0, -1)
			})

			for _, frame in list2:GetChildren() do
				if not frame:IsA("Frame") then
					continue
				end

				local button = frame:FindFirstChild("Button")

				if frame.Name ~= name then
					GeneralUtils.fastTween(
						button,
						TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
						{
							Position = UDim2.fromScale(0.5, 10)
						}
					)
				end
			end

			task.spawn(function()
				task.wait(0.35)
				GeneralUtils.fastTween(list2, TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
					Position = UDim2.fromScale(0.5, 1.5)
				}).Completed:Once(function()
					clone:Destroy()
				end)
			end)
			remoteEvent:FireServer(v, p2)
			name = nil
			v = nil
			v2 = nil
		end)
		self.trove:Add(InputController.Observe(function(p2)
			v3 = p2

			if inputBeganConnection and inputBeganConnection.Connected then
				inputBeganConnection:Disconnect()
				inputBeganConnection = nil
			end

			if p2 == "Gamepad" then
			end
		end))
		return self
	end
}
setmetatable(SelectiveFishClient, module)
return SelectiveFishClient