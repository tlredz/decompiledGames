local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local General = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("General"))
local Effects = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Effects"))
local String = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("String"))
local PetAging = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetAging"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("Services"):WaitForChild("FormatNumber"):WaitForChild("Main"))
local Pets = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Pets"))
local rarityGradients = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("RarityGradients")
local Mutations = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Mutations"))
local Rebirths = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Rebirths"))
local PetRigService = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetRigService"))
local smoke = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Effects"):WaitForChild("Smoke")
local petCash = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Billboards"):WaitForChild("PetCash")
local petSpeed = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Billboards"):WaitForChild("PetSpeed")
local SFX = SoundService:WaitForChild("SFX")
local animals = SoundService:WaitForChild("Animals")

local function SetAnimation(state, wantedTrack, p)
	state.WantedTrack = wantedTrack

	if state.Culled or not state.Tracks then
		return
	end

	local track = state.Tracks[wantedTrack]
	local track2 = state.Tracks[wantedTrack == "Idle" and "Move" or "Idle"]

	if track2 and track2.IsPlaying then
		track2:Stop(p)
	end

	if track and not track.IsPlaying then
		track:Play(p)

		if wantedTrack == "Move" and state.MoveRate then
			track:AdjustSpeed(state.MoveRate)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function LoadTracks(p)
	if next(p.Tracks) ~= nil then
		return
	end

	local model = p.Model
	pcall(function()
		local animationController = model:FindFirstChildOfClass("AnimationController")
		local animations = model:FindFirstChild("Animations")

		if not (animationController and animations) then
			return
		end

		local v = animationController:FindFirstChildOfClass("Animator")

		if not v then
			v = Instance.new("Animator")
			v.Parent = animationController
		end

		local idle = animations:FindFirstChild("Idle")

		if idle then
			p.Tracks.Idle = v:LoadAnimation(idle)
			p.Tracks.Idle.Looped = true
		end

		local walk = animations:FindFirstChild("Walk") or animations:FindFirstChild("Run") or animations:FindFirstChild("Fly")

		if walk then
			p.Tracks.Move = v:LoadAnimation(walk)
			p.Tracks.Move.Looped = true
		end
	end)
end

