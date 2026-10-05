local createVector = vector.create
local UserInputService = game:GetService("UserInputService")
game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Trove = require(ReplicatedStorage.Packages.Trove)
local RegisterTool = require(ReplicatedStorage.Shared.RegisterTool)
require(ReplicatedStorage.Controllers.AnimalController)
local FishingController = require(ReplicatedStorage.Controllers.FishingController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Shared.PID)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
local Net = require(ReplicatedStorage.Packages.Net)
local Spring = require(ReplicatedStorage.Packages.Spring)
local _ = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local fishing = localPlayer.PlayerGui.ToolGuis.Fishing
local remoteEvent = Net:RemoteEvent("FishingRod.Cast")
local remoteEvent2 = Net:RemoteEvent("FishingRod.Cancel")
local remoteEvent3 = Net:RemoteEvent("FishingRod.SetupBobber")
local remoteEvent4 = Net:RemoteEvent("FishingRod.MinigameClick")
local remoteEvent5 = Net:RemoteEvent("FishingRod.Reward")
local remoteEvent6 = Net:RemoteEvent("FishingRod.BiteGot")
Random.new()
local v = Spring.new()
v.Speed = 45
v.Damper = 0.8
local v2 = Spring.new(0.1)
v2.Speed = 2
v2.Damper = 1
local v3 = Spring.new(70)
v3.Speed = 30
v3.Damper = 1
local mover = fishing.Fillbar.Mover
local flag = false
local flag2 = false
RunService.Heartbeat:Connect(function()
	if flag then
		mover.Rotation = v.p
		v3.t = 80 + 10 * v2.p
		flag2 = true
	elseif flag2 then
		flag2 = false
		v3.t = 70
		v3.p = 70
		v3.v = 0
	end
end)

local function QuadInOut_Clamped(p)
	if p >= 0.85 then
		return 1
	end

	local v4 = p / 0.85

	if v4 < 0.5 then
		return 2 * v4 * v4
	end

	return -1 + (4 - 2 * v4) * v4
end

