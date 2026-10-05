local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
require(ReplicatedStorage.Shared.EventTypes)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local Net = require(ReplicatedStorage.Packages.Net)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
local name = script.Name
local spainEvent = workspace.Sounds.SpainEvent
local remoteEvent = Net:RemoteEvent("EventService/Spain/Burst")
local maid = Trove.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function configurePart(p)
	p.Anchored = false
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
end

local function createPlaceholderVisual()
	local part = Instance.new("Part")
	part.Name = "BullVisual"
	part.Size = createVector(6, 4, 10)
	part.Color = Color3.fromRGB(198, 0, 43)
	part.Material = Enum.Material.SmoothPlastic
	configurePart(part) -- equivalent call inferred; original call site unknown
	return part
end

local function getVisual()
	local bullVisual = script:FindFirstChild("BullVisual")

	if bullVisual and bullVisual:IsA("BasePart") then
		return bullVisual:Clone()
	end

	local part = Instance.new("Part")
	part.Name = "BullVisual"
	part.Size = createVector(6, 4, 10)
	part.Color = Color3.fromRGB(198, 0, 43)
	part.Material = Enum.Material.SmoothPlastic
	configurePart(part) -- equivalent call inferred; original call site unknown
	return part
end

local function createFallbackBurst()
	local part = Instance.new("Part")
	part.Name = "Burst"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Size = createVector(0.25, 0.25, 0.25)
	part.Transparency = 1
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "SpainBurst"
	particleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(198, 0, 43)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 196, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(198, 0, 43))
	})
	particleEmitter.Drag = 4
	particleEmitter.Enabled = false
	particleEmitter.Lifetime = NumberRange.new(0.3, 0.55)
	particleEmitter.LightEmission = 1
	particleEmitter.Rate = 0
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.RotSpeed = NumberRange.new(-180, 180)
	particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 0) })
	particleEmitter.Speed = NumberRange.new(10, 18)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particleEmitter:SetAttribute("EmitCount", 20)
	particleEmitter.Parent = part
	return part
end

local function loadTrack(folder, childName: string, maid2)
	local animation = script:FindFirstChild(childName)

	if not animation or not animation:IsA("Animation") or animation.AnimationId == "" then
		return nil
	end

	local animator = folder:FindFirstChildWhichIsA("Animator", true)

	if not animator then
		return nil
	end

	local track = animator:LoadAnimation(animation)
	maid2:Add(function()
		track:Stop(0)
		track:Destroy()
	end)
	return track
end

local Spain = {}

function Spain.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	EffectController:Activate("Blink")
	CycleController:Update()
	SoundController:UpdateOST()
	maid:Add(function()
		EffectController:Activate("Blink")
		CycleController:Update()
		SoundController:UpdateOST()
	end)
	EffectController:Run("SpainEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("SpainEvent", "GrassRecolor")
	end)
	EffectController:Run("SpainEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("SpainEvent", "WallRecolor")
	end)
	EffectController:Run("SpainEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("SpainEvent", "WallBottomRecolor")
	end)
	local spainMap = not ServerData.IsTsunamiServer() and script:FindFirstChild("SpainMap")

	if spainMap then
		local clone = maid:Clone(spainMap)
		clone.Parent = workspace
	end

	maid:Add(task.spawn(function()
		if not spainEvent.IsLoaded then
			spainEvent.Volume = 0
			spainEvent:Play()
		end

		while not spainEvent.IsLoaded do
			task.wait()
		end

		spainEvent.Volume = 0.25
		spainEvent:Stop()
		spainEvent.Looped = false
		local timePosition = workspace:GetServerTimeNow() - activeEventData.startedAt
		local timeLength = spainEvent.TimeLength

		if timeLength > 0 and timeLength <= timePosition then
			return
		end

		spainEvent.TimePosition = timePosition
		spainEvent:Play()
		maid:Add(function()
			spainEvent:Stop()
		end)
	end))
	local burst = script:FindFirstChild("Burst")

	if not (burst and burst:IsA("BasePart")) then
		burst = createFallbackBurst()
	end

	maid:Add(remoteEvent.OnClientEvent:Connect(function(p)
		ClientEventUtils.playBurst(burst, p, { ReplicatedStorage.Sounds.Events.Spain.Burst })
	end))
	maid:Add(Observers.observeTag("SpainBull", function(model)
		if not model:IsA("Model") then
			return nil
		end

		local maid2 = Trove.new()
		maid2:Add(task.spawn(function()
			local rootPart = model:WaitForChild("RootPart", 10)

			if not (rootPart and rootPart:IsA("BasePart") and model.Parent) then
				return
			end

			local folder = maid2:Add(getVisual())
			configurePart(folder) -- equivalent call inferred; original call site unknown

			for _, descendant in ipairs(folder:GetDescendants()) do
				if descendant:IsA("BasePart") then
					configurePart(descendant) -- equivalent call inferred; original call site unknown
				elseif descendant:IsA("Humanoid") then
					descendant.EvaluateStateMachine = false
					descendant.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
					descendant.PlatformStand = true
				end
			end

			folder.CFrame = rootPart.CFrame
			folder.Parent = model
			local v = maid2:Add(Instance.new("Weld"))
			v.Part0 = rootPart
			v.Part1 = folder
			v.C0 = CFrame.identity
			v.C1 = CFrame.identity
			v.Parent = folder
			local v2 = {}

			for _, v3 in {
				"Idle",
				"Walk",
				"Run",
				"RunAttack",
				"Charge",
				"Attack"
			} do
				local v4 = loadTrack(folder, v3, maid2)

				if not v4 then
					continue
				end

				v4.Looped = v3 ~= "Charge" and v3 ~= "Attack"
				local action3

				if v3 == "Charge" or v3 == "Attack" then
					action3 = Enum.AnimationPriority.Action3
				elseif v3 == "Idle" then
					action3 = Enum.AnimationPriority.Action
				else
					action3 = Enum.AnimationPriority.Action2
				end

				v4.Priority = action3
				v2[v3] = v4
			end

			local function resolveTrack()
				local bullState = model:GetAttribute("BullState")

				if bullState == "Charge" then
					return v2.Charge
				elseif bullState == "Attack" then
					return v2.Attack
				elseif bullState == "RunAttack" then
					return v2.RunAttack or v2.Run or v2.Walk
				elseif bullState == "Run" then
					return v2.Run or v2.Walk
				end

				if bullState == "Walk" and model:GetAttribute("Walking") == true then
					return v2.Walk
				end

				return v2.Idle
			end

			local v3 = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateTrack()
				local track = resolveTrack()

				if track == v3 then
					return
				end

				if v3 and v3.IsPlaying then
					v3:Stop(0.25)
				end

				v3 = track

				if track then
					track:Play(0.25)
				end
			end

			updateTrack() -- equivalent call inferred; original call site unknown
			maid2:Add(model:GetAttributeChangedSignal("BullState"):Connect(updateTrack))
			maid2:Add(model:GetAttributeChangedSignal("Walking"):Connect(updateTrack))
		end))
		return maid2:WrapClean()
	end, { workspace }))
end

function Spain.OnStop(_)
	maid:Destroy()
end

function Spain.OnLoad(_)
	task.spawn(function()
		ContentProvider:PreloadAsync({ spainEvent })
	end)
end

return Spain