local function StopTracks(p)
	for _, track in pairs(p.Tracks) do
		local v = track
		pcall(function()
			v:Stop(0)
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CullOrigin()
	local character = Players.LocalPlayer and Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local currentCamera = workspace.CurrentCamera
	return humanoidRootPart and humanoidRootPart.Position or currentCamera and currentCamera.CFrame.Position
end

local function RefreshCull(state, p)
	local model = state.Model

	if not (p and model and model.Parent) then
		return nil
	end

	local magnitude = (model:GetPivot().Position - p).Magnitude

	if state.Culled or not (magnitude > 500) then
		if state.Culled and magnitude >= 470 then
			return nil
		end

		return magnitude
	else
		state.Culled = true
		StopTracks(state)
		return nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Wake(p)
	p.Culled = nil
	LoadTracks(p) -- equivalent call inferred; original call site unknown
	SetAnimation(p, p.WantedTrack or "Idle", 0.2)
end

local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function QueueWake(p)
	table.insert(v, 1, p)
end

local function GetFootstepTemplates(petName)
	local folder = animals:FindFirstChild(petName)

	if not (folder and folder:IsA("Folder")) then
		return nil
	end

	local footsteps = folder:FindFirstChild("Footsteps")

	if not footsteps then
		return nil
	end

	local sounds = {}

	for _, sound in footsteps:GetChildren() do
		if sound:IsA("Sound") then
			table.insert(sounds, sound)
		end
	end

	return #sounds > 0 and sounds or nil
end

local function EnsureWalkSounds(primaryPart, items)
	local clones = {}

	for _, item in items do
		for i = 1, 4 do
			local name = string.format("%s%d_%s", "WalkFootstep_", i, item.Name)
			local clone = primaryPart:FindFirstChild(name)

			if not clone then
				clone = item:Clone()
				clone.Name = name
				clone.Parent = primaryPart
			end

			table.insert(clones, clone)
		end
	end

	return clones
end

local function BaseVolumeOf(instance)
	local baseVolume = instance:GetAttribute("BaseVolume")

	if not baseVolume then
		baseVolume = instance.Volume
		instance:SetAttribute("BaseVolume", baseVolume)
	end

	return baseVolume
end

local function PlayFootstepClip(footstepClip, playbackSpeed)
	footstepClip:SetAttribute("FadeToken", (footstepClip:GetAttribute("FadeToken") or 0) + 1)
	footstepClip:SetAttribute("Fading", false)
	local baseVolume = footstepClip:GetAttribute("BaseVolume")

	if not baseVolume then
		baseVolume = footstepClip.Volume
		footstepClip:SetAttribute("BaseVolume", baseVolume)
	end

	footstepClip.Volume = baseVolume
	footstepClip.PlaybackSpeed = playbackSpeed
	footstepClip:Play()
end

local function StopFootstepClips(footstepClips)
	if not footstepClips then
		return
	end

	for _, item in footstepClips do
		if not item.Playing or item:GetAttribute("Fading") then
			continue
		end

		local baseVolume = item:GetAttribute("BaseVolume")

		if not baseVolume then
			baseVolume = item.Volume
			item:SetAttribute("BaseVolume", baseVolume)
		end

		local v2 = (item:GetAttribute("FadeToken") or 0) + 1
		item:SetAttribute("FadeToken", v2)
		item:SetAttribute("Fading", true)
		local v3 = item
		task.spawn(function()
			local total = 0

			while total < 0.08 do
				total += task.wait()

				if v3:GetAttribute("FadeToken") ~= v2 then
					return
				end

				v3.Volume = baseVolume * math.max(1 - total / 0.08, 0)
			end

			v3:Stop()
			v3.Volume = baseVolume
			v3:SetAttribute("Fading", false)
		end)
	end
end

local function StepFootsteps(state)
	if not (state.Model and state.Model:IsDescendantOf(workspace)) then
		return
	end

	local footstepClips = state.FootstepClips

	if footstepClips and #footstepClips > 0 then
		local now = os.clock()

		if now < (state.NextStepClock or 0) then
			return
		end

		local value = state.FootstepSpeedValue and tonumber(state.FootstepSpeedValue.Value)
		local v2 = (not value or value <= 0) and 1 or value
		local v3 = state.FootstepOverlapValue and state.FootstepOverlapValue.Value == true
		local playbackSpeed = math.clamp(
			(state.TravelSpeed or state.MoveSpeed or 6) / (state.SpeedReference or 6),
			0.5,
			3
		) * 1
		local footstepClip = footstepClips[math.random(#footstepClips)]
		PlayFootstepClip(footstepClip, playbackSpeed)
		local v5

		if v3 then
			v5 = 0.3 / playbackSpeed / v2
		else
			v5 = footstepClip.TimeLength / playbackSpeed * 0.85 / v2
		end

		state.NextStepClock = now + math.clamp(v5, 0.05, 3)
	elseif state.FootstepLoop and not state.FootstepLoop.Playing then
		state.FootstepLoop:Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopFootsteps(state)
	state.NextStepClock = 0
	StopFootstepClips(state.FootstepClips)

	if state.FootstepLoop and state.FootstepLoop.Playing then
		state.FootstepLoop:Stop()
	end
end

local PetRenderer = {}
local v2 = {}
local v3 = {}
PetRenderer.Added = Instance.new("BindableEvent")
PetRenderer.Removed = Instance.new("BindableEvent")

local function CashMultiplierFor(ownerUserId)
	local playerByUserId = Players:GetPlayerByUserId(ownerUserId)
	local savedData = playerByUserId and playerByUserId:FindFirstChild("SavedData")
	local rebirths = savedData and savedData:FindFirstChild("Rebirths")
	local noSaveData = playerByUserId and playerByUserId:FindFirstChild("NoSaveData")
	local friendsPlaying = noSaveData and noSaveData:FindFirstChild("FriendsPlaying")
	local v4 = 1 + (friendsPlaying and friendsPlaying.Value or 0) * 0.1
	return Rebirths.GetMultiplier(rebirths and rebirths.Value or 0) * v4
end

local function KeyOf(p, p2)
	return p .. "::" .. p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function MutationFactorFor(p)
	return Mutations.CombinedFactor(p.Mutation, p.SpawnMutation)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ApplyMutationAura(p, mutation)
	PetRigService.ApplyMutationAura(p, mutation)
end

local _ = {
	"M",
	"B",
	"T",
	"Qa",
	"Qi",
	"Sx",
	"Sp",
	"Oc",
	"No",
	"Dc"
}

function PetRenderer.FormatCash(p)
	return String.Abbreviate(p)
end

local function FindGround(p)
	local characters = {}

	for _, v4 in Players:GetPlayers() do
		if v4.Character then
			table.insert(characters, v4.Character)
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = characters
	raycastParams.RespectCanCollide = true
	local raycastResult = workspace:Raycast(p + createVector(0, 25, 0), createVector(0, -150, 0), raycastParams)
	return raycastResult and raycastResult.Position.Y or p.Y
end

local visibleExtentsY = PetRigService.VisibleExtentsY

local function VisibleBottomY(p)
	return (visibleExtentsY(p))
end

local formatSpeed = PetAging.FormatSpeed

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshSpeedBillboard(p, value)
	local speedBillboard = p.SpeedBillboard
	local model = p.Model

	if not (speedBillboard and model) then
		return
	end

	PetRigService.PinBillboard(speedBillboard, model, petSpeed, 3)

	if value then
		speedBillboard.Speed.Text = formatSpeed(value)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function MeasureHeightOffset(folder)
	return folder:GetPivot().Position.Y - visibleExtentsY(folder)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HeightOffsetFor(data)
	if not data.GrowthIntro then
		return data.HeightOffset
	end

	return MeasureHeightOffset(data.Model)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PivotYFor(data, p)
	local heightOffsetFor = HeightOffsetFor(data) -- equivalent call inferred; original call site unknown
	return p + heightOffsetFor + (not data.IsFlying and 0 or data.FlyHeight or 5)
end

function PetRenderer.PlayEffects(position)
	local clone = smoke:Clone()
	clone:PivotTo(CFrame.new(position))
	clone.Parent = workspace
	Effects:PlayVFX(clone)
	Debris:AddItem(clone, 3)
	local pop = SFX:FindFirstChild("Pop")

	if pop then
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Transparency = 1
		part.Size = createVector(1, 1, 1)
		part.Position = position
		part.Parent = workspace
		local clone2 = pop:Clone()
		clone2.Parent = part
		clone2:Play()
		Debris:AddItem(part, 3)
	end
end

function PetRenderer.Build(data)
	local v4 = data.OwnerUserId .. "::" .. data.PetKey

	if v2[v4] then
		PetRenderer.ApplyMutation(data.OwnerUserId, data.PetKey, data.Mutation)
		return v2[v4]
	end

	local folder = PetRigService.Build(data.PetName)

	if not folder then
		return nil
	end

	folder.Name = data.PetName

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = true
	end

	if not folder.PrimaryPart then
		folder.PrimaryPart = folder:FindFirstChildWhichIsA("BasePart", true)
	end

	local birthTime = tonumber(data.BirthTime)
	local baseWeight = tonumber(data.BaseWeight)
	local age = tonumber(data.Age) or 1

	if birthTime then
		age = PetAging.StateFrom(birthTime, nil, data)
	end

	local v5 = baseWeight and PetAging.WeightFor(baseWeight, age) or tonumber(data.Weight) or 10
	folder:AddTag("Pet")
	folder:SetAttribute("PetKey", data.PetKey)
	folder:SetAttribute("PetName", data.PetName)
	folder:SetAttribute("Weight", v5)
	folder:SetAttribute("Age", age)
	folder:SetAttribute("OwnerUserId", data.OwnerUserId)
	folder:SetAttribute("Mutation", data.Mutation)
	folder:SetAttribute("SpawnMutation", data.SpawnMutation)
	local scale = folder:GetScale()
	folder:ScaleTo((math.max(scale * (v5 / 10), scale * 0.01)))
	local data2 = folder:FindFirstChild("Data")
	local isFlying = data2 and data2:FindFirstChild("IsFlying")
	local PetRideModes = require(ReplicatedStorage.GameServices.PetRideModes)
	local speeds, v6 = PetRideModes.Speeds(folder)
	local isFlying2 = not (speeds and v6)

	if isFlying2 then
		if isFlying == nil then
			isFlying2 = false
		else
			isFlying2 = isFlying.Value == true
		end
	end

	if speeds and v6 then
		folder:SetAttribute("RideMode", "Walk")
	end

	local speed = data2 and data2:FindFirstChild("Speed")
	local baseRideSpeed

	if speed then
		baseRideSpeed = speed.Value or nil
	end

	local _, v8 = folder:GetBoundingBox()
	local heightOffset = MeasureHeightOffset(folder) -- equivalent call inferred; original call site unknown
	local pet = Pets[data.PetName]
	local mutationFactorFor = MutationFactorFor(data) -- equivalent call inferred; original call site unknown
	local v11 = {
		Model = folder,
		OwnerUserId = data.OwnerUserId,
		PetKey = data.PetKey,
		Mutation = data.Mutation,
		SpawnMutation = data.SpawnMutation,
		IsFlying = isFlying2,
		HeightOffset = heightOffset,
		Tracks = {},
		DisplayIncome = math.floor(math.floor((not pet and 0 or tonumber(pet.Income) or 0) * (v5 / PetAging.WeightStandardKG)) * mutationFactorFor),
		Income = math.floor(math.floor(math.floor((not pet and 0 or tonumber(pet.Income) or 0) * (v5 / PetAging.WeightStandardKG)) * mutationFactorFor) * CashMultiplierFor(data.OwnerUserId)),
		CollectTime = tonumber(data.CollectTime) or workspace:GetServerTimeNow(),
		BirthTime = birthTime,
		BaseWeight = baseWeight,
		BaseScale = scale,
		BaseIncome = not pet and 0 or tonumber(pet.Income) or 0,
		BaseRideSpeed = baseRideSpeed,
		CurrentAge = age,
		MoveSpeed = (baseRideSpeed or 6) * 0.5,
		SpeedReference = (baseRideSpeed or 6) * 0.5,
		DisplayedCash = 0,
		RollToken = 0,
		TouchRadius = v8.Magnitude / 2 + 4
	}

	if speed and baseRideSpeed then
		speed.Value = math.floor((PetAging.DisplaySpeedFor(baseRideSpeed, v5, mutationFactorFor)))
	end

	if data.Mutation then
		ApplyMutationAura(folder, data.Mutation) -- equivalent call inferred; original call site unknown
	end

	local ground = FindGround(data.Position)
	local X = data.Position.X
	folder:PivotTo(CFrame.new((Vector3.new(X, PivotYFor(v11, ground), data.Position.Z))))
	local playerByUserId = Players:GetPlayerByUserId(data.OwnerUserId)
	local plot = playerByUserId and General:GetPlot(playerByUserId)
	folder.Parent = plot and plot:FindFirstChild("Pets") or workspace
	v11.Culled = true
	v11.WantedTrack = "Idle"
	QueueWake(v11) -- equivalent call inferred; original call site unknown

	if folder.PrimaryPart and not isFlying2 then
		local footstepTemplates = GetFootstepTemplates(data.PetName)

		if footstepTemplates then
			v11.FootstepClips = EnsureWalkSounds(folder.PrimaryPart, footstepTemplates)
		end

		v11.FootstepLoop = folder.PrimaryPart:FindFirstChild("Footstep")
		v11.FootstepSpeedValue = data2 and data2:FindFirstChild("FootstepSpeed")
		v11.FootstepOverlapValue = data2 and data2:FindFirstChild("FootstepSoundOverlap")
	end

	if folder.PrimaryPart then
		local clone = petCash:Clone()
		clone.Adornee = folder.PrimaryPart
		clone.CashEarned.Text = "$0"
		clone.Income.Text = "$" .. PetRenderer.FormatCash(v11.DisplayIncome) .. "/s"
		clone.Parent = folder
		v11.Billboard = clone
		PetRigService.PinBillboard(clone, folder, petCash, -2)
	end

	if folder.PrimaryPart then
		local clone = petSpeed:Clone()
		clone.Adornee = folder.PrimaryPart
		clone.Parent = folder
		v11.SpeedBillboard = clone
		local speed2 = clone:FindFirstChild("Speed")
		local child = pet and pet.Rarity and rarityGradients:FindFirstChild(pet.Rarity)

		if speed2 and child then
			for _, uIGradient in speed2:GetChildren() do
				if uIGradient:IsA("UIGradient") then
					uIGradient:Destroy()
				end
			end

			local clone_2 = child:Clone()
			clone_2.Parent = speed2
		end

		if speed then
			baseRideSpeed = speed.Value or baseRideSpeed
		end

		RefreshSpeedBillboard(v11, baseRideSpeed) -- equivalent call inferred; original call site unknown
	end

	v2[v4] = v11
	local v13 = v3[v4]

	if v13 then
		PetRenderer.ApplyMutation(data.OwnerUserId, data.PetKey, v13.Mutation)
	end

	PetRenderer.Added:Fire(data.OwnerUserId, data.PetKey)

	if data.Effects then
		PetRenderer.PlayEffects(folder:GetPivot().Position)
	end

	return v11
end

function PetRenderer.RefreshSpeedBillboard(p, p2)
	local speedBillboard = p.SpeedBillboard
	local model = p.Model

	if speedBillboard then
		if not model then
			return
		end

		PetRigService.PinBillboard(speedBillboard, model, petSpeed, 3)

		if p2 then
			speedBillboard.Speed.Text = formatSpeed(p2)
		end
	end
end

function PetRenderer.Get(p, p2)
	return v2[p .. "::" .. p2]
end

function PetRenderer.GetAll()
	return v2
end

local function ApplyAge(state, currentAge)
	state.CurrentAge = currentAge
	local model = state.Model
	local v4 = state.BaseWeight and PetAging.WeightFor(state.BaseWeight, currentAge) or tonumber(model:GetAttribute("Weight")) or 10
	model:SetAttribute("Age", currentAge)
	model:SetAttribute("Weight", v4)
	pcall(function()
		local baseScale = state.BaseScale or 1
		model:ScaleTo((math.max(baseScale * (v4 / 10), baseScale * 0.01)))
	end)
	local _, v5 = model:GetBoundingBox()
	state.HeightOffset = MeasureHeightOffset(model)
	state.TouchRadius = v5.Magnitude / 2 + 4
	PetRigService.PinBillboard(state.Billboard, model, petCash, -2)
	local mutationFactorFor = MutationFactorFor(state) -- equivalent call inferred; original call site unknown
	state.MoveSpeed = (state.BaseRideSpeed or 6) * 0.5
	state.SpeedReference = (state.BaseRideSpeed or 6) * 0.5
	local displayIncome = math.floor(math.floor((state.BaseIncome or 0) * (v4 / PetAging.WeightStandardKG)) * mutationFactorFor)
	state.DisplayIncome = displayIncome
	state.Income = math.floor(displayIncome * CashMultiplierFor(state.OwnerUserId))
	local income = state.Billboard and state.Billboard:FindFirstChild("Income")

	if income then
		income.Text = "$" .. PetRenderer.FormatCash(displayIncome) .. "/s"
	end

	local data = model:FindFirstChild("Data")
	local speed = data and data:FindFirstChild("Speed")

	if speed and state.BaseRideSpeed then
		speed.Value = math.floor((PetAging.DisplaySpeedFor(state.BaseRideSpeed, v4, mutationFactorFor)))
	end

	local value = speed and speed.Value
	local speedBillboard = state.SpeedBillboard
	local model2 = state.Model

	if speedBillboard then
		if not model2 then
			return
		end

		PetRigService.PinBillboard(speedBillboard, model2, petSpeed, 3)

		if value then
			speedBillboard.Speed.Text = formatSpeed(value)
		end
	end
end

task.spawn(function()
	while true do
		task.wait(1)

		for _, v4 in pairs(v2) do
			if not v4.Model.Parent or v4.GrowthIntro then
				continue
			end

			if v4.BirthTime then
				local stateFrom = PetAging.StateFrom(v4.BirthTime, nil, v4)

				if stateFrom ~= v4.CurrentAge then
					ApplyAge(v4, stateFrom)
				end
			end

			local v5 = v4.BaseWeight and PetAging.WeightFor(v4.BaseWeight, v4.CurrentAge) or tonumber(v4.Model:GetAttribute("Weight")) or 10
			local displayIncome = math.floor(math.floor((v4.BaseIncome or 0) * (v5 / PetAging.WeightStandardKG)) * Mutations.CombinedFactor(
				v4.Mutation,
				v4.SpawnMutation
			))
			local income2 = math.floor(displayIncome * CashMultiplierFor(v4.OwnerUserId))

			if income2 == v4.Income then
				continue
			end

			v4.DisplayIncome = displayIncome
			v4.Income = income2
			local income = v4.Billboard and v4.Billboard:FindFirstChild("Income")

			if income then
				income.Text = "$" .. PetRenderer.FormatCash(displayIncome) .. "/s"
			end
		end
	end
end)

function PetRenderer.ApplyMutation(ownerUserId, p2, mutation)
	local v4 = ownerUserId .. "::" .. p2
	local v5 = v2[v4]
	local factorFor = Mutations.FactorFor(mutation)

	if v5 and v5.Model.Parent then
		v3[v4] = nil

		if factorFor <= Mutations.FactorFor(v5.Mutation) then
			return v5
		end

		v5.Mutation = mutation
		v5.Model:SetAttribute("Mutation", mutation)
		ApplyAge(v5, v5.CurrentAge)
		ApplyMutationAura(v5.Model, mutation) -- equivalent call inferred; original call site unknown
		return v5
	else
		local v6 = v3[v4]

		if Mutations.FactorFor(v6 and v6.Mutation) < factorFor then
			v3[v4] = {
				OwnerUserId = ownerUserId,
				Mutation = mutation
			}
		end

		return nil
	end
end

function PetRenderer.TemplateScaleFor(p)
	local template = PetRigService.GetTemplate(p)
	return template and template:GetScale() or nil
end

function PetRenderer.SnapTo(p, p2, p3)
	local v4 = v2[p .. "::" .. p2]

	if not (v4 and v4.Model.Parent) then
		return
	end

	if v4.Tween then
		v4.Tween:Cancel()
		v4.Tween = nil
	end

	if v4.Progress then
		v4.Progress:Destroy()
		v4.Progress = nil
	end

	local ground = FindGround(p3)
	local model = v4.Model
	local rotation = model:GetPivot().Rotation
	local X = p3.X
	model:PivotTo(rotation + Vector3.new(X, PivotYFor(v4, ground), p3.Z))
end

function PetRenderer.PauseMove(p, p2)
	local v4 = v2[p .. "::" .. p2]

	if not v4 or v4.Paused then
		return
	end

	v4.Paused = true

	if v4.Tween and v4.Tween.PlaybackState == Enum.PlaybackState.Playing then
		v4.Tween:Pause()
		v4.TweenWasPlaying = true
	end

	v4.WantedTrack = "Idle"

	if not v4.Culled then
		if not v4.Tracks then
			return
		end

		local idle = v4.Tracks.Idle
		local move = v4.Tracks.Move

		if move and move.IsPlaying then
			move:Stop(0.2)
		end

		if idle and not idle.IsPlaying then
			idle:Play(0.2)
		end
	end
end

function PetRenderer.ResumeMove(p, p2)
	local v4 = v2[p .. "::" .. p2]

	if not (v4 and v4.Paused) then
		return
	end

	v4.Paused = nil

	if v4.Tween and v4.TweenWasPlaying and v4.Tween.PlaybackState == Enum.PlaybackState.Paused then
		v4.Tween:Play()
		SetAnimation(v4, "Move", 0.2)
	end

	v4.TweenWasPlaying = nil
end

function PetRenderer.MoveTo(p, p2, p3, p4)
	local v4 = v2[p .. "::" .. p2]

	if not (v4 and v4.Model.Parent) then
		return
	end

	local model = v4.Model

	if v4.Tween then
		v4.Tween:Cancel()
		v4.Tween = nil
	end

	if v4.Progress then
		v4.Progress:Destroy()
		v4.Progress = nil
	end

	local pivot = model:GetPivot()
	local ground = FindGround(p3)
	local X = p3.X
	local vector2 = Vector3.new(X, PivotYFor(v4, ground), p3.Z)
	local magnitude = (vector2 - pivot.Position).Magnitude

	if magnitude < 0.5 then
		return
	end

	local v6 = (vector2 - pivot.Position) * createVector(1, 0, 1)
	local cframe

	if v6.Magnitude > 0.05 then
		cframe = CFrame.lookAt(vector2, vector2 + v6.Unit)
	else
		cframe = pivot.Rotation + vector2
	end

	local v7 = math.max(p4 or math.clamp(magnitude / (v4.MoveSpeed or 6), 0.4, 2.6), 0.05)
	local travelSpeed = magnitude / v7
	v4.TravelSpeed = travelSpeed
	v4.MoveRate = math.clamp(travelSpeed / (v4.SpeedReference or 6), 0.5, 3)

	if v4.Tracks.Move then
		v4.Tracks.Move:AdjustSpeed(v4.MoveRate)
	end

	SetAnimation(v4, "Move", 0.2)
	local v9 = math.clamp(0.25 / v7, 0.05, 1)
	local rotation = pivot.Rotation
	local rotation2 = cframe.Rotation
	local position = pivot.Position
	local numberValue = Instance.new("NumberValue")
	v4.Progress = numberValue
	numberValue.Changed:Connect(function(p5)
		if not model.Parent then
			return
		end

		if v4.Culled and p5 < 1 then
			local now = os.clock()

			if now < (v4.NextFarPivot or 0) then
				return
			else
				v4.NextFarPivot = now + 0.2
			end
		end

		model:PivotTo(rotation:Lerp(rotation2, (math.min(p5 / v9, 1))) + position:Lerp(vector2, p5))
		StepFootsteps(v4)
	end)
	local tween = TweenService:Create(numberValue, TweenInfo.new(v7, Enum.EasingStyle.Linear), {
		Value = 1
	})
	v4.Tween = tween
	tween.Completed:Connect(function(p5)
		if p5 ~= Enum.PlaybackState.Completed then
			return
		end

		v4.Tween = nil
		numberValue:Destroy()

		if v4.Progress == numberValue then
			v4.Progress = nil
		end

		StopFootsteps(v4) -- equivalent call inferred; original call site unknown
		v4.TravelSpeed = nil
		local v11 = v4
		v11.WantedTrack = "Idle"

		if not v11.Culled then
			if not v11.Tracks then
				return
			end

			local idle = v11.Tracks.Idle
			local move = v11.Tracks.Move

			if move and move.IsPlaying then
				move:Stop(0.2)
			end

			if idle and not idle.IsPlaying then
				idle:Play(0.2)
			end
		end
	end)
	tween:Play()
end

function PetRenderer.Remove(p, p2)
	local v4 = p .. "::" .. p2
	v3[v4] = nil
	local v5 = v2[v4]

	if not v5 then
		return
	end

	v2[v4] = nil

	if v5.Tween then
		v5.Tween:Cancel()
	end

	if v5.Progress then
		v5.Progress:Destroy()
	end

	v5.Model:Destroy()
	PetRenderer.Removed:Fire(p, p2)
end

function PetRenderer.RemoveAllFrom(p)
	for k, v4 in pairs(v3) do
		if v4.OwnerUserId == p then
			v3[k] = nil
		end
	end

	for _, v4 in pairs(v2) do
		if v4.OwnerUserId == p then
			PetRenderer.Remove(v4.OwnerUserId, v4.PetKey)
		end
	end
end

task.spawn(function()
	while true do
		task.wait(0.5)
		local cullOrigin = CullOrigin() -- equivalent call inferred; original call site unknown

		if not cullOrigin then
			continue
		end

		local v5 = {}

		for _, entry in pairs(v2) do
			local distance = RefreshCull(entry, cullOrigin)

			if distance then
				table.insert(v5, {
					Entry = entry,
					Distance = distance
				})
			end
		end

		table.sort(v5, function(a, b)
			return a.Distance < b.Distance
		end)
		local entries = {}

		for k, v6 in v5 do
			local entry = v6.Entry

			if entry.Culled then
				if k <= 60 then
					table.insert(entries, entry)
				end
			elseif k > 68 then
				entry.Culled = true
				StopTracks(entry)
			end
		end

		v = entries
	end
end)
RunService.Heartbeat:Connect(function()
	if #v == 0 then
		return
	end

	local cullOrigin = CullOrigin() -- equivalent call inferred; original call site unknown

	for _ = 1, 3 do
		local v5 = table.remove(v, 1)

		if not v5 then
			break
		end

		local model = v5.Model

		if not (v5.Culled and cullOrigin and model and model.Parent) then
			continue
		end

		if not ((model:GetPivot().Position - cullOrigin).Magnitude < 470) then
			continue
		end

		Wake(v5) -- equivalent call inferred; original call site unknown
	end
end)
return PetRenderer