local v4 = {}
RegisterTool("FishingRod", function(instance)
	local maid = Trove.new()
	local maid2 = maid:Extend()
	local v5 = false
	local minigameHits = 0
	local minigameTotalHits = 0
	local v6 = 0
	local humanoid = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
	local tracksByName = {}

	local function reloadAnimations()
		local equippedFishingRod = localPlayer:GetAttribute("EquippedFishingRod")

		for _, child in (script:FindFirstChild(equippedFishingRod) or script["Ice Rod"]):GetChildren() do
			local name = child.Name
			local track = humanoid:LoadAnimation(child)
			track.Looped = child:GetAttribute("Looped")
			track.Priority = child:GetAttribute("Priority")
			local v7 = tracksByName[name]

			if v7 then
				if v7.IsPlaying and v7.Looped then
					track:Play()
				end

				v7:Stop()
			end

			tracksByName[name] = track
		end
	end

	reloadAnimations()
	maid:Add(localPlayer:GetAttributeChangedSignal("EquippedFishingRod"):Connect(reloadAnimations))
	maid:Add(RunService.Stepped:Connect(function()
		local reeling = instance:FindFirstChild("Reeling", true)

		if reeling then
			reeling.PlaybackSpeed = 0.9 + v2.p * 0.1
			reeling.Volume = 0.3 + v2.p * 0.3
		end

		tracksByName.Reeling:AdjustSpeed(v2.p)
	end))

	local function updateMinigameHits()
		if not minigameHits then
			return
		end

		local v7 = minigameHits / instance:GetAttribute("minigameHP")

		if v6 < minigameHits then
			local v8 = 0.2 + 0.6 * v7
			v2.p = math.clamp(v2.p + v8, 0.1, 1.3)
			v2.t = 0.1
			SoundService:PlayLocalSound(fishing.Click)
		end

		TweenService:Create(fishing.Fillbar.Fill, TweenInfo.new(0.2), {
			Size = UDim2.fromScale(v7, 1)
		}):Play()
		TweenService:Create(fishing.Fillbar.Mover, TweenInfo.new(0.25), {
			Position = UDim2.fromScale(math.lerp(0, 0.875, v7), 0.5)
		}):Play()
		v6 = minigameHits
	end

	local function updateMinigameTotalClicks()
		if not minigameTotalHits then
			return
		end

		if string.format("%.3d", minigameTotalHits) == 0 then
			fishing.Fillbar.TextLabel.Text = "Click Anywhere!"
		else
			fishing.Fillbar.TextLabel.Text = `Click Anywhere! (x{minigameTotalHits})`
		end

		fishing.Fillbar.TextLabel.Size = UDim2.fromScale(0.568, 0.75)
		TweenService:Create(
			fishing.Fillbar.TextLabel,
			TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true),
			{
				Size = UDim2.fromScale(0.7, 0.85)
			}
		):Play()
	end

	maid:Add(instance:GetAttributeChangedSignal("minigameHits"):Connect(function()
		minigameHits = instance:GetAttribute("minigameHits")
		updateMinigameHits()
	end))
	maid:Add(instance:GetAttributeChangedSignal("minigameTotalHits"):Connect(function()
		minigameTotalHits = instance:GetAttribute("minigameTotalHits")
		updateMinigameTotalClicks()
	end))
	maid:Add(instance:GetAttributeChangedSignal("minigame"):Connect(function()
		if instance:GetAttribute("minigame") then
			flag = true
			tracksByName.Reeling:Play()
			fishing.Fillbar.Visible = true
		else
			tracksByName.Reeling:Stop()
			fishing.Fillbar.Visible = false
			flag = false
		end
	end))
	maid:Add(instance:GetAttributeChangedSignal("casted"):Connect(function()
		if instance:GetAttribute("casted") and not instance:GetAttribute("minigame") then
			v2.p = 0
			v2.v = 0
			v2.t = 0
			tracksByName.Reeling:Play()
		elseif not (instance:GetAttribute("casted") or instance:GetAttribute("minigame")) then
			tracksByName.Reeling:Stop()
		end
	end))
	maid:Add(instance.Equipped:Connect(function()
		v5 = true
		fishing.Enabled = true
		fishing.Fillbar.Visible = false
		fishing.CastBar.Enabled = false
		tracksByName.Idle:Play()
	end))
	maid:Add(instance.Unequipped:Connect(function()
		v5 = false
		fishing.Enabled = false
		maid2:Destroy()

		for _, v7 in tracksByName do
			v7:Stop()
		end
	end))
	local flag3 = false
	local v7 = -1

	local function onMouseDown()
		local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")

		if instance:GetAttribute("minigame") then
			if time() - v7 < 0.1 then
				return
			end

			v7 = time()
			minigameHits += 1
			minigameTotalHits += 1
			updateMinigameTotalClicks()
			updateMinigameHits()
			remoteEvent4:FireServer()
		else
			if instance:GetAttribute("casted") then
				remoteEvent2:FireServer()
				return
			end

			if instance:GetAttribute("castCooldown") or flag3 then
				return
			end

			flag3 = true
			fishing.CastBar.Enabled = true
			fishing.CastBar.Adornee = humanoidRootPart
			maid2:Add(function()
				fishing.CastBar.Enabled = false
			end)
			local v8 = time()
			local v9 = nil
			local luck = instance:GetAttribute("Luck") or 1
			maid2:Add(instance:GetAttributeChangedSignal("Luck"):Connect(function()
				luck = instance:GetAttribute("Luck") or 1
			end))
			tracksByName.HoldingCast:Play()
			tracksByName.HoldingCast:AdjustSpeed(1)
			maid2:Add(function()
				tracksByName.HoldingCast:Stop()
			end)

			while flag3 and v5 do
				local v10 = (time() - v8) % 1

				if v10 > 0.5 then
					v10 = 1 - v10
				end

				local v11 = v10 / 0.5

				if v11 >= 0.85 then
					v9 = 1
				else
					local v12 = v11 / 0.85

					if v12 < 0.5 then
						v9 = 2 * v12 * v12
					else
						v9 = -1 + (4 - 2 * v12) * v12
					end
				end

				fishing.CastBar.Bar.Bar.Fill.Size = UDim2.fromScale(1, v9)
				fishing.CastBar.Bar.Luck.Size = UDim2.fromScale(8, 0.14 + 0.05 * v9)
				fishing.CastBar.Bar.Luck.Text = `LUCK: {math.floor(math.lerp(1, luck, v9) * 100) / 100}x`

				if not tracksByName.HoldingCast.IsPlaying then
					tracksByName.HoldingCast:Play()
					tracksByName.HoldingCast.TimePosition = tracksByName.HoldingCast.Length - 0.01
					tracksByName.HoldingCast:AdjustSpeed(0)
				end

				task.wait()
			end

			maid2:Destroy()

			if not v5 then
				return
			end

			tracksByName.Cast:Play()
			remoteEvent:FireServer(v9)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onMouseUp()
		flag3 = false
		maid2:Destroy()
	end

	maid:Add(instance.Activated:Connect(onMouseDown))
	maid:Add(instance.Deactivated:Connect(onMouseUp))
	maid:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.Touch then
			onMouseDown()
		end
	end))
	maid:Add(UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.Touch then
			onMouseUp() -- equivalent call inferred; original call site unknown
		end
	end))
	v4[instance] = {
		animTracks = tracksByName
	}
	maid:Add(function()
		flag = false
		v5 = false
		fishing.Enabled = false
		v4[instance] = nil

		for _, v8 in tracksByName do
			v8:Stop()
		end
	end)
	return maid:WrapClean()
