local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.ServerInfo)
require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.Shared.FastUtils)
require3(ReplicatedStorage2.Shared.UseNewLobby)
local v6 = require3(ReplicatedStorage2.Shared.PlayerNameUtility)
local v7 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local v8 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local tutorialWon = playerGui:WaitForChild("TutorialWon")
local parryTutorialUI = playerGui:WaitForChild("ParryTutorialUI")
local remoteFunction = v2:RemoteFunction("TutorialGetRandomUsers")
local remoteEvent = v2:RemoteEvent("TutorialTeleport")
v2:RemoteEvent("UpdateCoreGuiState")
v2:RemoteEvent("TutorialCompleted")
local humanoidDescriptionCache = ReplicatedStorage2.Assets.HumanoidDescriptionCache
local tutorial = ReplicatedStorage2.Assets.Tutorial
local random = Random.new()
local currentCamera = workspace.CurrentCamera
local v9 = {
	Shirt = "http://www.roblox.com/asset/?id=607785311",
	Pants = "http://www.roblox.com/asset/?id=382538502"
}

local function preloadImage(image: string, callback)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Image = image
	imageLabel.Parent = script
	pcall(ContentProvider.PreloadAsync, ContentProvider, { imageLabel }, callback)
	imageLabel:Destroy()
end

for _, v10 in pairs(v9) do
	task.spawn(preloadImage, v10)
end

local function createDefaultClothing(parent, className: string, maid)
	local v10 = parent:FindFirstChildOfClass(className) or Instance.new(className)
	local v11 = v9[className]
	v10[`{className}Template`] = v11
	local success, assetFetchStatus = pcall(ContentProvider.GetAssetFetchStatus, ContentProvider, v11)

	if not success or assetFetchStatus ~= Enum.AssetFetchStatus.Success then
		warn("Default clothing has not yet been loaded, changing the character's BodyColors instead")
		local bodyColors = parent:FindFirstChildWhichIsA("BodyColors") or Instance.new("BodyColors")
		local v12 = { "Torso", "LeftLeg", "RightLeg" }
		local v13 = {}

		for _, v14 in v12 do
			local formatted = `{v14}Color`
			v13[formatted] = bodyColors[formatted]
			bodyColors[formatted] = BrickColor.new("Really black")
		end

		local connection = nil
		connection = maid:Add(ContentProvider:GetAssetFetchStatusChangedSignal(v11):Connect(function(p)
			if p == Enum.AssetFetchStatus.Success then
				for _, v14 in v12 do
					local formatted = `{v14}Color`
					bodyColors[formatted] = v13[formatted]
				end

				connection:Disconnect()
			end
		end))
	end

	if parent.Parent and v10.Parent ~= parent then
		v10.Parent = parent
	end

	return v10
end

local function validateClothing(p, instance)
	local maid = v3.new()
	maid:AttachToInstance(instance)

	for _, className in pairs({ "Shirt", "Pants" }) do
		local v10 = tonumber(p[className])

		if not (v10 and v10 ~= 0) then
			continue
		end

		local firstChildOfClass = instance:FindFirstChildOfClass(className)

		if firstChildOfClass then
			local v11 = firstChildOfClass[`{className}Template`]
			local v12 = tonumber(string.match(v11, "%d+"))

			if v12 then
				local formatted = `http://www.roblox.com/asset/?id={v12}`
				local success, assetFetchStatus = pcall(ContentProvider.GetAssetFetchStatus, ContentProvider, formatted)

				if success and assetFetchStatus ~= Enum.AssetFetchStatus.Failure and assetFetchStatus ~= Enum.AssetFetchStatus.TimedOut then
					if assetFetchStatus == Enum.AssetFetchStatus.None then
						task.spawn(preloadImage, formatted, function(_, _) end)
					end

					if assetFetchStatus == Enum.AssetFetchStatus.Loading or assetFetchStatus == Enum.AssetFetchStatus.None then
						local connection = nil
						local values = createDefaultClothing(instance, className, maid)
						local v13 = className
						connection = maid:Add(ContentProvider:GetAssetFetchStatusChangedSignal(formatted):Connect(function(p2)
							if p2 == Enum.AssetFetchStatus.Success then
								values[`{v13}Template`] = formatted
								connection:Disconnect()
							end
						end))
					end
				else
					warn(
						`Failed to fetch texture {formatted} for {className} {v10} when applying HumanoidDescription '{p.Name}' - applying default`,
						assetFetchStatus
					)
					createDefaultClothing(instance, className, maid)
				end
			else
				warn((`Failed to set texture for {className} {v10} when applying HumanoidDescription '{p.Name}' - applying default`))
				createDefaultClothing(instance, className, maid)
			end
		else
			warn((`Failed to find {className} Instance {v10} when applying HumanoidDescription '{p.Name}' - applying default`))
			createDefaultClothing(instance, className, maid)
		end
	end
