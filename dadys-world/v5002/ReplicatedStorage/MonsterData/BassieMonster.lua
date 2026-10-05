local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local BassieMonster = {
	Name = "Twisted Bassie",
	Rarity = "MainCharacter",
	VisionRadius = 70,
	InstantRadius = 30,
	WalkSpeed = 10,
	RunSpeed = 19,
	InterestTime = 3,
	HearingRadius = 180,
	Damage = 1,
	WaitTime = 1,
	LineOfSight = 0.4,
	KillRadius = 4,
	HitCooldown = 2,
	UseBehaviorTree = true,
	LostInterestAnimationTime = 2.7,
	Trinket = "WhisperingFlower",
	Icon = "rbxassetid://126888077067126",
	Render = "rbxassetid://72150087781052",
	Description = "One of the Holiday Main Characters of Dandy's World. The fear of never living up to others' expectations has caused her to act out in desperation. When occupying a floor, this Twisted grows Ichor-drenched flowers that slow those too close to them, allowing Twisteds a better chance to catch their target. Watch out for her thorns.",
	HolidayTwisted = true,
	EasterTwisted = true,
	Holiday = true,
	Easter = true,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://82347462750315",
			NormalTexture = "rbxassetid://108243426201050",
			AttackTexture = "rbxassetid://76557809588530"
		}
	},
	WiltedFlowerPatches = {
		Count = 6,
		Size = createVector(5, 5, 5),
		SlowMultiplier = 0.5,
		InstanceRegistry = {}
	},
	SpecialBehavior = {
		DropDecoys = true,
		DecoyRadius = 35,
		DecoyDuration = 8,
		WiltedFlowerPatchesEnabled = true,
		WiltedFlowerPatchSize = createVector(5, 1, 5),
		WiltedFlowerSlowAmount = 0.5
	}
}

function BassieMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, BassieMonster.SpecialAnimatorData.Config)
end

local function CleanupWiltedFlowerPatches(instance)
	if not BassieMonster.WiltedFlowerPatches.InstanceRegistry[instance] then
		return
	end

	local ServerScriptService = game:GetService("ServerScriptService")
	local Players = game:GetService("Players")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local success, result = pcall(function()
		return require(ServerScriptService:FindFirstChild("ZoneModifierManager"))
	end)

	if not (success and result) then
		warn("Could not load ZoneModifierManager for cleanup")
		return
	end

	local success2, result2 = pcall(function()
		return require(ReplicatedStorage2.Modules.Gameplay.DebuffManager)
	end)

	if success2 and result2 then
		for _, v in ipairs(Players:GetPlayers()) do
			local character = v.Character

			if not (character and character.Parent) then
				continue
			end

			local wiltedFlower_ZoneCount = character:GetAttribute("WiltedFlower_ZoneCount")

			if not (wiltedFlower_ZoneCount and wiltedFlower_ZoneCount > 0) then
				continue
			end

			character:SetAttribute("WiltedFlower_ZoneCount", nil)
			result2.ClearPendingDebuffBySource(character, "Slow", "WiltedFlower")
			result2.ClearPendingDebuffBySource(character, "Tired", "WiltedFlower")
			result2.ClearPendingDebuffBySource(character, "Slow", "WiltedFlower_Linger")
			result2.ClearPendingDebuffBySource(character, "Tired", "WiltedFlower_Linger")
			local debuffInfo = result2.GetDebuffInfo(character, "Slow")

			if debuffInfo and (debuffInfo.source == "WiltedFlower" or debuffInfo.source == "WiltedFlower_Linger") then
				result2.RemoveDebuffCompletely(character, "Slow")
			end

			local debuffInfo2 = result2.GetDebuffInfo(character, "Tired")

			if debuffInfo2 and (debuffInfo2.source == "WiltedFlower" or debuffInfo2.source == "WiltedFlower_Linger") then
				result2.RemoveDebuffCompletely(character, "Tired")
			end

			print("BassieMonster: Cleaned up WiltedFlower debuffs from", character.Name)
		end
	end

	local v = BassieMonster.WiltedFlowerPatches.InstanceRegistry[instance]
	local activePatches = v.ActivePatches or {}

	for _, activePatch in ipairs(activePatches) do
		if activePatch and activePatch.Parent then
			result.RemoveZone(activePatch)
		end
	end

	local flowerMeshes = v.FlowerMeshes or {}

	for _, flowerMesh in ipairs(flowerMeshes) do
		if flowerMesh and flowerMesh.Parent then
			flowerMesh:Destroy()
		end
	end

	BassieMonster.WiltedFlowerPatches.InstanceRegistry[instance] = nil
	print("BassieMonster: Cleaned up wilted flower patches for", instance:GetFullName())
end