end)
remoteEvent3.OnClientEvent:Connect(function(instance, assemblyLinearVelocity)
	local primaryPart = instance.PrimaryPart
	primaryPart.AssemblyLinearVelocity = assemblyLinearVelocity
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(0, 0, 0)
	bodyVelocity.Velocity = createVector(0, 0, 0)
	bodyVelocity.Parent = primaryPart
	local PID = require(ReplicatedStorage.Shared.PID)
	PID.new(-16, 16, 36, 1.5, 0.1)
	local v5 = workspace:FindFirstChild("FishingMap") and workspace:FindFirstChild("FishingMap"):QueryDescendants("#CatchZone") or {}
	local steppedConnection = nil
	steppedConnection = RunService.Stepped:Connect(function(_)
		if not (instance and instance:IsDescendantOf(workspace)) then
			steppedConnection:Disconnect()
			return
		end

		local v6 = nil

		for _, v8 in v5 do
			if not MathUtils.isPointInVolume(primaryPart.CFrame.Position, v8.CFrame, v8.Size + createVector(0, 1.5, 0)) then
				continue
			end

			v6 = v8
			break
		end

		if not v6 then
			return
		end

		bodyVelocity.MaxForce = Vector3.new(
			32 + primaryPart.AssemblyMass * 32,
			1000000000,
			32 + primaryPart.AssemblyMass * 32
		)
		local Y = FishingController:WaterSurfacePoint(primaryPart.Position).Y
		bodyVelocity.Velocity = createVector(0, 0, 0)
		RunService.RenderStepped:Once(function()
			primaryPart.CFrame = CFrame.new(primaryPart.Position.X, Y, primaryPart.Position.Z)
		end)
	end)
end)
remoteEvent5.OnClientEvent:Connect(function(player, p, p2, _, p3, _)
	if player == localPlayer then
		v4[p].animTracks.Catch:Play()
	end

	local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v5 = humanoidRootPart.Position - createVector(0, 3, 0)
	local v6 = v5:Lerp(p2, 0.3) + createVector(0, 20, 0)
	local clone = ReplicatedStorage.Models.ToolsExtras.FishingCatch:Clone()
	clone.CFrame = CFrame.new(0, 10000, 0)
	clone.Transparency = 1
	clone.Parent = workspace.Debris

	local function Bezier(p4, p5, p6, p7)
		local v7 = 1 - p7
		return p4 * (v7 * v7) + p6 * (2 * v7 * p7) + p5 * (p7 * p7)
	end

	local scale = nil
	local total = 0
	local preRenderConnection = nil
	preRenderConnection = RunService.PreRender:Connect(function(dt)
		total += dt

		if total >= 0.5 then
			if preRenderConnection then
				preRenderConnection:Disconnect()
			end

			task.wait(2)
			clone:Destroy()
		else
			local v10 = total / 0.5
			local v11 = 1 - v10
			local v12 = p2 * (v11 * v11) + v6 * (2 * v11 * v10) + v5 * (v10 * v10)
			local v16 = total / 0.5 + 0.01
			local v17 = 1 - v16
			local v18 = p2 * (v17 * v17) + v6 * (2 * v17 * v16) + v5 * (v16 * v16)
			clone.CFrame = CFrame.lookAt(v12, v18)
			local animalModel = ClientEventUtils.getAnimalModel(p3)

			if not animalModel then
				return
			end

			if not scale then
				scale = animalModel:GetScale()
			end

			animalModel:ScaleTo((math.max(scale * total / 0.5, 0.01)))
			animalModel:PivotTo(CFrame.new(v12))
		end
	end)
end)
remoteEvent6.OnClientEvent:Connect(function(player, _)
	local character = player.Character
	assert(character)
	local head = character:FindFirstChild("Head")
	assert(head)
	local clone = script.FishingGotBite:Clone()
	clone.Adornee = head
	clone.Parent = head
	clone.Exclamation:Play()
	local textLabel = clone.TextLabel
	textLabel.Rotation = 15
	textLabel.Size = UDim2.fromScale(0, 0)
	textLabel.Position = UDim2.fromScale(0.5, 1)
	TweenService:Create(textLabel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Rotation = 0,
		Size = UDim2.fromScale(1, 1)
	}):Play()
	task.delay(2, function()
		if textLabel:IsDescendantOf(game) then
			TweenService:Create(textLabel, TweenInfo.new(2), {
				TextTransparency = 1
			}):Play()
			TweenService:Create(textLabel.UIStroke, TweenInfo.new(2), {
				Transparency = 1
			}):Play()
		end

		task.wait(2)
		clone:Destroy()
	end)
end)