end

local v10 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function createAnimation(animationId: string)
	if v10[animationId] then
		return v10[animationId]
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	v10[animationId] = animation
	return animation
end

local TutorialController = {
	Init = function(_)
		hidePlayerListOnJoin()
	end,
	Start = function(_)
		local v11 = false
		local flag = false
		local enabledChangedConnection = nil
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local tweenInfo3 = TweenInfo.new(0, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local postSimulationConnection = nil

		local function tweenToTransparency(p: number, tweenInfo4)
			if tweenInfo4.Time == 0 then
				parryTutorialUI.Center.ImageTransparency = p
			else
				v5.fastTween(parryTutorialUI.Center, tweenInfo4, {
					ImageTransparency = p
				})
			end

			for _, frame in parryTutorialUI.Center:GetChildren() do
				if not frame:IsA("Frame") then
					continue
				end

				if tweenInfo4.Time == 0 then
					frame.BackgroundTransparency = p
				else
					v5.fastTween(frame, tweenInfo4, {
						BackgroundTransparency = p
					})
				end
			end
		end

		task.spawn(pcall, function()
			ContentProvider:PreloadAsync({ parryTutorialUI.Center, parryTutorialUI.Center.Image })
		end)
		v2:Connect("ShowParryTutorial", function(flag2: boolean, _: number)
			if flag2 then
				currentCamera.CameraType = Enum.CameraType.Scriptable
				tweenToTransparency(1, tweenInfo3)
				parryTutorialUI.Enabled = true
				tweenToTransparency(0.2, tweenInfo)
				parryTutorialUI.TextLabel.Text = `<stroke color="rgb(0,0,0)" joins="round" thickness="2">{v.TouchEnabled and "TAP" or "CLICK"} ON THE <font color="rgb(118, 189, 255)">SCREEN</font> TO BLOCK THE BALL<font color="rgb(255, 58, 58)"></font> <font color="rgb(255, 58, 58)"></font></stroke>`
				local now = 0
				postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
					local v12 = workspace.Balls:GetChildren()[1]

					if v12 then
						local position = v12:GetPivot().Position
						local worldToViewportPoint, v13 = currentCamera:WorldToViewportPoint(position)

						if v13 then
							parryTutorialUI.Center.Position = UDim2.fromOffset(
								worldToViewportPoint.X,
								worldToViewportPoint.Y
							)
							local v14 = math.clamp(7 / worldToViewportPoint.Z, 0.1, 0.7)
							parryTutorialUI.Center.Size = UDim2.fromScale(v14, v14)
						end

						if v13 and not (os.clock() - now < 1) then
							now = 0
						else
							local character = localPlayer.Character
							local pivot = character and character:GetPivot() or CFrame.identity
							currentCamera.CFrame = currentCamera.CFrame:Lerp(
								CFrame.lookAt((pivot * CFrame.new(0, 4, 9)).Position, position),
								dt * 6
							)

							if now == 0 then
								now = os.clock()
							end

							parryTutorialUI.Center.Position = UDim2.fromScale(1.5, 1)
						end
					end
				end)
			else
				if postSimulationConnection then
					postSimulationConnection:Disconnect()
				end

				currentCamera.CameraType = Enum.CameraType.Custom

				if parryTutorialUI.Enabled then
					tweenToTransparency(1, tweenInfo2)
					task.wait(tweenInfo2.Time)
					parryTutorialUI.Enabled = false
				end
			end
		end)
		v2:Connect("TutorialCompleted", function(p: string)
			if flag then
				return
			end

			flag = true
			tutorialWon.MainFrame.FadeTitle.Title.Text = `<stroke color="rgb(2, 75, 0)" joins="round" thickness="4">{p}<font color="rgb(255, 58, 58)"></font></stroke>`
			tutorialWon.Black.BackgroundTransparency = 1
			local tween = TweenService:Create(tutorialWon.Black, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
				BackgroundTransparency = 0.25
			})
			tutorialWon.MainFrame.PlayButton.Position = UDim2.fromScale(0.5, 1.742)
			tutorialWon.MainFrame.PlayButton.ImageTransparency = 1
			local tween2 = TweenService:Create(
				tutorialWon.MainFrame.PlayButton,
				TweenInfo.new(0.4, Enum.EasingStyle.Quart),
				{
					Position = UDim2.fromScale(0.5, 0.742),
					ImageTransparency = 0
				}
			)
			tutorialWon.MainFrame.FadeTitle.Position = UDim2.fromScale(0.5, -1.328)
			tutorialWon.MainFrame.FadeTitle.ImageTransparency = 1
			local tween3 = TweenService:Create(
				tutorialWon.MainFrame.FadeTitle,
				TweenInfo.new(0.4, Enum.EasingStyle.Quart),
				{
					Position = UDim2.fromScale(0.5, 0.328),
					ImageTransparency = 0
				}
			)
			v7(Enum.CoreGuiType.Chat, false)
			v7(Enum.CoreGuiType.PlayerList, false)
			tutorialWon.Enabled = true
			enabledChangedConnection = tutorialWon:GetPropertyChangedSignal("Enabled"):Connect(function()
				tutorialWon.Enabled = true
			end)
			tween:Play()
			task.wait(0.1)
			tween3:Play()
			tween3.Completed:Wait()
			task.wait(0.1)
			tween2:Play()
			task.delay(15, function()
				if not v11 then
					remoteEvent:FireServer()
				end
			end)
		end)
		v2:Connect("UpdateCoreGuiState", function(p, ...)
			if p == "Show" then
				setShow(...)
			elseif p == "Hide" then
				setHide(...)
			end
		end)
		tutorialWon.MainFrame.PlayButton.MouseButton1Click:Connect(function()
			remoteEvent:FireServer()
			v11 = true

			if enabledChangedConnection then
				enabledChangedConnection:Disconnect()
				enabledChangedConnection = nil
			end

			tutorialWon.Enabled = false
		end)
		hidePlayerListOnJoin()

		if v4.isTutorialServer() or v4.isNewPlayerLobbyServer() then
			local v12, v13 = remoteFunction:InvokeServer()
			random = Random.new(v13)
			local v14 = v3.new()
			local spawn = workspace:WaitForChild("Spawn", 99)
			local tutorialBotPositions = spawn:WaitForChild("TutorialBotPositions")
			local spawnLocation = spawn:WaitForChild("SpawnLocation")
			local v15 = {
				{
					Part = tutorialBotPositions:WaitForChild("ExplosionCrate"),
					Margin = 5,
					Count = { 0, 1 }
				},
				{
					Part = tutorialBotPositions:WaitForChild("SwordCrate"),
					Margin = 5,
					Count = { 1, 1 }
				},
				{
					Part = tutorialBotPositions:WaitForChild("Wheel"),
					Margin = 5,
					Count = { 1, 1 }
				},
				{
					Part = tutorialBotPositions:WaitForChild("LobbyWall"),
					Margin = 15,
					Count = { 2, 3 }
				},
				{
					Part = tutorialBotPositions:WaitForChild("LobbyWall2"),
					Margin = 15,
					Count = { 3, 3 }
				},
				{
					Part = spawnLocation,
					Margin = 25,
					Count = { 3, 3 }
				}
			}
			local v16 = {}
			local v17 = nil
			local botsById = {}

			for i = 1, 8 do
				table.insert(v16, {
					Part = tutorialBotPositions:WaitForChild((`WanderPoint{i}`)),
					Margin = 8,
					Count = { 0, 1 }
				})
			end

			for _, v18 in v15 do
				v18.CFrame = v18.Part.CFrame
			end

			for _, v18 in v16 do
				v18.CFrame = v18.Part.CFrame
			end

			local function generateNewPositions()
				local v18 = workspace:GetServerTimeNow() // 10
				local clone = table.clone(v15)
				local result = {}

				for _, v19 in clone do
					for _ = 1, random:NextInteger(v19.Count[1], v19.Count[2]) do
						table.insert(result, table.clone(v19))
					end
				end

				local count = #result

				for i = 1, count do
					local v19 = v18 + i * 10
					local integer = Random.new(v19):NextInteger(1, count)
					local v20 = result[i]
					result[i] = result[integer]
					result[integer] = v20
				end

				return result
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function getFinalPosition(p)
				return p.CFrame.Position + random:NextUnitVector() * random:NextNumber(0, p.Margin)
			end

			local function getHumanoidDescription(id)
				local name = tostring(id)
				local child = humanoidDescriptionCache:FindFirstChild(name)

				if child then
					return child
				end

				local success, result = pcall(function()
					return Players:GetHumanoidDescriptionFromUserIdAsync(id)
				end)

				if not success then
					return tutorial:WaitForChild("HumanoidDescription")
				end

				result.Name = name
				result.Parent = humanoidDescriptionCache
				return result
			end

			local function createBot(data, p: number)
				local maid = v3.new()
				local clone = maid:Clone(data.Model or tutorial.Bot)
				clone:PivotTo((spawn:FindFirstChild("Pivot") or spawn:FindFirstChildWhichIsA("SpawnLocation", true)):GetPivot() * CFrame.new(
					(math.random() - 0.5) * 6,
					clone:GetExtentsSize().Y / 2 + 0.1,
					(math.random() - 0.5) * 6
				))
				clone.Parent = workspace.Dead
				v8:EquipSwordTo(clone, data.Sword or "Base Sword")
				local humanoid = clone:WaitForChild("Humanoid")
				task.spawn(validateClothing, humanoid:GetAppliedDescription(), clone)
				local animator = humanoid:WaitForChild("Animator")
				local animation = createAnimation("rbxassetid://180435571") -- equivalent call inferred; original call site unknown
				local track = animator:LoadAnimation(animation)
				local animation2 = createAnimation("rbxassetid://13772440420") -- equivalent call inferred; original call site unknown
				local track2 = animator:LoadAnimation(animation2)
				local animation3 = createAnimation("rbxassetid://13772468608") -- equivalent call inferred; original call site unknown
				local track3 = animator:LoadAnimation(animation3)
				local animation4 = createAnimation("rbxassetid://125750702") -- equivalent call inferred; original call site unknown
				local track4 = animator:LoadAnimation(animation4)
				local v18 = { "rbxassetid://14351095988", "rbxassetid://14351086764", "rbxassetid://14351086764" }
				local animation5 = createAnimation(v18[random:NextInteger(1, #v18)]) -- equivalent call inferred; original call site unknown
				local track5 = animator:LoadAnimation(animation5)
				track:Play()
				track2:Play()
				local v20 = v17[p]

				if v20 then
					task.delay(random:NextNumber(0, 3), function()
						if not clone then
							return
						end

						local finalPosition = getFinalPosition(v20) -- equivalent call inferred; original call site unknown
						maid:Add(humanoid:GetPropertyChangedSignal("WalkToPoint"):Connect(function()
							local magnitude = ((clone:GetPivot().Position - humanoid.WalkToPoint) * createVector(
								1,
								0,
								1
							)).Magnitude

							if humanoid:GetState() == Enum.HumanoidStateType.None or magnitude < 1 then
								track3:Stop()
							elseif not track3.IsPlaying then
								track3:Play()
							end

							if track3.IsPlaying and track5.IsPlaying then
								track5:Stop()
							end
						end))
						local v22 = {
							AFK = random:NextNumber() < 0.35
						}

						if v20.Part == spawnLocation then
							v22.AFK = true
						end

						v22.Emoter = v22.AFK and random:NextNumber() < 0.15
						v22.Wanderer = not v22.AFK and random:NextNumber() < 0.35
						v22.Jumpy = not v22.AFK and random:NextNumber() < 0.3

						if v22.Jumpy then
							maid:Add(task.spawn(function()
								while clone and clone.Parent do
									if random:NextNumber() < 0.1 and track3.IsPlaying then
										humanoid.Jump = true
										track4:Play(nil, 100)
									end

									task.wait(0.1)
								end
							end))
						end

						maid:Add(humanoid.MoveToFinished:Connect(function()
							track3:Stop()

							if v22.Emoter then
								task.wait(random:NextNumber(0, 3))
								track5:Play()
							end

							local number = random:NextNumber(6, 8)

							if v22.AFK then
								number *= 2
							end

							if v22.Wanderer then
								if random:NextNumber() < 0.3 then
									number = 0
								elseif random:NextNumber() < 0.8 then
									number = random:NextNumber(0.25, 1)
								end
							end

							local v23 = v20.Part == spawnLocation and 1000 or number
							task.wait(v23)

							if not (clone and humanoid and clone.Parent) then
								return
							end

							local v24

							if v22.Wanderer then
								v24 = v16
							else
								v24 = v17
							end

							local v25 = v24[random:NextInteger(1, #v24)]

							while v25.Part == spawnLocation do
								v25 = v24[random:NextInteger(1, #v24)]
								task.wait()
							end

							local v26 = v25 and getFinalPosition(v25)

							if v26 then
								humanoid:MoveTo(v26)
							end
						end))
						humanoid:MoveTo(finalPosition)
					end)
				end

				if not data.Model then
					task.spawn(pcall, function()
						humanoid:ApplyDescriptionAsync(tutorial:WaitForChild("RandomUserHumanoidDescriptions"):WaitForChild(
							data.Id,
							5
						) or getHumanoidDescription(data.Id))
					end)
				end

				humanoid.DisplayName = v6:GetHumanoidDisplayName(data, false)
				humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
				return clone, maid
			end

			local function onGameStateChange()
				v12, v13 = remoteFunction:InvokeServer()
				random = Random.new(v13)

				if workspace:GetAttribute("GameActive") then
					v14:Destroy()
					table.clear(botsById)
				end

				if not workspace:GetAttribute("GameActive") then
					local v18 = workspace:GetServerTimeNow() // 10
					local clone = table.clone(v12)
					local v19 = v12[1]
					local count = #clone

					for i = 1, count do
						local v20 = v18 + i * 10
						local integer = Random.new(v20):NextInteger(1, count)
						local v21 = clone[i]
						clone[i] = clone[integer]
						clone[integer] = v21
					end

					v17 = generateNewPositions()

					for k, v20 in clone do
						if not (not workspace:GetAttribute("AB_IsOneBotTutorial") or v20 == v19) or botsById[v20.Id] then
							continue
						end

						local v21 = v20
						local v22 = k
						task.delay(k * (0.1 + math.random() * 0.5), function()
							local bot, v23 = createBot(v21, v22)
							botsById[v21.Id] = bot
							v14:Add(v23)
						end)
					end
				end
			end

			v17 = generateNewPositions()
			v2:Connect("TutorialBotDied", function(p, p2: number)
				task.wait(Players.RespawnTime)

				if workspace:GetAttribute("GameActive") and not botsById[p.Id] then
					local bot, v18 = createBot(p, p2)
					botsById[p.Id] = bot
					v14:Add(v18)
				end
			end)
			workspace:GetAttributeChangedSignal("GameActive"):Connect(onGameStateChange)
			task.spawn(onGameStateChange)
		end
	end
}

function hidePlayerListOnJoin()
	if v4.isTutorialServer() then
		task.spawn(setHide)
	end
end

function setShow()
	v7(Enum.CoreGuiType.PlayerList, true)
end

function setHide()
	v7(Enum.CoreGuiType.PlayerList, false)
end

return TutorialController