local function CreateWiltedFlowerPatches(instance)
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local ZonePlacementManager = require(ReplicatedStorage2.Modules.Zones.ZonePlacementManager)
	local currentRoom = workspace:FindFirstChild("CurrentRoom")

	if not currentRoom then
		return
	end

	local model = currentRoom:FindFirstChildOfClass("Model")

	if not model then
		return
	end

	local CollectionService = game:GetService("CollectionService")
	local v = {}
	local triggerZones = model:FindFirstChild("TriggerZones")

	if triggerZones and #triggerZones:GetChildren() > 0 then
		local v2 = {}

		for _, child in ipairs(triggerZones:GetChildren()) do
			if child.Name ~= "TriggerZone" then
				continue
			end

			local v3 = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart", true)

			if v3 and CollectionService:HasTag(v3, "Obstacle") then
				continue
			end

			local position

			if child:IsA("BasePart") then
				position = child.Position
			elseif child:IsA("Model") and child.PrimaryPart then
				position = child.PrimaryPart.Position
			else
				local basePart = child:FindFirstChildWhichIsA("BasePart", true)

				if not basePart then
					continue
				end

				position = basePart.Position
			end

			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = { child }
			local raycastResult = workspace:Raycast(
				position + createVector(0, 2, 0),
				createVector(0, -10, 0),
				raycastParams
			)

			if raycastResult and CollectionService:HasTag(raycastResult.Instance, "Floor") then
				table.insert(v2, raycastResult.Position)
			end
		end

		for i = #v2, 2, -1 do
			local v3 = math.random(1, i)
			local v4 = v2[v3]
			local v5 = v2[i]
			v2[i] = v4
			v2[v3] = v5
		end

		for i = 1, math.min(BassieMonster.WiltedFlowerPatches.Count, #v2) do
			table.insert(v, v2[i])
		end

		print("BassieMonster: Found", #v2, "valid TriggerZone positions, using", #v)
	end

	if #v == 0 then
		local monsterSpawnPoints = model:FindFirstChild("MonsterSpawnPoints") or model:FindFirstChild("BassieSpawnPoints") or model:FindFirstChild("ItemSpawnPoints")

		if not monsterSpawnPoints or #monsterSpawnPoints:GetChildren() == 0 then
			warn("BassieMonster: No spawn points or TriggerZones found for wilted flower patches")
			return
		end

		local children = monsterSpawnPoints:GetChildren()

		for _ = 1, BassieMonster.WiltedFlowerPatches.Count do
			table.insert(v, children[math.random(1, #children)].Position)
		end

		warn("BassieMonster: Using fallback MonsterSpawnPoints (no TriggerZones available)")
	end

	local zoneBatch = ZonePlacementManager.CreateZoneBatch(
		"WiltedFlowerZone",
		v,
		BassieMonster.WiltedFlowerPatches.Size,
		{
			searchRadius = 25,
			maxAttempts = 50,
			enforceSpacing = true
		}
	)
	local clones = {}
	local parts = ReplicatedStorage2:FindFirstChild("Parts")
	local flowerField = parts and parts:FindFirstChild("FlowerField")

	if flowerField then
		for _, v2 in ipairs(zoneBatch) do
			local v3 = v2
			pcall(function()
				local clone = flowerField:Clone()
				local v4 = v3.Position.Y - v3.Size.Y / 2
				local v5 = not clone.PrimaryPart and 0 or clone.PrimaryPart.Size.Y / 2 or 0
				local vector2 = Vector3.new(v3.Position.X, v4 + v5, v3.Position.Z)

				if clone:IsA("Model") and clone.PrimaryPart then
					clone:SetPrimaryPartCFrame(CFrame.new(vector2))
				elseif clone:IsA("BasePart") then
					clone.CFrame = CFrame.new(vector2)
					clone.Anchored = true
				end

				for i, part in ipairs(clone:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Anchored = true
					end
				end

				local triggerZone = clone:FindFirstChild("TriggerZone")

				if triggerZone then
					triggerZone.Transparency = 1
				end

				clone.Parent = model
				table.insert(clones, clone)
			end)
		end
	else
		warn("BassieMonster: FlowerField asset not found in ReplicatedStorage.Parts")
	end

	if not BassieMonster.WiltedFlowerPatches.InstanceRegistry[instance] then
		BassieMonster.WiltedFlowerPatches.InstanceRegistry[instance] = {}
	end

	BassieMonster.WiltedFlowerPatches.InstanceRegistry[instance].ActivePatches = zoneBatch
	BassieMonster.WiltedFlowerPatches.InstanceRegistry[instance].FlowerMeshes = clones
	print("BassieMonster: Created", #zoneBatch, "wilted flower patches with", #clones, "flower meshes")
end

local v = nil
pcall(function()
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local modules = ReplicatedStorage2:FindFirstChild("Modules")
	local data = modules and modules:FindFirstChild("Data")
	local bassieAbilityConfig = data and data:FindFirstChild("BassieAbilityConfig") or modules and modules:FindFirstChild("BassieAbilityConfig")

	if bassieAbilityConfig then
		local module = require(bassieAbilityConfig)
		v = module
	end
end)

if not v then
	warn("[Bassie] BassieAbilityConfig not found - running on hard-coded defaults; live tuning will not apply")
end

local function getConfig(p, p2)
	if v and v[p] ~= nil then
		return v[p]
	end

	return p2
end

BassieMonster.SpottedAbilityCooldown = 30
BassieMonster.SpottedAbilityChaseDelay = 2
BassieMonster.ChaseAbility = true
BassieMonster.AbilityCooldown = 30
BassieMonster.AbilityLineOfSight = true

local function PreloadAbilityAnimations(instance)
	local humanoid = instance:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local parent = humanoid:FindFirstChild("Animator")

	if not parent then
		parent = Instance.new("Animator")
		parent.Parent = humanoid
	end

	local animation = Instance.new("Animation")
	animation.Name = "_BassieAbilityStart"
	animation.AnimationId = (not v or v.BASSIE_ANIM_START == nil) and "rbxassetid://73403668322740" or v.BASSIE_ANIM_START
	animation.Parent = parent
	local animation2 = Instance.new("Animation")
	animation2.Name = "_BassieAbilityLoop"
	animation2.AnimationId = (not v or v.BASSIE_ANIM_LOOP == nil) and "rbxassetid://110743596890039" or v.BASSIE_ANIM_LOOP
	animation2.Parent = parent
	local animation3 = Instance.new("Animation")
	animation3.Name = "_BassieAbilityStop"
	animation3.AnimationId = (not v or v.BASSIE_ANIM_STOP == nil) and "rbxassetid://115150964648721" or v.BASSIE_ANIM_STOP
	animation3.Parent = parent
	parent:LoadAnimation(animation)
	parent:LoadAnimation(animation2)
	parent:LoadAnimation(animation3)
	pcall(function()
		local ContentProvider = game:GetService("ContentProvider")
		local v3 = {}

		for _, v4 in ipairs({ "FLOWER_EMERGE_ANIM", "THORN_EMERGE_ANIM" }) do
			local animationId = (not v or v[v4] == nil) and "" or v[v4]

			if animationId == "" then
				continue
			end

			local animation4 = Instance.new("Animation")
			animation4.AnimationId = animationId
			table.insert(v3, animation4)
		end

		for _, v4 in ipairs({
			"THORN_LOOP_ANIMS",
			"THORN_IDLE_ANIMS",
			"NEW_THORN_LOOP_ANIMS",
			"THICK_WHEELS_EMERGE_ANIMS",
			"THICK_WHEELS_IDLE_ANIMS",
			"THICK_WHEELS_WARNING_IDLE_ANIMS"
		}) do
			for _, animationId in ipairs((not v or v[v4] == nil) and {} or v[v4]) do
				local animation4 = Instance.new("Animation")
				animation4.AnimationId = animationId
				table.insert(v3, animation4)
			end
		end

		if #v3 > 0 then
			ContentProvider:PreloadAsync(v3)

			for _, v4 in ipairs(v3) do
				v4:Destroy()
			end
		end
	end)
	instance:SetAttribute("_BassieAnimsPreloaded", true)
	print("BassieMonster: Pre-loaded ability animations on spawn")
end

function BassieMonster.SpecialSetup(instance)
	CreateWiltedFlowerPatches(instance)
	instance:SetAttribute("HasWiltedFlowerPatches", true)
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local events = ReplicatedStorage2:FindFirstChild("Events")

	if events and not events:FindFirstChild("BassieVFX") then
		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = "BassieVFX"
		remoteEvent.Parent = events
	end

	local bassieVFX = events and events:FindFirstChild("BassieVFX")

	if bassieVFX then
		local vineEmergeSounds = (not v or v.VINE_EMERGE_SOUNDS == nil) and {} or v.VINE_EMERGE_SOUNDS
		local vineEmergeVol = (not v or v.VINE_EMERGE_VOLUME == nil) and 0.8 or v.VINE_EMERGE_VOLUME
		local thornSpikeSounds = (not v or v.THORN_SPIKE_SOUNDS == nil) and {} or v.THORN_SPIKE_SOUNDS
		local thornSpikeVol = (not v or v.THORN_SPIKE_VOLUME == nil) and 1 or v.THORN_SPIKE_VOLUME
		local color = Color3.fromRGB(
			(not v or v.SMOKE_COLOR_R == nil) and 15 or v.SMOKE_COLOR_R,
			(not v or v.SMOKE_COLOR_G == nil) and 5 or v.SMOKE_COLOR_G,
			(not v or v.SMOKE_COLOR_B == nil) and 15 or v.SMOKE_COLOR_B
		)
		local color2 = Color3.fromRGB(
			(not v or v.SMOKE_LIGHT_COLOR_R == nil) and 120 or v.SMOKE_LIGHT_COLOR_R,
			(not v or v.SMOKE_LIGHT_COLOR_G == nil) and 30 or v.SMOKE_LIGHT_COLOR_G,
			(not v or v.SMOKE_LIGHT_COLOR_B == nil) and 180 or v.SMOKE_LIGHT_COLOR_B
		)
		local color3 = Color3.fromRGB(
			(not v or v.DUST_COLOR_R == nil) and 180 or v.DUST_COLOR_R,
			(not v or v.DUST_COLOR_G == nil) and 150 or v.DUST_COLOR_G,
			(not v or v.DUST_COLOR_B == nil) and 100 or v.DUST_COLOR_B
		)
		local config = {
			vineScale = (not v or v.VINE_SCALE == nil) and 1 or v.VINE_SCALE,
			vineStage2Scale = (not v or v.VINE_STAGE2_SCALE == nil) and 1 or v.VINE_STAGE2_SCALE,
			sizeX = (not v or v.CHUNK_SIZE_X == nil) and 4 or v.CHUNK_SIZE_X,
			sizeY = (not v or v.CHUNK_SIZE_Y == nil) and 4 or v.CHUNK_SIZE_Y,
			sizeZ = (not v or v.CHUNK_SIZE_Z == nil) and 8 or v.CHUNK_SIZE_Z,
			groundOffset = (not v or v.CHUNK_GROUND_OFFSET == nil) and 1 or v.CHUNK_GROUND_OFFSET,
			VINE_FILL_CHUNK = not v or v.VINE_FILL_CHUNK == nil or v.VINE_FILL_CHUNK,
			VINE_SPAN_CHUNKS = (not v or v.VINE_SPAN_CHUNKS == nil) and 1 or v.VINE_SPAN_CHUNKS,
			VINE_STRETCH_Z = (not v or v.VINE_STRETCH_Z == nil) and 0 or v.VINE_STRETCH_Z
		}
		local v8

		if v and v.VINE_MIRROR ~= nil then
			v8 = v.VINE_MIRROR
		else
			v8 = false
		end

		config.VINE_MIRROR = v8
		config.VINE_ALIGN_TO_LINE = not v or v.VINE_ALIGN_TO_LINE == nil or v.VINE_ALIGN_TO_LINE
		config.VINE_EMERGE_SPEED = (not v or v.VINE_EMERGE_SPEED == nil) and 2 or v.VINE_EMERGE_SPEED
		config.VINE_EMERGE_BLEND_TIME = (not v or v.VINE_EMERGE_BLEND_TIME == nil) and 0.05 or v.VINE_EMERGE_BLEND_TIME
		config.THICK_WHEELS_EMERGE_ANIMS = (not v or v.THICK_WHEELS_EMERGE_ANIMS == nil) and {} or v.THICK_WHEELS_EMERGE_ANIMS
		config.THICK_WHEELS_IDLE_ANIMS = (not v or v.THICK_WHEELS_IDLE_ANIMS == nil) and {} or v.THICK_WHEELS_IDLE_ANIMS
		config.THICK_WHEELS_WARNING_IDLE_ANIMS = (not v or v.THICK_WHEELS_WARNING_IDLE_ANIMS == nil) and {} or v.THICK_WHEELS_WARNING_IDLE_ANIMS
		config.THORN_LOOP_ANIMS = (not v or v.THORN_LOOP_ANIMS == nil) and {} or v.THORN_LOOP_ANIMS
		config.THORN_IDLE_ANIMS = (not v or v.THORN_IDLE_ANIMS == nil) and {} or v.THORN_IDLE_ANIMS
		config.NEW_THORN_LOOP_ANIMS = (not v or v.NEW_THORN_LOOP_ANIMS == nil) and {} or v.NEW_THORN_LOOP_ANIMS
		config.NEW_THORN_IDLE_ANIMS = (not v or v.NEW_THORN_IDLE_ANIMS == nil) and {} or v.NEW_THORN_IDLE_ANIMS
		config.NEW_THORN_WARNING_IDLE_ANIMS = (not v or v.NEW_THORN_WARNING_IDLE_ANIMS == nil) and {} or v.NEW_THORN_WARNING_IDLE_ANIMS
		config.NEW_THORN_EMERGE_ANIMS = (not v or v.NEW_THORN_EMERGE_ANIMS == nil) and {} or v.NEW_THORN_EMERGE_ANIMS
		config.VINE_EMERGE_ANIMS = (not v or v.VINE_EMERGE_ANIMS == nil) and {} or v.VINE_EMERGE_ANIMS
		config.VINE_WARNING_IDLE_ANIMS = (not v or v.VINE_WARNING_IDLE_ANIMS == nil) and {} or v.VINE_WARNING_IDLE_ANIMS
		config.FLOWER_EMERGE_ANIM = (not v or v.FLOWER_EMERGE_ANIM == nil) and "" or v.FLOWER_EMERGE_ANIM
		config.THORN_EMERGE_ANIM = (not v or v.THORN_EMERGE_ANIM == nil) and "" or v.THORN_EMERGE_ANIM
		config.vineEmergeSounds = vineEmergeSounds
		config.vineEmergeVol = vineEmergeVol
		config.thornSpikeSounds = thornSpikeSounds
		config.thornSpikeVol = thornSpikeVol
		local smokeEnabled

		if v and v.SMOKE_ENABLED ~= nil then
			smokeEnabled = v.SMOKE_ENABLED
		else
			smokeEnabled = false
		end

		config.smokeEnabled = smokeEnabled
		config.smokeColor = color
		config.smokeSize = (not v or v.SMOKE_SIZE == nil) and 1.5 or v.SMOKE_SIZE
		config.smokeRiseVelocity = (not v or v.SMOKE_RISE_VELOCITY == nil) and 1.5 or v.SMOKE_RISE_VELOCITY
		config.smokeOpacity = (not v or v.SMOKE_OPACITY == nil) and 0.3 or v.SMOKE_OPACITY
		config.smokeLightColor = color2
		config.smokeLightBrightness = (not v or v.SMOKE_LIGHT_BRIGHTNESS == nil) and 1 or v.SMOKE_LIGHT_BRIGHTNESS
		config.smokeLightRange = (not v or v.SMOKE_LIGHT_RANGE == nil) and 6 or v.SMOKE_LIGHT_RANGE
		config.SMOKE_Y_OFFSET = (not v or v.SMOKE_Y_OFFSET == nil) and -2 or v.SMOKE_Y_OFFSET
		local dustEnabled

		if v and v.DUST_FLARE_ENABLED ~= nil then
			dustEnabled = v.DUST_FLARE_ENABLED
		else
			dustEnabled = false
		end

		config.dustEnabled = dustEnabled
		config.dustCount = (not v or v.DUST_FLARE_COUNT == nil) and 8 or v.DUST_FLARE_COUNT
		config.dustColor = color3
		config.dustYOffset = (not v or v.DUST_FLARE_Y_OFFSET == nil) and -1.5 or v.DUST_FLARE_Y_OFFSET
		config.dustSpeedMin = (not v or v.DUST_FLARE_SPEED_MIN == nil) and 2 or v.DUST_FLARE_SPEED_MIN
		config.dustSpeedMax = (not v or v.DUST_FLARE_SPEED_MAX == nil) and 8 or v.DUST_FLARE_SPEED_MAX
		config.dustLifeMin = (not v or v.DUST_FLARE_LIFETIME_MIN == nil) and 0.3 or v.DUST_FLARE_LIFETIME_MIN
		config.dustLifeMax = (not v or v.DUST_FLARE_LIFETIME_MAX == nil) and 0.8 or v.DUST_FLARE_LIFETIME_MAX
		config.dustSize = (not v or v.DUST_FLARE_SIZE == nil) and 1.5 or v.DUST_FLARE_SIZE
		local dustStage

		if v and v.DUST_FLARE_STAGE2 ~= nil then
			dustStage = v.DUST_FLARE_STAGE2
		else
			dustStage = false
		end

		config.dustStage2 = dustStage
		config.dustCountS2 = (not v or v.DUST_FLARE_COUNT_STAGE2 == nil) and 15 or v.DUST_FLARE_COUNT_STAGE2
		local ptclEnabled

		if v and v.PARTICLES_ENABLED ~= nil then
			ptclEnabled = v.PARTICLES_ENABLED
		else
			ptclEnabled = false
		end

		config.ptclEnabled = ptclEnabled
		config.ptclRate = (not v or v.PARTICLE_RATE == nil) and 20 or v.PARTICLE_RATE
		config.ptclLifeMin = (not v or v.PARTICLE_LIFETIME_MIN == nil) and 0.5 or v.PARTICLE_LIFETIME_MIN
		config.ptclLifeMax = (not v or v.PARTICLE_LIFETIME_MAX == nil) and 1.5 or v.PARTICLE_LIFETIME_MAX
		config.warnColor = Color3.fromRGB(
			(not v or v.WARN_COLOR_R == nil) and 0 or v.WARN_COLOR_R,
			(not v or v.WARN_COLOR_G == nil) and 220 or v.WARN_COLOR_G,
			(not v or v.WARN_COLOR_B == nil) and 80 or v.WARN_COLOR_B
		)
		config.VINE_S1_LINGER = (not v or v.VINE_S1_LINGER == nil) and 0.6 or v.VINE_S1_LINGER
		config.TRANSITION_POOF_DELAY = (not v or v.TRANSITION_POOF_DELAY == nil) and 0.5 or v.TRANSITION_POOF_DELAY
		config.poofEnabled = not v or v.TRANSITION_POOF_ENABLED == nil or v.TRANSITION_POOF_ENABLED
		bassieVFX:FireAllClients({
			action = "config",
			config = config,
			emergeTime = (not v or v.EMERGE_TWEEN_TIME == nil) and 0.2 or v.EMERGE_TWEEN_TIME
		})
		print("BassieMonster: Fired CONFIG VFX event to clients at spawn (one-time)")
	end

	task.spawn(function()
		local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
		local sharedData = ReplicatedStorage3:FindFirstChild("SharedData")
		local holidayEventConfig = sharedData and sharedData:FindFirstChild("HolidayEventConfig")
		local success, result = pcall(require, holidayEventConfig)

		if not success or not result or not result.ENABLED or result.ContentFlag ~= "Easter" then
			return
		end

		PreloadAbilityAnimations(instance)
	end)
	instance.AncestryChanged:Connect(function(_, parent)
		if not parent then
			CleanupWiltedFlowerPatches(instance)
		end
	end)
end

local flag = false
local v2 = {}
local v3 = nil
local v4 = nil
local v5 = nil

local function getCachedTemplates()
	if v3 then
		return v3, v4, v5
	end

	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local parts = ReplicatedStorage2:FindFirstChild("Parts")
	local v6 = not v or v.VINE_ENABLED == nil or v.VINE_ENABLED
	local children = {}
	local children2 = {}

	if v6 and parts then
		local child = parts:FindFirstChild((not v or v.VINE_FOLDER == nil) and "VinesAnimated" or v.VINE_FOLDER)

		if child then
			local v7 = (not v or v.VINE_STAGE1_PREFIX == nil) and "Small_Vines_Thick_Wheels" or v.VINE_STAGE1_PREFIX
			local v8 = (not v or v.VINE_STAGE1_PREFIX_2 == nil) and "" or v.VINE_STAGE1_PREFIX_2
			local v9 = (not v or v.VINE_STAGE1_PREFIX_3 == nil) and "" or v.VINE_STAGE1_PREFIX_3
			local v10 = (not v or v.VINE_STAGE2_PREFIX == nil) and "HugeSpike_Circular" or v.VINE_STAGE2_PREFIX

			for _, child2 in ipairs(child:GetChildren()) do
				if not (child2:IsA("Model") or child2:IsA("BasePart")) then
					continue
				end

				local name = child2.Name

				if string.sub(name, 1, #v7) == v7 then
					table.insert(children, child2)
				elseif v8 == "" or string.sub(name, 1, #v8) ~= v8 then
					if v9 == "" or string.sub(name, 1, #v9) ~= v9 then
						if string.sub(name, 1, #v10) == v10 then
							table.insert(children2, child2)
						end
					else
						table.insert(children, child2)
					end
				else
					table.insert(children, child2)
				end
			end
		end

		if #children == 0 and #children2 == 0 then
			v6 = false
		end
	end

	v3 = children
	v4 = children2
	v5 = v6
	return children, children2, v6
end

local function SpawnChunkAttack(instance, instance2, data)
	if flag then
		print("BassieMonster: Chunk attack already active, skipping")
		return
	end

	flag = true
	local Players = game:GetService("Players")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local TweenService = game:GetService("TweenService")
	local success, result = pcall(function()
		return require(ReplicatedStorage2.SharedModules.Character:FindFirstChild("DamageHandler"))
	end)

	if success and result then
		local v6 = (not v or v.CHUNK_COUNT == nil) and 15 or v.CHUNK_COUNT
		local v7 = (not v or v.OVERSHOOT_DISTANCE == nil) and 8 or v.OVERSHOOT_DISTANCE
		local v8 = (not v or v.CHUNK_SPAWN_DELAY == nil) and 0.01 or v.CHUNK_SPAWN_DELAY
		local v9 = (not v or v.EMERGE_TWEEN_TIME == nil) and 0.2 or v.EMERGE_TWEEN_TIME
		local v10 = (not v or v.SPIKE_TWEEN_TIME == nil) and 0.1 or v.SPIKE_TWEEN_TIME
		local v11 = (not v or v.CHUNK_SIZE_X == nil) and 4 or v.CHUNK_SIZE_X
		local v12 = (not v or v.CHUNK_SIZE_Y == nil) and 4 or v.CHUNK_SIZE_Y
		local v13 = (not v or v.CHUNK_SIZE_Z == nil) and 8 or v.CHUNK_SIZE_Z
		local v14 = (not v or v.CHUNK_TRANSPARENCY == nil) and 1 or v.CHUNK_TRANSPARENCY
		local v15

		if v and v.DEBUG_SHOW_HITBOX ~= nil then
			v15 = v.DEBUG_SHOW_HITBOX
		else
			v15 = false
		end

		local transparency = v15 and 0.7 or v14
		local v17 = (not v or v.CHUNK_GROUND_OFFSET == nil) and 1 or v.CHUNK_GROUND_OFFSET
		local v18 = (not v or v.STAGE1_DURATION == nil) and 0.75 or v.STAGE1_DURATION
		local v19 = (not v or v.STAGE2_DURATION == nil) and 0.15 or v.STAGE2_DURATION
		local color = Color3.fromRGB(
			(not v or v.WARN_COLOR_R == nil) and 0 or v.WARN_COLOR_R,
			(not v or v.WARN_COLOR_G == nil) and 220 or v.WARN_COLOR_G,
			(not v or v.WARN_COLOR_B == nil) and 80 or v.WARN_COLOR_B
		)
		local color2 = Color3.fromRGB(
			(not v or v.DAMAGE_COLOR_R == nil) and 220 or v.DAMAGE_COLOR_R,
			(not v or v.DAMAGE_COLOR_G == nil) and 50 or v.DAMAGE_COLOR_G,
			(not v or v.DAMAGE_COLOR_B == nil) and 50 or v.DAMAGE_COLOR_B
		)
		local CHUNK_MESH_ENABLED

		if v and v.CHUNK_MESH_ENABLED ~= nil then
			CHUNK_MESH_ENABLED = v.CHUNK_MESH_ENABLED
		else
			CHUNK_MESH_ENABLED = false
		end

		local v20 = (not v or v.CHUNK_MESH_NAME == nil) and "BassieChunkMesh" or v.CHUNK_MESH_NAME
		local PARTICLES_ENABLED

		if v and v.PARTICLES_ENABLED ~= nil then
			PARTICLES_ENABLED = v.PARTICLES_ENABLED
		else
			PARTICLES_ENABLED = false
		end

		local rate = (not v or v.PARTICLE_RATE == nil) and 20 or v.PARTICLE_RATE
		local v22 = (not v or v.PARTICLE_LIFETIME_MIN == nil) and 0.5 or v.PARTICLE_LIFETIME_MIN
		local v23 = (not v or v.PARTICLE_LIFETIME_MAX == nil) and 1.5 or v.PARTICLE_LIFETIME_MAX
		local v24 = not v or v.SOUNDS_ENABLED == nil or v.SOUNDS_ENABLED
		local volume = (not v or v.CHUNK_SOUND_VOLUME == nil) and 0.8 or v.CHUNK_SOUND_VOLUME
		local CollectionService = game:GetService("CollectionService")
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		local characters = { instance }

		for _, v26 in ipairs(Players:GetPlayers()) do
			if v26.Character then
				table.insert(characters, v26.Character)
			end
		end

		raycastParams.FilterDescendantsInstances = characters
		local v26 = (not v or v.PREDICTION_MAGNITUDE == nil) and 10 or v.PREDICTION_MAGNITUDE
		local v27 = (not v or v.CHUNK_GAP == nil) and 0 or v.CHUNK_GAP
		local v28 = (not v or v.SPREAD_ANGLE == nil) and 0 or v.SPREAD_ANGLE
		local v29 = (not v or v.DAMAGE_HEIGHT_GROW == nil) and 2 or v.DAMAGE_HEIGHT_GROW
		local v30 = (not v or v.SPREAD_SHAPE == nil) and "line" or v.SPREAD_SHAPE
		local v31 = (not v or v.CLUSTER_OFFSET == nil) and 2 or v.CLUSTER_OFFSET
		local v32 = (not v or v.CLUSTER_SPACING == nil) and 1 or v.CLUSTER_SPACING
		local REALTIME_TRACKING

		if v and v.REALTIME_TRACKING ~= nil then
			REALTIME_TRACKING = v.REALTIME_TRACKING
		else
			REALTIME_TRACKING = false
		end

		local v33 = not v or v.VINE_CLIP_THROUGH == nil or v.VINE_CLIP_THROUGH
		local VINE_OBSTACLE_CLIMB

		if v and v.VINE_OBSTACLE_CLIMB ~= nil then
			VINE_OBSTACLE_CLIMB = v.VINE_OBSTACLE_CLIMB
		else
			VINE_OBSTACLE_CLIMB = false
		end

		local v34 = (not v or v.VINE_CLIMB_MARGIN == nil) and 2 or v.VINE_CLIMB_MARGIN
		local v35 = (not v or v.VINE_CLIMB_STEP == nil) and 4 or v.VINE_CLIMB_STEP
		local v36 = (not v or v.VINE_CLIMB_MAX_HEIGHT == nil) and 40 or v.VINE_CLIMB_MAX_HEIGHT
		local parts = ReplicatedStorage2:FindFirstChild("Parts")
		local child = CHUNK_MESH_ENABLED and parts and parts:FindFirstChild(v20) or nil
		local cachedTemplates, v37, v38 = getCachedTemplates()
		local v39 = {}
		local attackId = instance.Name .. "_" .. tostring(tick())
		local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
		local events = ReplicatedStorage3:FindFirstChild("Events")
		local v41 = events and events:FindFirstChild("BassieVFX")

		if not v41 and events then
			v41 = Instance.new("RemoteEvent")
			v41.Name = "BassieVFX"
			v41.Parent = events
		end

		local v42 = {}

		if v41 then
			v41:FireAllClients({
				action = "attack_start",
				attackId = attackId
			})
			print("BassieMonster: Fired ATTACK_START VFX event to clients, attackId=" .. attackId)
		end

		local v43 = nil
		pcall(function()
			local DebuffManager = require(ReplicatedStorage2.Modules.Gameplay.DebuffManager)
			v43 = DebuffManager
		end)

		local function applySlowDebuff(character)
			local v44 = (not v or v.SLOW_DEBUFF_STRENGTH == nil) and 2 or v.SLOW_DEBUFF_STRENGTH
			local v45 = (not v or v.SLOW_DEBUFF_DURATION == nil) and 2 or v.SLOW_DEBUFF_DURATION

			if v43 and v43.ApplySlowness then
				v43.ApplySlowness(character, v44, v45, {
					allowRefreshOnEqual = true,
					source = "BassieChunkAttack"
				})
				return
			end

			local scripts = game.ServerStorage:FindFirstChild("Scripts")
			local debuffScript = scripts and scripts:FindFirstChild("DebuffScript")

			if not debuffScript then
				return
			end

			local clone = debuffScript:Clone()
			clone.DebuffType.Value = "Slow"
			clone.DebuffStrength.Value = v44
			clone.Duration.Value = v45
			clone.Parent = character
			clone.Disabled = false
		end

		local v44 = {}
		local zones = {}
		local v45 = {}
		local lastTime = os.clock()
		local v46 = false
		local v47 = (not v or v.SLOW_DETECT_PADDING == nil) and 4 or v.SLOW_DETECT_PADDING
		local HIGHLIGHT_ENABLED

		if v and v.HIGHLIGHT_ENABLED ~= nil then
			HIGHLIGHT_ENABLED = v.HIGHLIGHT_ENABLED
		else
			HIGHLIGHT_ENABLED = false
		end

		local color3 = Color3.fromRGB(
			(not v or v.HIGHLIGHT_FILL_COLOR_R == nil) and 220 or v.HIGHLIGHT_FILL_COLOR_R,
			(not v or v.HIGHLIGHT_FILL_COLOR_G == nil) and 30 or v.HIGHLIGHT_FILL_COLOR_G,
			(not v or v.HIGHLIGHT_FILL_COLOR_B == nil) and 30 or v.HIGHLIGHT_FILL_COLOR_B
		)
		local color4 = Color3.fromRGB(
			(not v or v.HIGHLIGHT_OUTLINE_COLOR_R == nil) and 255 or v.HIGHLIGHT_OUTLINE_COLOR_R,
			(not v or v.HIGHLIGHT_OUTLINE_COLOR_G == nil) and 0 or v.HIGHLIGHT_OUTLINE_COLOR_G,
			(not v or v.HIGHLIGHT_OUTLINE_COLOR_B == nil) and 0 or v.HIGHLIGHT_OUTLINE_COLOR_B
		)
		local fillTransparency = (not v or v.HIGHLIGHT_FILL_TRANSPARENCY == nil) and 0.6 or v.HIGHLIGHT_FILL_TRANSPARENCY
		local outlineTransparency = (not v or v.HIGHLIGHT_OUTLINE_TRANSPARENCY == nil) and 0.2 or v.HIGHLIGHT_OUTLINE_TRANSPARENCY
		local v50 = (not v or v.HIGHLIGHT_DEPTH_MODE == nil) and "AlwaysOnTop" or v.HIGHLIGHT_DEPTH_MODE
		local v51 = not v or v.HIGHLIGHT_BLINK == nil or v.HIGHLIGHT_BLINK
		local ServerScriptService = game:GetService("ServerScriptService")
		local success2, result2 = pcall(function()
			return require(ServerScriptService:FindFirstChild("ZoneModifierManager"))
		end)

		local function applyWarningHighlight(player, character)
			if not HIGHLIGHT_ENABLED or v45[player] then
				return
			end

			local bassieWarningHighlight = character:FindFirstChild("BassieWarningHighlight")

			if bassieWarningHighlight then
				bassieWarningHighlight:Destroy()
			end

			local highlight = Instance.new("Highlight")
			highlight.Name = "BassieWarningHighlight"
			highlight.FillColor = color3
			highlight.OutlineColor = color4
			highlight.FillTransparency = fillTransparency
			highlight.OutlineTransparency = outlineTransparency
			highlight.DepthMode = Enum.HighlightDepthMode[v50] or Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Adornee = character
			highlight.Parent = character
			v45[player] = highlight

			if v51 then
				task.spawn(function()
					while highlight and highlight.Parent do
						local v52 = os.clock() - lastTime
						local v53 = math.clamp(v52 / math.max(v18 + v8 * v6, 0.1), 0, 1)
						local v54 = 0.6 - v53 * 0.48
						local v55 = 0.95 - (0.95 - fillTransparency) * v53
						local v56 = 0.8 - (0.8 - outlineTransparency) * v53
						local midpoint = (math.sin(v52 % v54 / v54 * 3.141592653589793 * 2) + 1) / 2
						highlight.FillTransparency = v55 + (1 - v55) * (1 - midpoint)
						highlight.OutlineTransparency = v56 + (1 - v56) * (1 - midpoint)
						task.wait(0.03)
					end
				end)
			end

			print("BassieMonster: Warning highlight applied to", character.Name)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function removeWarningHighlight(p)
			local v52 = v45[p]

			if v52 and v52.Parent then
				v52:Destroy()
			end

			v45[p] = nil
		end

		if (not v or v.SLOW_DEBUFF_ENABLED == nil or v.SLOW_DEBUFF_ENABLED) and success2 and result2 then
			result2.DefineZoneType("BassieChunkSlowZone", {
				stats = {},
				targetType = "Toons",
				onPlayerEntered = function(player, _)
					local character = player.Character

					if not (character and character.Parent) then
						return
					end

					local humanoid = character:FindFirstChildOfClass("Humanoid")

					if not humanoid or humanoid.Health <= 0 then
						return
					end

					if character:GetAttribute("DebuffImmune") then
						local DebuffImmunityFeedback = require(ReplicatedStorage2.Modules.Gameplay.DebuffImmunityFeedback)
						DebuffImmunityFeedback.Notify(character, "BassieSlow")
					else
						applyWarningHighlight(player, character)

						if v44[player] then
							return
						end

						v44[player] = true
						applySlowDebuff(character)
						print("BassieMonster: Slow applied to", character.Name)
					end
				end,
				onPlayerExited = function(p, _)
					removeWarningHighlight(p) -- equivalent call inferred; original call site unknown
					v44[p] = nil
				end
			})
			v46 = true
		elseif HIGHLIGHT_ENABLED and success2 and result2 then
			result2.DefineZoneType("BassieChunkSlowZone", {
				stats = {},
				targetType = "Toons",
				onPlayerEntered = function(player, _)
					local character = player.Character

					if not (character and character.Parent) then
						return
					end

					local humanoid = character:FindFirstChildOfClass("Humanoid")

					if not humanoid or humanoid.Health <= 0 then
						return
					end

					applyWarningHighlight(player, character)
				end,
				onPlayerExited = function(p, _)
					removeWarningHighlight(p) -- equivalent call inferred; original call site unknown
				end
			})
			v46 = true
		end

		local function createSlowZoneForChunk(part)
			if not (v46 and part and part.Parent) then
				return
			end

			local vector2 = Vector3.new(part.Size.X + v47 * 2, part.Size.Y + 8, part.Size.Z + v47 * 2)
			local zone = result2.CreateZone("BassieChunkSlowZone", part.Position, vector2)

			if zone then
				table.insert(zones, zone)
			end
		end

		local function findGround(p, Y)
			local vector2 = Vector3.new(p.X, Y + 15, p.Z)
			local v52 = 60

			for _ = 1, 12 do
				local raycastResult = not (v52 <= 0) and workspace:Raycast(
					vector2,
					Vector3.new(0, -v52, 0),
					raycastParams
				)

				if not raycastResult then
					break
				end

				local instance3 = raycastResult.Instance
				local hasTag = CollectionService:HasTag(instance3, "Floor")
				local hasTag2 = CollectionService:HasTag(instance3, "Wall")

				if CollectionService:HasTag(instance3, "Obstacle") then
					if not v33 then
						return raycastResult.Position.Y, raycastResult.Normal, "Obstacle"
					end
				elseif (hasTag or hasTag2) and not hasTag2 then
					if not (raycastResult.Position.Y > data.Y + 10) then
						return raycastResult.Position.Y, raycastResult.Normal, nil
					end

					local Y2 = raycastResult.Position.Y
					vector2 = Vector3.new(p.X, Y2 - 0.1, p.Z)
					v52 -= vector2.Y - (Y2 - 0.1)
					warn("BassieMonster: findGround rejected ceiling hit at Y=" .. math.floor(raycastResult.Position.Y) .. " (startY=" .. math.floor(data.Y) .. ")")
					continue
				end

				local Y2 = raycastResult.Position.Y
				vector2 = Vector3.new(p.X, Y2 - 0.1, p.Z)
				v52 -= vector2.Y - (Y2 - 0.1)
			end

			local vector3 = Vector3.new(p.X, Y + 40, p.Z)
			local v53 = 80

			for _ = 1, 12 do
				local raycastResult = not (v53 <= 0) and workspace:Raycast(
					vector3,
					Vector3.new(0, -v53, 0),
					raycastParams
				)

				if not raycastResult then
					break
				end

				local instance3 = raycastResult.Instance
				local hasTag = CollectionService:HasTag(instance3, "Floor")
				local hasTag2 = CollectionService:HasTag(instance3, "Wall")

				if CollectionService:HasTag(instance3, "Obstacle") then
					if not v33 then
						return raycastResult.Position.Y, raycastResult.Normal, "Obstacle"
					end
				elseif (hasTag or hasTag2) and not hasTag2 and not (raycastResult.Position.Y > data.Y + 10) then
					return raycastResult.Position.Y, raycastResult.Normal, nil
				end

				local Y2 = raycastResult.Position.Y
				vector3 = Vector3.new(p.X, Y2 - 0.1, p.Z)
				v53 -= vector3.Y - (Y2 - 0.1)
			end

			return Y, createVector(0, 1, 0), nil
		end

		local v52 = {}
		local clones = {}
		local v53 = {}
		local v54 = {}
		local Y = data.Y
		local humanoidRootPart = instance2 and instance2:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			local v55 = math.max(v11, v13)
			local v56 = v55 / 2 + 1

			local function isNearWall(vector2, vector3)
				local cross = vector3:Cross(createVector(0, 1, 0))
				local v57 = not (cross.Magnitude > 0.01) and createVector(1, 0, 0) or cross.Unit
				local v58 = {
					vector3,
					-vector3,
					v57,
					-v57
				}

				for _, v59 in ipairs(v58) do
					local raycastResult = workspace:Raycast(vector2, v59 * v56, raycastParams)

					if raycastResult and (CollectionService:HasTag(raycastResult.Instance, "Wall") or CollectionService:HasTag(
						raycastResult.Instance,
						"Obstacle"
					)) then
						return true
					end
				end

				return false
			end

			local function spawnSingleChunk(data2, unit, chunkIndex, _, p2, climbPhase)
				local groundY, v58

				if p2 then
					groundY = p2
					v58 = createVector(0, 1, 0)
				else
					local v59
					groundY, v58, v59 = findGround(data2, Y)

					if not v59 then
						Y = groundY
					end

					if v59 then
						return nil
					end
				end

				local WALL_STOP_ENABLED = not v33

				if WALL_STOP_ENABLED then
					if v and v.WALL_STOP_ENABLED ~= nil then
						WALL_STOP_ENABLED = v.WALL_STOP_ENABLED
					else
						WALL_STOP_ENABLED = false
					end

					if not WALL_STOP_ENABLED then
						if v and v.WALL_SKIP_ENABLED ~= nil then
							WALL_STOP_ENABLED = v.WALL_SKIP_ENABLED
						else
							WALL_STOP_ENABLED = false
						end
					end
				end

				if WALL_STOP_ENABLED and not p2 and isNearWall(Vector3.new(data2.X, groundY + v12 / 2, data2.Z), unit) then
					local cross = unit:Cross(createVector(0, 1, 0))
					local v59 = not (cross.Magnitude > 0.01) and createVector(1, 0, 0) or cross.Unit
					local v60 = v55 * 1.2
					local v61 = false

					for _, v63 in ipairs({ 1, -1 }) do
						local vector3 = Vector3.new(data2.X + v59.X * v60 * v63, data2.Y, data2.Z + v59.Z * v60 * v63)
						local ground, v64, v65 = findGround(vector3, Y)

						if v65 or isNearWall(Vector3.new(vector3.X, ground + v12 / 2, vector3.Z), unit) then
							continue
						end

						v58 = v64
						groundY = ground
						data2 = vector3
						v61 = true
						break
					end

					if not v61 then
						return nil
					end
				end

				local vector2 = Vector3.new(data2.X, groundY + v12 / 2 + v17, data2.Z)
				local v59 = unit - v58 * unit:Dot(v58)
				local unit2

				if v59.Magnitude > 0.01 then
					unit2 = v59.Unit
				else
					unit2 = unit
				end

				local unit3 = unit2:Cross(v58).Unit
				local cframe = CFrame.fromMatrix(vector2, unit3, v58, -unit2)
				local part = Instance.new("Part")
				part.Name = "BassieChunk"
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
				part.Size = Vector3.new(v11, v12, v13)
				part.Color = color
				part.Transparency = transparency
				part.Material = Enum.Material.Neon
				part.CFrame = cframe * CFrame.new(0, -v12 * 1.5, 0)
				part.Parent = workspace
				TweenService:Create(part, TweenInfo.new(v9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					CFrame = cframe
				}):Play()

				if PARTICLES_ENABLED then
					local particleEmitter = Instance.new("ParticleEmitter")
					particleEmitter.Name = "BassieChunkParticles"
					particleEmitter.Color = ColorSequence.new(color)
					particleEmitter.Rate = rate
					particleEmitter.Lifetime = NumberRange.new(v22, v23)
					particleEmitter.Speed = NumberRange.new(2, 8)
					particleEmitter.SpreadAngle = Vector2.new(30, 30)
					particleEmitter.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1.5),
						NumberSequenceKeypoint.new(1, 0)
					})
					particleEmitter.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.2),
						NumberSequenceKeypoint.new(1, 1)
					})
					particleEmitter.LightEmission = 0.5
					particleEmitter.Parent = part
				end

				if v24 and chunkIndex == 1 then
					Audio:Play("Sounds.Twisted.Bassie.Chunk", {
						Volume = volume,
						RollOffMaxDistance = 80,
						Parent = part
					})
				end

				if child then
					pcall(function()
						local clone = child:Clone()

						if clone:IsA("Model") and clone.PrimaryPart then
							clone:SetPrimaryPartCFrame(cframe)
						elseif clone:IsA("BasePart") then
							clone.CFrame = cframe
							clone.Anchored = true
						end

						for _, part2 in ipairs(clone:GetDescendants()) do
							if not part2:IsA("BasePart") then
								continue
							end

							part2.Anchored = true
							part2.CanCollide = false
						end

						clone.Parent = workspace
						table.insert(clones, clone)
					end)
				end

				if v38 and #cachedTemplates > 0 then
					pcall(function()
						local cachedTemplate = cachedTemplates[math.random(1, #cachedTemplates)]
						local vector3 = Vector3.new(vector2.X, groundY + v17, vector2.Z)
						local v60 = not v or v.VINE_ALIGN_TO_LINE == nil or v.VINE_ALIGN_TO_LINE
						local cframe2

						if climbPhase == "ascend" then
							local vector4 = Vector3.new(unit.X, 0, unit.Z)
							local vector5 = vector4.Magnitude < 0.01 and createVector(1, 0, 0) or vector4.Unit
							local unit4 = vector5:Cross(createVector(0, 1, 0)).Unit
							cframe2 = CFrame.fromMatrix(vector3, unit4, vector5, createVector(-0, -1, -0))
						elseif climbPhase == "descend" then
							local vector4 = Vector3.new(unit.X, 0, unit.Z)
							local vector5 = vector4.Magnitude < 0.01 and createVector(1, 0, 0) or vector4.Unit
							local unit4 = vector5:Cross(createVector(0, 1, 0)).Unit
							cframe2 = CFrame.fromMatrix(vector3, unit4, -vector5, createVector(0, 1, 0))
						elseif v60 and unit then
							local v61 = vector3 + Vector3.new(unit.X, 0, unit.Z)
							cframe2 = CFrame.lookAt(vector3, v61)
						else
							cframe2 = CFrame.new(vector3) * CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
						end

						v39[chunkIndex] = {
							cframe = cframe2,
							templateName = cachedTemplate.Name
						}
						table.insert(v42, {
							vineCFrame = cframe2,
							groundY = groundY,
							templateName = cachedTemplate.Name,
							climbPhase = climbPhase,
							fwdDir = unit,
							chunkSize = Vector3.new(v11, v12, v13),
							chunkCFrame = cframe
						})

						if v41 then
							v41:FireAllClients({
								action = "chunk",
								attackId = attackId,
								chunkIndex = chunkIndex,
								vineCFrame = cframe2,
								groundY = groundY,
								templateName = cachedTemplate.Name,
								climbPhase = climbPhase,
								fwdDir = unit,
								chunkSize = Vector3.new(v11, v12, v13),
								chunkCFrame = cframe
							})
						end

						local v61 = (not v or v.VINE_EMERGE_SPEED == nil) and 2 or v.VINE_EMERGE_SPEED
						part:SetAttribute(
							"_vineAnimLen",
							((not v or v.VINE_EMERGE_ANIM_LENGTH == nil) and 0.5 or v.VINE_EMERGE_ANIM_LENGTH) / v61
						)
					end)
				end

				table.insert(v52, part)

				if not climbPhase then
					createSlowZoneForChunk(part)
				end

				return vector2
			end

			local position = humanoidRootPart.Position
			local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
			local vector2 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)

			if vector2.Magnitude > 1 then
				position += vector2.Unit * v26
			end

			local vector3 = Vector3.new(position.X - data.X, 0, position.Z - data.Z)
			local unit = vector3.Magnitude > 1 and vector3.Unit or createVector(1, 0, 0)

			if REALTIME_TRACKING then
				local humanoidRootPart2 = instance2 and instance2:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 then
					position = humanoidRootPart2.Position
				end

				local vector4 = Vector3.new(position.X - data.X, 0, position.Z - data.Z)
				local magnitude = vector4.Magnitude

				if magnitude > 1 then
					unit = vector4.Unit or unit
				end

				local v57 = math.max(magnitude / v6, v55) + v27
				local v58 = math.max(math.min(math.floor(magnitude / v57), v6 - 2), 1)
				print("BassieMonster: RT Phase A — bridge", v58, "chunks from Bassie to player")

				for i = 1, v58 do
					spawnSingleChunk(
						Vector3.new(data.X + unit.X * (v57 * i), data.Y, data.Z + unit.Z * (v57 * i)),
						unit,
						i,
						v6
					)

					if i < v58 then
						task.wait(v8)
					end
				end

				local v59 = (not v or v.RT_SPAWN_DELAY == nil) and 0.15 or v.RT_SPAWN_DELAY
				local vector5 = Vector3.new(data.X + unit.X * (v57 * v58), data.Y, data.Z + unit.Z * (v57 * v58))
				local v60 = v55 + v27
				local v61 = (not v or v.CLUSTER_COUNT == nil) and 6 or v.CLUSTER_COUNT
				local v62 = math.max(1, v6 - v58 - v61)
				print("BassieMonster: RT Phase B —", v62, "tracking +", v61, "cluster, shape=" .. v30)
				local unit2 = unit

				for i = 1, v62 do
					local humanoidRootPart3 = instance2 and instance2:FindFirstChild("HumanoidRootPart")
					local magnitude2 = 0

					if humanoidRootPart3 then
						local position2 = humanoidRootPart3.Position
						local assemblyLinearVelocity2 = humanoidRootPart3.AssemblyLinearVelocity
						local vector6 = Vector3.new(assemblyLinearVelocity2.X, 0, assemblyLinearVelocity2.Z)
						magnitude2 = vector6.Magnitude

						if magnitude2 > 2 then
							unit2 = vector6.Unit
						else
							local lookVector = humanoidRootPart3.CFrame.LookVector
							unit2 = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
						end

						local dot = unit:Dot(unit2)
						local v63 = v60 * (dot < 0.7 and 0.3 or dot < 0.85 and 0.6 or 1)
						vector5 = Vector3.new(position2.X, data.Y, position2.Z) + unit2 * v63

						if not v33 then
							local vector7 = Vector3.new(position2.X, data.Y + v12 / 2, position2.Z)
							local v64 = vector5 - Vector3.new(vector7.X, data.Y, vector7.Z)

							if v64.Magnitude > 0.5 then
								local raycastResult = workspace:Raycast(
									Vector3.new(vector7.X, vector7.Y, vector7.Z),
									Vector3.new(v64.X, 0, v64.Z),
									raycastParams
								)

								if raycastResult and (CollectionService:HasTag(raycastResult.Instance, "Wall") or CollectionService:HasTag(
									raycastResult.Instance,
									"Obstacle"
								)) then
									vector5 = Vector3.new(position2.X, data.Y, position2.Z) + unit2 * (v60 * 0.3)
									print("BassieMonster: RT track", i, "wall-validated, fell back to near-player pos")
								end
							end
						end

						unit = unit2
					else
						vector5 += unit2 * v60
					end

					spawnSingleChunk(vector5, unit2, v58 + i, v6 + v61)

					if not (i < v62) then
						continue
					end

					local dot = unit:Dot(unit2)
					local v63 = math.clamp(dot, 0.6, 1)
					local v64 = math.max(v59 * math.clamp(8 / math.max(magnitude2, 1), 0.2, 1) * v63, v8)
					print(
						"BassieMonster: RT track",
						i,
						"speed=" .. math.floor(magnitude2),
						"turnDot=" .. string.format("%.2f", dot),
						"delay=" .. string.format("%.3f", v64)
					)
					task.wait(v64)
				end

				local humanoidRootPart3 = instance2 and instance2:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart3 then
					local position2 = humanoidRootPart3.Position
					local assemblyLinearVelocity2 = humanoidRootPart3.AssemblyLinearVelocity
					local vector6 = Vector3.new(assemblyLinearVelocity2.X, 0, assemblyLinearVelocity2.Z)
					local unit3

					if vector6.Magnitude > 2 then
						unit3 = vector6.Unit
					else
						local lookVector = humanoidRootPart3.CFrame.LookVector
						unit3 = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
					end

					local dot = unit:Dot(unit3)
					local v63 = dot < 0.7 and 0.3 or dot < 0.85 and 0.6 or 1
					local v64 = v55 * math.min(v31, 1) * v63
					local v65 = Vector3.new(position2.X, data.Y, position2.Z) + unit3 * v64

					if not v33 then
						local vector7 = Vector3.new(position2.X, data.Y + v12 / 2, position2.Z)
						local v66 = v65 - Vector3.new(position2.X, data.Y, position2.Z)

						if v66.Magnitude > 0.5 then
							local raycastResult = workspace:Raycast(
								vector7,
								Vector3.new(v66.X, 0, v66.Z),
								raycastParams
							)

							if raycastResult and (CollectionService:HasTag(raycastResult.Instance, "Wall") or CollectionService:HasTag(
								raycastResult.Instance,
								"Obstacle"
							)) then
								v65 = Vector3.new(position2.X, data.Y, position2.Z) + unit3 * (v55 * 0.3)
								print("BassieMonster: cluster center wall-validated, fell back to near-player")
							end
						end
					end

					local v66 = v55 * v32
					local v67 = math.max(v55 * 0.8, v66)
					local v68 = {}

					if v30 == "line" then
						for i = 1, v61 do
							table.insert(v68, v65 + unit3 * (v66 * (i - 1)))
						end
					elseif v30 == "triangle" then
						local v69 = math.rad(math.max(v28, 30) / 2)
						local v70 = math.floor(v61 / 2)
						local v71 = math.max(v67 / math.max(v70, 1), v66)

						for i = -1, 1, 2 do
							local vectorToWorldSpace = CFrame.fromAxisAngle(createVector(0, 1, 0), v69 * i):VectorToWorldSpace(unit3)

							for i2 = 1, v70 do
								table.insert(v68, v65 + vectorToWorldSpace * (v71 * i2))
							end
						end

						if v61 % 2 == 1 then
							table.insert(v68, v65 + unit3 * v67)
						end
					elseif v30 == "circle" then
						if 6.283185307179586 * v67 < v61 * v66 then
							v67 = v61 * v66 / 6.283185307179586
						end

						for i = 1, v61 do
							local v69 = (i - 1) / v61 * 3.141592653589793 * 2
							local vector7 = Vector3.new(math.cos(v69) * v67, 0, math.sin(v69) * v67)
							table.insert(v68, (Vector3.new(v65.X + vector7.X, data.Y, v65.Z + vector7.Z)))
						end
					elseif v30 == "square" then
						local v69 = math.max(v67 * 8 / v61, v66)
						local v70 = {
							Vector3.new(-v67, 0, -v67),
							Vector3.new(v67, 0, -v67),
							Vector3.new(v67, 0, v67),
							(Vector3.new(-v67, 0, v67))
						}
						local count = 0

						for i = 1, 4 do
							local v71 = v70[i]
							local v72 = v70[i % 4 + 1]
							local magnitude2 = (v72 - v71).Magnitude
							local unit4 = (v72 - v71).Unit
							local total = 0

							while total < magnitude2 and count < v61 do
								table.insert(
									v68,
									(Vector3.new(
										v65.X + v71.X + unit4.X * total,
										data.Y,
										v65.Z + v71.Z + unit4.Z * total
									))
								)
								count += 1
								total += v69
							end
						end
					end

					for i, v69 in ipairs(v68) do
						spawnSingleChunk(v69, unit3, v58 + v62 + i, v6)

						if i < #v68 then
							task.wait(v8)
						end
					end
				else
					for i = 1, v61 do
						spawnSingleChunk(vector5 + unit2 * (v60 * i), unit2, v58 + v62 + i, v6)

						if i < v61 then
							task.wait(v8)
						end
					end
				end

				print("BassieMonster: RT mode, Shape='" .. v30 .. "', spawned=" .. #v52)
			else
				local WALL_STOP_ENABLED

				if v and v.WALL_STOP_ENABLED ~= nil then
					WALL_STOP_ENABLED = v.WALL_STOP_ENABLED
				else
					WALL_STOP_ENABLED = false
				end

				local v57 = position + unit * v7
				local vector4 = Vector3.new(v57.X - data.X, 0, v57.Z - data.Z)

				if vector4.Magnitude < 1 then
					flag = false

					if instance and instance.Parent then
						instance:SetAttribute("_BassieChunkAttackDone", true)
					end

					return
				else
					local unit2 = vector4.Unit
					local v58 = math.max(vector4.Magnitude / v6, v55) + v27
					local v59 = {}

					for i = 1, v6 do
						table.insert(v59, Vector3.new(data.X, data.Y, data.Z) + unit2 * (v58 * i))
					end

					if v30 ~= "line" then
						local v60 = position + unit * (v55 * v31)
						local vector5 = Vector3.new(v60.X, data.Y, v60.Z)
						local v61 = math.max(4, (math.floor(v6 * 0.6)))
						local v62 = math.max(v7 * 0.5, 6)
						local v63 = v55 * v32

						if v30 == "triangle" then
							local v64 = math.rad(math.max(v28, 30) / 2)
							local v65 = math.floor(v61 / 2)
							local v66 = math.max(v62 / math.max(v65, 1), v63)

							for i = -1, 1, 2 do
								local vectorToWorldSpace = CFrame.fromAxisAngle(createVector(0, 1, 0), v64 * i):VectorToWorldSpace(unit)

								for i2 = 1, v65 do
									local v67 = vector5 + vectorToWorldSpace * (v66 * i2)
									table.insert(v59, (Vector3.new(v67.X, data.Y, v67.Z)))
								end
							end

							if v61 % 2 == 1 then
								table.insert(v59, Vector3.new(vector5.X, data.Y, vector5.Z) + unit * v62)
							end
						elseif v30 == "circle" then
							if 6.283185307179586 * v62 < v61 * v63 then
								v62 = v61 * v63 / 6.283185307179586
							end

							for i = 1, v61 do
								local v64 = (i - 1) / v61 * 3.141592653589793 * 2
								local vector6 = Vector3.new(math.cos(v64) * v62, 0, math.sin(v64) * v62)
								table.insert(v59, (Vector3.new(vector5.X + vector6.X, data.Y, vector5.Z + vector6.Z)))
							end
						elseif v30 == "square" then
							local v64 = math.max(v62 * 8 / v61, v63)
							local v65 = {
								Vector3.new(-v62, 0, -v62),
								Vector3.new(v62, 0, -v62),
								Vector3.new(v62, 0, v62),
								(Vector3.new(-v62, 0, v62))
							}
							local count = 0

							for i = 1, 4 do
								local v66 = v65[i]
								local v67 = v65[i % 4 + 1]
								local magnitude = (v67 - v66).Magnitude
								local unit3 = (v67 - v66).Unit
								local total = 0

								while total < magnitude and count < v61 do
									table.insert(
										v59,
										(Vector3.new(
											vector5.X + v66.X + unit3.X * total,
											data.Y,
											vector5.Z + v66.Z + unit3.Z * total
										))
									)
									count += 1
									total += v64
								end
							end
						end
					end

					print("BassieMonster: Static mode, Shape='" .. v30 .. "', line=" .. v6 .. ", total=" .. #v59)
					local WALL_SKIP_ENABLED

					if v and v.WALL_SKIP_ENABLED ~= nil then
						WALL_SKIP_ENABLED = v.WALL_SKIP_ENABLED
					else
						WALL_SKIP_ENABLED = false
					end

					local v60 = (not v or v.WALL_SKIP_MAX == nil) and 2 or v.WALL_SKIP_MAX
					local v61 = 0
					local count = 0

					for i, v63 in ipairs(v59) do
						if (VINE_OBSTACLE_CLIMB or not v33 and WALL_STOP_ENABLED) and v61 <= 0 then
							local vector5 = Vector3.new(data.X, data.Y + v12 / 2, data.Z)
							local vector6 = Vector3.new(v63.X - data.X, 0, v63.Z - data.Z)

							if vector6.Magnitude > 0.5 then
								local raycastResult = workspace:Raycast(vector5, vector6, raycastParams)

								if raycastResult and (CollectionService:HasTag(raycastResult.Instance, "Wall") or CollectionService:HasTag(
									raycastResult.Instance,
									"Obstacle"
								)) then
									if VINE_OBSTACLE_CLIMB then
										local position2 = raycastResult.Position
										local unit3 = vector6.Unit
										local v64 = Y
										local v65 = position2.X + unit3.X * 0.5
										local v66 = position2.Z + unit3.Z * 0.5
										local Y2 = position2.Y

										for i2 = 1, math.ceil(v36 / v35) do
											Y2 = v64 + i2 * v35
											local raycastResult2 = workspace:Raycast(
												Vector3.new(v65, Y2 + 1, v66),
												createVector(0, -2, 0),
												raycastParams
											)

											if raycastResult2 and (CollectionService:HasTag(
												raycastResult2.Instance,
												"Wall"
											) or CollectionService:HasTag(raycastResult2.Instance, "Obstacle")) then
												Y2 += v35
											else
												break
											end
										end

										local v67 = Y2 + v34
										print(
											"BassieMonster: Climbing obstacle at chunk",
											i,
											"- top:",
											math.floor(Y2),
											"climbY:",
											(math.floor(v67))
										)
										local v68 = not v or v.VINE_CLIMB_MUD == nil or v.VINE_CLIMB_MUD
										local color5 = Color3.fromRGB(
											(not v or v.VINE_CLIMB_MUD_COLOR_R == nil) and 60 or v.VINE_CLIMB_MUD_COLOR_R,
											(not v or v.VINE_CLIMB_MUD_COLOR_G == nil) and 40 or v.VINE_CLIMB_MUD_COLOR_G,
											(not v or v.VINE_CLIMB_MUD_COLOR_B == nil) and 30 or v.VINE_CLIMB_MUD_COLOR_B
										)
										local v69 = {}

										if v68 then
											local model = raycastResult.Instance:FindFirstAncestorOfClass("Model")

											if model then
												for _, part in ipairs(model:GetDescendants()) do
													if not (part:IsA("MeshPart") and (part.Position - position2).Magnitude <= 12) then
														continue
													end

													table.insert(v69, {
														part = part,
														origMaterial = part.Material,
														origColor = part.Color
													})
													part.Material = Enum.Material.Mud
													part.Color = color5
												end
											end

											for _, v70 in ipairs(v69) do
												table.insert(v54, v70)
											end

											if #v69 > 0 then
												print("BassieMonster: Changed", #v69, "MeshParts to Mud in", model.Name)
											end
										end

										local v70 = position2.X + unit3.X * v11
										local v71 = position2.Z + unit3.Z * v11

										for i2 = 1, 6 do
											v70 = position2.X + unit3.X * (v11 * i2)
											v71 = position2.Z + unit3.Z * (v11 * i2)
											local raycastResult2 = workspace:Raycast(
												Vector3.new(v70, v67 + 2, v71),
												Vector3.new(0, -(v67 - v64 + 4), 0),
												raycastParams
											)

											if raycastResult2 and (CollectionService:HasTag(
												raycastResult2.Instance,
												"Wall"
											) or CollectionService:HasTag(raycastResult2.Instance, "Obstacle")) then
												v70 += unit3.X * v11
												v71 += unit3.Z * v11
											else
												break
											end
										end

										local v72 = #v52 + 1
										local v73 = position2.X - unit3.X * (v11 * 0.3)
										local v74 = position2.Z - unit3.Z * (v11 * 0.3)
										local v75 = v64

										while v75 < v67 do
											v75 = math.min(v75 + v35, v67)
											count += 1
											spawnSingleChunk(
												Vector3.new(v73, 0, v74),
												unit,
												#v59 + count,
												#v59 + count,
												v75 - v12 / 2,
												"ascend"
											)
											task.wait(v8)
										end

										local v76 = math.sqrt((v70 - v73) ^ 2 + (v71 - v74) ^ 2)
										local v77 = math.max(1, (math.ceil(v76 / v11)))

										for i2 = 1, v77 do
											local v78 = i2 / v77
											local v79 = v73 + unit3.X * v76 * v78
											local v80 = v74 + unit3.Z * v76 * v78
											count += 1
											spawnSingleChunk(
												Vector3.new(v79, 0, v80),
												unit,
												#v59 + count,
												#v59 + count,
												v67 - v12 / 2,
												"traverse"
											)
											task.wait(v8)
										end

										local ground, _, v78 = findGround(Vector3.new(v70, 0, v71), Y)

										if v78 then
											ground = v64
										end

										while ground < v67 do
											v67 = math.max(v67 - v35, ground)
											count += 1
											spawnSingleChunk(
												Vector3.new(v70, 0, v71),
												unit,
												#v59 + count,
												#v59 + count,
												v67 - v12 / 2,
												"descend"
											)
											task.wait(v8)
										end

										Y = ground
										Vector3.new(v70, ground, v71)

										for i2 = v72, #v52 do
											v53[i2] = true
										end

										print(
											"BassieMonster: Climb complete at chunk",
											i,
											"-",
											count,
											"climb chunks, marked",
											#v52 - v72 + 1,
											"for stage2 skip"
										)
										spawnSingleChunk(v63, unit, i, #v59)
										data = v63
										continue
									elseif WALL_SKIP_ENABLED then
										print("BassieMonster: Wall at chunk", i, "- skipping up to", v60, "chunks")
										v61 = v60
									else
										if VINE_OBSTACLE_CLIMB then
											local position2 = raycastResult.Position
											local unit3 = vector6.Unit
											local v64 = position2.X - unit3.X * (v11 * 0.3)
											local v65 = position2.Z - unit3.Z * (v11 * 0.3)
											local v66 = Y
											local v67 = #v59 - i + 1
											local v68 = #v52 + 1
											print(
												"BassieMonster: Vine overgrowth at wall, chunk",
												i,
												"-",
												v67,
												"chunks going vertical"
											)

											for _ = 1, v67 do
												v66 += v35

												if v36 < v66 - Y then
													break
												end

												count += 1
												spawnSingleChunk(
													Vector3.new(v64, 0, v65),
													unit,
													#v59 + count,
													#v59 + count,
													v66 - v12 / 2,
													"ascend"
												)
												task.wait(v8)
											end

											for i2 = v68, #v52 do
												v53[i2] = true
											end
										else
											print("BassieMonster: Wall-stop at chunk", i, "- hard stop")
										end

										break
									end
								end
							end
						end

						if v61 > 0 then
							v61 -= 1

							if v61 == 0 then
								local _, _, v64 = findGround(v63, Y)

								if v64 then
									print("BassieMonster: No floor after wall skip at chunk", i, "- stopping line")
									break
								else
									print("BassieMonster: Floor confirmed after wall skip, resuming at chunk", i)
								end
							end
						else
							spawnSingleChunk(v63, unit, i, #v59)
							print("BassieMonster: Chunk", i, "/", #v59)
						end

						local v64 = (not v or v.VINE_EMERGE_WAIT_PERCENT == nil) and 0.5 or v.VINE_EMERGE_WAIT_PERCENT

						if v64 > 0 and #v52 > 0 then
							local v65 = v52[#v52]
							local _vineAnimLen = v65 and v65:GetAttribute("_vineAnimLen")

							if _vineAnimLen and _vineAnimLen > 0 then
								local v66 = _vineAnimLen * v64

								if v8 < v66 then
									task.wait(v66)
								elseif i < #v59 then
									task.wait(v8)
								end

								data = v63
								continue
							end
						end

						if i < #v59 then
							task.wait(v8)
						end

						data = v63
					end
				end
			end

			task.wait(v9)
			print("BassieMonster:", #v52, "chunks spawned")

			if #v52 == 0 then
				for _, v57 in ipairs(v54) do
					if not (v57.part and v57.part.Parent) then
						continue
					end

					v57.part.Material = v57.origMaterial
					v57.part.Color = v57.origColor
				end
			else
				local stage2TemplateIndex

				if #v37 > 1 then
					stage2TemplateIndex = (instance:GetAttribute("_BassieStage2Index") or 0) % #v37 + 1
					instance:SetAttribute("_BassieStage2Index", stage2TemplateIndex)
				else
					stage2TemplateIndex = 1
				end

				print("BassieMonster: All", #v52, "chunks spawned, VFX events sent per-chunk")
				print("BassieMonster: Stage 1 — chunks:", #v52, ", slow zones:", #zones)

				if #v52 > 0 then
					local _vineAnimLen = v52[#v52]:GetAttribute("_vineAnimLen")

					if _vineAnimLen and _vineAnimLen > 0 then
						task.wait(_vineAnimLen)
					end
				end

				local v58 = (not v or v.WARNING_IDLE_DURATION == nil) and 0.5 or v.WARNING_IDLE_DURATION
				local v59 = (not v or v.VINE_WARNING_IDLE_ANIMS == nil) and {} or v.VINE_WARNING_IDLE_ANIMS
				local v60 = (not v or v.NEW_THORN_WARNING_IDLE_ANIMS == nil) and {} or v.NEW_THORN_WARNING_IDLE_ANIMS
				local v61 = (not v or v.THICK_WHEELS_WARNING_IDLE_ANIMS == nil) and {} or v.THICK_WHEELS_WARNING_IDLE_ANIMS
				local v62 = #v59 > 0 or #v60 > 0 or #v61 > 0

				if v58 > 0 and v62 then
					print("BassieMonster: Warning phase —", v58, "s before stage 2")

					if v41 then
						v41:FireAllClients({
							action = "warning",
							attackId = attackId
						})
					end

					task.wait(v58)
				else
					task.wait(v18)
				end

				for _, v63 in ipairs(zones) do
					if not (v63 and v63.Parent) then
						continue
					end

					local v64 = v63
					pcall(function()
						result2.RemoveZone(v64)
					end)
				end

				zones = {}

				for _, v63 in pairs(v45) do
					if v63 and v63.Parent then
						v63:Destroy()
					end
				end

				v45 = {}
				local v63 = not v or v.HITBOX_ENABLED == nil or v.HITBOX_ENABLED
				local stage2ChunkDelay = (not v or v.STAGE2_CHUNK_DELAY == nil) and 0.11 or v.STAGE2_CHUNK_DELAY
				print("BassieMonster: Stage 2 — sequential damage phase, hitbox=" .. tostring(v63) .. ", chunkDelay=" .. stage2ChunkDelay .. "s, holdTime=" .. v19 .. "s")
				local v65 = {}
				local zones2 = {}

				if v63 and success2 and result2 then
					result2.DefineZoneType("BassieChunkZone", {
						stats = {},
						targetType = "Toons",
						onPlayerEntered = function(player, _)
							if v65[player] then
								return
							end

							local character = player.Character

							if not (character and character.Parent) then
								return
							end

							local humanoid = character:FindFirstChildOfClass("Humanoid")

							if not humanoid or humanoid.Health <= 0 then
								return
							end

							v65[player] = true
							local success3, result3 = pcall(function()
								result.handleDamage(character, 1, "Twisted Bassie", 0, {
									monster = instance
								})
							end)

							if success3 then
								print("BassieMonster: Zone damaged", character.Name)
							else
								warn("BassieMonster: Zone damage failed -", result3)
							end
						end
					})
				end

				if v41 then
					v41:FireAllClients({
						action = "stage2",
						attackId = attackId,
						chunkCount = #v52,
						stage2ChunkDelay = stage2ChunkDelay,
						stage2TemplateIndex = stage2TemplateIndex
					})
					print("BassieMonster: Fired single STAGE2 VFX event, chunkCount=" .. #v52 .. ", delay=" .. stage2ChunkDelay)
				end

				for i, v66 in ipairs(v52) do
					if not (v66 and v66.Parent) then
						continue
					end

					if v53[i] then
						v66:Destroy()

						if i < #v52 and not v53[i + 1] then
							task.wait(stage2ChunkDelay)
						end
					else
						v66.Color = color2
						local bassieChunkParticles = v66:FindFirstChild("BassieChunkParticles")

						if bassieChunkParticles then
							bassieChunkParticles.Color = ColorSequence.new(color2)
						end

						local v67 = v66.Size.Y + v29
						TweenService:Create(v66, TweenInfo.new(v10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Size = Vector3.new(v66.Size.X, v67, v66.Size.Z),
							CFrame = v66.CFrame * CFrame.new(0, v29 / 2, 0)
						}):Play()
						v66:SetAttribute(
							"_thornAnimLen",
							(not v or v.THORN_ANIM_DURATION_ESTIMATE == nil) and 1 or v.THORN_ANIM_DURATION_ESTIMATE
						)

						if v63 and success2 and result2 then
							local vector4 = Vector3.new(v66.Size.X, v67 + 4, v66.Size.Z)
							local _thornAnimLen = v66:GetAttribute("_thornAnimLen")

							if _thornAnimLen and _thornAnimLen > 0 then
								local v68 = v66
								local position2 = v66.Position
								local v70 = vector4
								local v71 = _thornAnimLen
								task.delay(0.5, function()
									if not (v68 and v68.Parent) then
										return
									end

									local zone = result2.CreateZone("BassieChunkZone", position2, v70)

									if zone then
										table.insert(zones2, zone)
										task.delay(math.max(v71 - 0.5, 0.1), function()
											if zone and zone.Parent then
												pcall(function()
													result2.RemoveZone(zone)
												end)
											end
										end)
									end
								end)
							end
						end

						if i < #v52 then
							task.wait(stage2ChunkDelay)
						end
					end
				end

				task.wait(v19)

				for _, v66 in ipairs(zones2) do
					if not (v66 and v66.Parent) then
						continue
					end

					local v67 = v66
					pcall(function()
						result2.RemoveZone(v67)
					end)
				end

				if v41 then
					v41:FireAllClients({
						action = "cleanup",
						attackId = attackId,
						sinkTime = 0.4,
						sinkDistance = 8
					})
				end

				for _, v66 in ipairs(v52) do
					if not (v66 and v66.Parent) then
						continue
					end

					local v67 = v66
					pcall(function()
						TweenService:Create(v67, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							CFrame = v67.CFrame * CFrame.new(0, -8, 0),
							Transparency = 1
						}):Play()
					end)
				end

				task.wait(0.5)

				for _, v66 in ipairs(v52) do
					if v66 and v66.Parent then
						v66:Destroy()
					end
				end

				for _, v66 in ipairs(clones) do
					if v66 and v66.Parent then
						v66:Destroy()
					end
				end

				for _, v66 in ipairs(zones2) do
					if not (v66 and v66.Parent) then
						continue
					end

					local v67 = v66
					pcall(function()
						result2.RemoveZone(v67)
					end)
				end

				if v54 then
					for _, v66 in ipairs(v54) do
						if not (v66.part and v66.part.Parent) then
							continue
						end

						v66.part.Material = v66.origMaterial
						v66.part.Color = v66.origColor
					end
				end

				flag = false

				if instance and instance.Parent then
					instance:SetAttribute("_BassieChunkAttackDone", true)
				end

				print("BassieMonster: Chunk attack cleaned up")
				return
			end
		end

		flag = false

		if instance and instance.Parent then
			instance:SetAttribute("_BassieChunkAttackDone", true)
		end
	else
		warn("BassieMonster: Could not load DamageHandler")
		flag = false

		if instance and instance.Parent then
			instance:SetAttribute("_BassieChunkAttackDone", true)
		end
	end
end

function BassieMonster.UseSpottedAbility(instance, instance2)
	local CollectionService = game:GetService("CollectionService")

	if not CollectionService:HasTag(instance, "TwistedBassie") then
		CollectionService:AddTag(instance, "TwistedBassie")
	end

	if instance:GetAttribute("_MonsterAbilityFrozen") then
		print("BassieMonster: Already mid-ability, ignoring duplicate call")
		return
	end

	local now = tick()
	local v6 = now - (instance:GetAttribute("_BassieLastSpotted") or 0)
	local spottedAbilityCooldown = BassieMonster.SpottedAbilityCooldown

	if v and v.COOLDOWN ~= nil then
		spottedAbilityCooldown = v.COOLDOWN
	end

	if v6 < spottedAbilityCooldown or not (instance and instance.Parent) then
		return
	end

	if not (instance2 and instance2.Parent) then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart2) then
		return
	end

	local v7 = (not v or v.ABILITY_RANGE == nil) and 66 or v.ABILITY_RANGE
	local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

	if v7 < magnitude then
		print("BassieMonster: Target too far for chunk attack (" .. math.floor(magnitude) .. " studs), skipping")
		return
	end

	instance:SetAttribute("_MonsterAbilityFrozen", true)
	instance:SetAttribute("_MonsterAbilityFrozenAt", os.clock())
	instance:SetAttribute("_BassieLastSpotted", now)
	local humanoid = instance:FindFirstChild("Humanoid")
	local MonsterFreeze = nil
	pcall(function()
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		MonsterFreeze = require(ReplicatedStorage2.MonsterModules:FindFirstChild("MonsterFreeze"))
	end)
	local frozen

	if MonsterFreeze then
		frozen = MonsterFreeze.Freeze(instance) or nil
	end

	if not frozen then
		warn("BassieMonster: MonsterFreeze failed — ability may not hold position")
		instance:SetAttribute("_MonsterAbilityFrozen", true)
	end

	if MonsterFreeze and frozen and humanoidRootPart2 then
		MonsterFreeze.FaceTarget(frozen, humanoidRootPart2.Position)
	elseif humanoidRootPart2 then
		humanoidRootPart.CFrame = CFrame.lookAt(
			humanoidRootPart.Position,
			(Vector3.new(humanoidRootPart2.Position.X, humanoidRootPart.Position.Y, humanoidRootPart2.Position.Z))
		)
	end

	print("BassieMonster: Frozen for ability")
	instance:SetAttribute("_BassieChunkAttackDone", nil)
	local success, result = pcall(function()
		if humanoid then
			local parent = humanoid:FindFirstChild("Animator")

			if not parent then
				parent = Instance.new("Animator")
				parent.Parent = humanoid
			end

			for _, v9 in ipairs(parent:GetPlayingAnimationTracks()) do
				v9:Stop(0)
			end

			local v9 = parent:FindFirstChild("_BassieAbilityStart")

			if not v9 then
				v9 = Instance.new("Animation")
				v9.Name = "_BassieAbilityStart"
				v9.AnimationId = (not v or v.BASSIE_ANIM_START == nil) and "rbxassetid://73403668322740" or v.BASSIE_ANIM_START
				v9.Parent = parent
			end

			local v10 = parent:FindFirstChild("_BassieAbilityLoop")

			if not v10 then
				v10 = Instance.new("Animation")
				v10.Name = "_BassieAbilityLoop"
				v10.AnimationId = (not v or v.BASSIE_ANIM_LOOP == nil) and "rbxassetid://110743596890039" or v.BASSIE_ANIM_LOOP
				v10.Parent = parent
			end

			local v11 = parent:FindFirstChild("_BassieAbilityStop")

			if not v11 then
				v11 = Instance.new("Animation")
				v11.Name = "_BassieAbilityStop"
				v11.AnimationId = (not v or v.BASSIE_ANIM_STOP == nil) and "rbxassetid://115150964648721" or v.BASSIE_ANIM_STOP
				v11.Parent = parent
			end

			local track = parent:LoadAnimation(v9)
			track.Looped = false
			track.Priority = Enum.AnimationPriority.Action4
			local track2 = parent:LoadAnimation(v10)
			track2.Looped = true
			track2.Priority = Enum.AnimationPriority.Action4
			local track3 = parent:LoadAnimation(v11)
			track3.Looped = false
			track3.Priority = Enum.AnimationPriority.Action4
			track:GetMarkerReachedSignal("StartLoop"):Once(function()
				if instance and instance.Parent and not instance:GetAttribute("_BassieChunkAttackDone") then
					track2:Play(0.1, 1, 1)
					print("BassieMonster: StartLoop marker → Loop animation started")
				end
			end)
			track.Stopped:Once(function()
				if not track2.IsPlaying and instance and instance.Parent and not instance:GetAttribute("_BassieChunkAttackDone") then
					track2:Play(0.1, 1, 1)
					print("BassieMonster: Start animation ended (no marker) → Loop animation started")
				end
			end)
			track:Play(0, 1, 1)
			print("BassieMonster: Ability Start animation playing")
			Audio:Play("Sounds.Twisted.Bassie.ArmSmash", {
				Volume = (not v or v.ARM_SMASH_VOLUME == nil) and 1.2 or v.ARM_SMASH_VOLUME,
				RollOffMaxDistance = 100,
				Parent = humanoidRootPart
			})
			local v12 = (not v or v.WIND_UP_DURATION == nil) and 0.7 or v.WIND_UP_DURATION

			if v12 > 0 then
				task.wait(v12)
			end

			print(
				"BassieMonster: Launching chunk attack toward",
				instance2.Name,
				"(" .. math.floor(magnitude) .. " studs)"
			)
			task.spawn(SpawnChunkAttack, instance, instance2, humanoidRootPart.Position)
			local lastTime = tick()

			while instance and instance.Parent and not instance:GetAttribute("_BassieChunkAttackDone") and humanoidRootPart and humanoidRootPart.Parent do
				if tick() - lastTime > 20 then
					warn("BassieMonster: Hold loop timed out after", 20, "s — forcing unfreeze")
					break
				else
					task.wait(0.15)
				end
			end

			flag = false

			if instance and instance.Parent then
				if track.IsPlaying then
					track:Stop(0)
				end

				if track2.IsPlaying then
					track2:Stop(0.2)
				end

				track3:Play(0.15, 1, 1)
				print("BassieMonster: StopLoop → Stop animation playing, Bassie recovering")
				local v13 = false
				track3.Stopped:Once(function()
					v13 = true
				end)
				local lastTime2 = tick()

				while not v13 and tick() - lastTime2 < 3 do
					task.wait(0.1)
				end

				if not v13 then
					warn("BassieMonster: Stop animation timed out — forcing unfreeze")
				end

				track3:Stop(0.3)
				task.wait(0.35)
				print("BassieMonster: Stop animation finished, Bassie unfrozen")
			end
		else
			print("BassieMonster: No animator, launching chunk attack directly")
			task.spawn(SpawnChunkAttack, instance, instance2, humanoidRootPart.Position)
			local lastTime = tick()

			while instance and instance.Parent and not instance:GetAttribute("_BassieChunkAttackDone") do
				if tick() - lastTime > 20 then
					warn("BassieMonster: Hold loop timed out after", 20, "s — forcing unfreeze")
					break
				else
					task.wait(0.15)
				end
			end

			flag = false
		end
	end)

	if not success then
		warn("BassieMonster: UseSpottedAbility error (Unfreeze will still run):", result)
		flag = false
	end

	if MonsterFreeze and frozen then
		local success2, result2 = pcall(MonsterFreeze.Unfreeze, frozen)

		if not success2 then
			warn("BassieMonster: Unfreeze error:", result2)
		end
	end

	if instance and instance.Parent then
		instance:SetAttribute("_MonsterAbilityFrozen", nil)
	end

	if instance and instance.Parent then
		instance:SetAttribute("_MonsterAbilityFrozenAt", nil)
		instance:SetAttribute("_BassieChunkAttackDone", nil)
	end

	print("BassieMonster: Unfrozen, AI resuming")
	local humanoid2 = instance2 and instance2:FindFirstChild("Humanoid")
	local v8 = instance2 and instance2.Parent and humanoid2 and humanoid2.Health > 0

	if v8 then
		if instance and instance.Parent then
			local chasingValue = instance:FindFirstChild("ChasingValue")

			if chasingValue and not chasingValue.Value then
				chasingValue.Value = instance2
				print("BassieMonster: Restored ChasingValue →", instance2.Name)
			end
		end
	else
		local chasingValue = instance and instance.Parent and instance:FindFirstChild("ChasingValue")

		if chasingValue then
			chasingValue.Value = nil
		end

		warn("BassieMonster: Target died during ability — skipping chase restore")
	end

	local v9 = (not v or v.POST_ABILITY_GRACE == nil) and 5 or v.POST_ABILITY_GRACE

	if v9 > 0 and instance and instance.Parent and v8 then
		if v2[instance] then
			task.cancel(v2[instance])
			v2[instance] = nil
		end

		instance:SetAttribute("_BassieChaseGrace", true)
		print("BassieMonster: Grace period started (" .. v9 .. "s) — no lost interest")
		v2[instance] = task.delay(v9, function()
			v2[instance] = nil

			if instance and instance.Parent then
				instance:SetAttribute("_BassieChaseGrace", nil)
				print("BassieMonster: Grace period ended — lost interest re-enabled")
			end
		end)
	end
end

function BassieMonster.UseChaseAbility(instance, p)
	BassieMonster.UseSpottedAbility(instance, p)

	if instance and instance.Parent and p and p.Parent then
		local AINew = nil
		pcall(function()
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			AINew = require(ReplicatedStorage2.Forbidden:FindFirstChild("AINew"))
		end)

		if AINew then
			local chasingValue = instance:FindFirstChild("ChasingValue")

			if chasingValue then
				chasingValue.Value = p
			end

			AINew.SmartPathfind(instance, p, false, {
				Tracking = true
			})
			print("BassieMonster: Restarted pathfinding after chase ability")
		end
	end
end

function BassieMonster.TestSpawnChunkAttack(p, position, instance)
	local dummyBassie = workspace:FindFirstChild("DummyBassie")
	local v6 = dummyBassie or Instance.new("Model")

	if not dummyBassie then
		v6.Name = "BassieTestFx"
		v6.Parent = workspace
	end

	local model

	if instance and instance:FindFirstChild("HumanoidRootPart") then
		model = nil
	else
		local part = Instance.new("Part")
		part.Name = "HumanoidRootPart"
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.Position = position
		model = Instance.new("Model")
		model.Name = "BassieTestTarget"
		part.Parent = model
		model.Parent = workspace
		instance = model
	end

	task.spawn(function()
		SpawnChunkAttack(v6, instance, p)

		if model then
			model:Destroy()
		end

		if not dummyBassie and v6 and v6.Parent then
			v6:Destroy()
		end
	end)
end

return BassieMonster