local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local Trove = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
local Net = require(ReplicatedStorage.packages.Net)
local Signal = require(ReplicatedStorage.packages.Signal)
local module = require("./PassiveHandler")
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local fx = require(ReplicatedStorage.shared.modules.fx)
local rods = require(ReplicatedStorage.shared.modules.library.rods)
local v = {}
local now = 0
local v2 = 0
local RandomPassivesClient = {
	NoMock = true,
	new = function(p, config, env)
		local object = setmetatable({}, {
			__index = p
		})
		object.config = config
		object.trove = Trove.new()
		object.reelTrove = object.trove:Extend()
		object.env = env
		object.uid = game.HttpService:GenerateGUID(false)
		local v3 = nil
		object.trove:Add(function()
			if v3 then
				v3:Fire()
				v3:Destroy()
			end
		end)
		object.trove:Connect(
			Net:RemoteEvent("RandomPassives/NewRods", -1).OnClientEvent,
			function(list, p2: number, p3: string?)
				if #v == #list and tick() - now < 10 then
					local flag = true

					for k, v4 in list do
						if v[k] ~= v4 then
							flag = false
						end
					end

					if flag then
						return
					end
				end

				local count = 0

				for _, v4 in list do
					if v4 == p3 then
						count += 1
					end
				end

				if count > 1 then
					p3 = nil
				end

				local lockEnabled = object.config.LockEnabled or false

				if v3 then
					v3:Fire()
					v3:Destroy()
				end

				local v4 = Signal.new()
				v3 = v4
				now = tick()
				v = list
				local flag = false
				v4:Once(function()
					flag = true
				end)
				local icons = { "rbxassetid://71839161790962", "rbxassetid://9125425964" }

				for _, v5 in list do
					local icon = rods[v5].Icon

					if icon and icon ~= "" and icon ~= "rbxassetid://1" and icon ~= "rbxassetid://-1" then
						table.insert(icons, icon)
					else
						warn((`ts "{v5}" rod got no icon 😭😭😭`))
					end
				end

				ContentProvider:PreloadAsync(icons)

				if v3 ~= v4 then
					return
				end

				local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quint)
				local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Linear)
				v2 = p2

				if lockEnabled then
					task.delay(10, function()
						if not flag then
							v4:Fire()
						end
					end)
				end

				local clone = script.MasterlineChangeOverlay:Clone()
				clone.lockText.Visible = lockEnabled
				clone.lockTip.Visible = lockEnabled

				for k, text in list do
					local rod = rods[text]
					local clone2 = script.rodFrame:Clone()
					clone2.rodIcon.Image = rod.Icon or ""
					clone2.Active = lockEnabled
					clone2.Selectable = lockEnabled
					clone2.Modal = lockEnabled

					if typeof(rod.Color) == "Color3" then
						local HSV, v6, v7 = rod.Color:ToHSV()
						clone2.rodIcon.shine.ImageColor3 = Color3.fromHSV(HSV, v6, 1)
						clone2.rodIcon.rodName.TextColor3 = rod.Color
						clone2.rodIcon.lock.ImageColor3 = rod.Color
						clone2.rodIcon.rodName.UIStroke.Color = rod.Color:Lerp(
							v7 < 0.5 and Color3.new(1, 1, 1) or Color3.new(0, 0, 0),
							0.75
						)
					elseif typeof(rod.Color) == "ColorSequence" then
						clone2.rodIcon.shine.UIGradient.Color = rod.Color
						clone2.rodIcon.rodName.UIGradient.Color = rod.Color
						clone2.rodIcon.lock.UIGradient.Color = rod.Color
					end

					if lockEnabled then
						local v6 = clone2
						clone2.MouseEnter:Connect(function()
							if flag then
								return
							end

							v6.rodIcon.lock.Visible = true
						end)
						local v7 = clone2
						clone2.MouseLeave:Connect(function()
							if flag then
								return
							end

							v7.rodIcon.lock.Visible = false
						end)
						local v8 = text
						local v9 = clone2
						clone2.Activated:Once(function()
							if flag then
								return
							end

							if p3 == v8 then
								ReplicatedStorage.events.anno_localthought:Fire("You can't lock the same rod twice in a row.")
								return
							end

							flag = true
							Net:Fire("RandomPassives/NewRods", v8)
							v4:Fire()
							TweenService:Create(v9.rodIcon.lock.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
								Scale = 2
							}):Play()
							script.lock:Play()
						end)
					end

					clone2.rodIcon.ImageTransparency = 1
					clone2.rodIcon.shine.ImageTransparency = 0
					clone2.rodIcon.Position = UDim2.fromScale(0, 1)
					clone2.rodIcon.rodName.Position = UDim2.fromScale(-0.5, 0.5)
					clone2.rodIcon.rodName.Text = text
					clone2.rodIcon.rodName.TextTransparency = 1
					clone2.rodIcon.rodName.UIStroke.Transparency = 1
					clone2.rodIcon.rodName.Visible = true
					clone2.LayoutOrder = k
					clone2.Parent = clone.container
					local v7 = k
					task.delay((k - 1) * 0.15, function()
						if v3 ~= v4 then
							clone2:Destroy()
							return
						end

						local tween = TweenService:Create(clone2.rodIcon, tweenInfo, {
							Position = UDim2.fromScale(0, 0),
							ImageTransparency = 0
						})
						TweenService:Create(clone2.rodIcon.shine, TweenInfo.new(1, Enum.EasingStyle.Linear), {
							ImageTransparency = 1
						}):Play()
						TweenService:Create(clone2.rodIcon.rodName, tweenInfo, {
							Position = UDim2.fromScale(0.5, 0.75),
							TextTransparency = 0
						}):Play()
						TweenService:Create(clone2.rodIcon.rodName.UIStroke, tweenInfo, {
							Transparency = 0
						}):Play()
						tween:Play()
						tween.Completed:Wait()

						if lockEnabled then
							if not flag then
								v4:Wait()
							end
						else
							task.wait(4)
						end

						local tween2 = TweenService:Create(clone2.rodIcon, tweenInfo2, {
							ImageTransparency = 1
						})
						TweenService:Create(
							clone2.rodIcon.rodName,
							TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
							{
								Position = UDim2.fromScale(1, 0.75),
								TextTransparency = 1
							}
						):Play()
						TweenService:Create(
							clone2.rodIcon.rodName.UIStroke,
							TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
							{
								Transparency = 1
							}
						):Play()
						TweenService:Create(
							clone2.rodIcon.lock,
							TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
							{
								ImageTransparency = 1
							}
						):Play()
						tween2:Play()
						tween2.Completed:Wait()

						if v7 == #list then
							clone:Destroy()
						end
					end)
				end

				fx:PlaySound(script.sound2, clone, false)
				clone.Parent = HudController:GetPlayerGui()
			end
		)
		return object
	end
}
setmetatable(RandomPassivesClient, module)
return RandomPassivesClient