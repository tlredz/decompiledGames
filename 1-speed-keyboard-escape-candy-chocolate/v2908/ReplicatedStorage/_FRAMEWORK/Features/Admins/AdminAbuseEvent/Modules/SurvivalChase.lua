local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Config = require(script.Config)
local RewardBar = require(script.RewardBar)
require(script.Types)
local Catch = require(script.Catch)
local Chaser = require(script.Chaser)
local Collision = require(script.Collision)
local Rewards = require(script.Rewards)
local Zone = require(script.Zone)
local parentModule = require(script.Parent.Parent)
local AdminAbuseUtils = require(script.Parent.Parent.AdminAbuseUtils)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})

local function findHostMap()
	for _, host in Config.hosts do
		local map = AdminAbuseUtils.Map.getMap(host.mapLiveName)

		if map then
			return host, map
		end
	end

	return nil, nil
end

local function isHostModuleActive()
	for _, v in parentModule.getActiveStates() do
		for _, host in Config.hosts do
			if v.slot == "main" and v.name == host.moduleName then
				return true
			end
		end
	end

	return false
end

local function checkCanStart()
	local flag = true
	local v

	for _, host in Config.hosts do
		v = AdminAbuseUtils.Map.getMap(host.mapLiveName)

		if not v then
			continue
		end

		flag = false
		break
	end

	if flag then
		v = nil
	end

	if isHostModuleActive() or v ~= nil then
		return true, nil
	end

	return false, "A host admin abuse must be active before starting Survival Chase (see SurvivalChase/Config.hosts)"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isHostMapLoaded(p, instance, seenClock: number, seenClock2: number)
	if p.mapLoadedAttribute then
		return instance:GetAttribute(p.mapLoadedAttribute) == true
	end

	return seenClock2 - seenClock >= Config.mapSettleSec
end

local function buildServerRuntime(data)
	local DataManager = require(ServerScriptService.DataManager)
	local Config2 = require(ReplicatedStorage.Config)
	local BoostsManager = require(ServerScriptService.BoostsManager)
	local BonusManager = require(ReplicatedStorage.BonusManager)
	local AABossNpcs = require(ServerScriptService.Server.AdminAbuseServerModules.AABossNpcs)
	local v = {
		seenMap = nil,
		seenClock = 0,
		session = nil,
		fallbackZoneFolder = nil,
		zoneBoxes = {},
		floorRaycastParams = Zone.buildFloorRaycastParams(),
		catchOverlapParams = Catch.buildOverlapParams(),
		slots = {},
		slotsByNpc = {},
		rewards = {},
		lastPollClock = 0,
		lastTickClock = 0,
		waitStartedClock = os.clock(),
		warnedTimeout = false
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function showWin(player, p: number)
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local showWin2

		if remotes then
			showWin2 = remotes:FindFirstChild("ShowWin")
		end

		if showWin2 and showWin2:IsA("RemoteEvent") then
			showWin2:FireClient(player, p)
		end
	end

	local function awardSurvivalWin(player, survivedSeconds: number)
		local v2 = DataManager.LevelCache[player.UserId] or 1
		local v3 = math.max(
			1,
			(math.ceil(Rewards.getTierWins(Config2.DEPRECATED_BOSS_WIN_TIERS, v2) / Config.rewardAwardDivisor))
		)
		local v4 = BoostsManager:HasWinsBoost(player) and 2 or 1
		local winsMultiplier = BonusManager:GetWinsMultiplier(player)
		local streakMultiplier = Rewards.getStreakMultiplier(survivedSeconds)
		local v5 = math.ceil(v3 * v4 * winsMultiplier * streakMultiplier)
		DataManager:IncrementStat(player, "Wins", v5, {
			source = Config.rewardSource
		})
		showWin(player, v5) -- equivalent call inferred; original call site unknown
		data.FireServerEventToPlayer(player, { "SurvivalWin", v5, streakMultiplier })
	end

	local function stepRewards(p: number)
		Rewards.pruneDisconnected(v.rewards)

		for _, v2 in Players:GetPlayers() do
			local reward = v.rewards[v2]

			if reward == nil then
				reward = Rewards.newState()
				v.rewards[v2] = reward
			end

			if Rewards.step(reward, v2, v.zoneBoxes, p, true) then
				awardSurvivalWin(v2, reward.survivedSeconds)
			end
		end
	end

	local function getReferenceSpeed(p)
		local parent = p.Parent
		local playerFromCharacter

		if parent then
			playerFromCharacter = Players:GetPlayerFromCharacter(parent)
		end

		local humanoid

		if parent then
			humanoid = parent:FindFirstChildOfClass("Humanoid")
		end

		if playerFromCharacter and humanoid and humanoid.WalkSpeed > 0 then
			return humanoid.WalkSpeed
		end

		return Config.chaserFallbackWalkSpeed
	end

	local function isRootAlive(p)
		local parent = p.Parent
		local humanoid

		if parent then
			humanoid = parent:FindFirstChildOfClass("Humanoid")
		end

		return humanoid ~= nil and humanoid.Health > 0
	end

	local function pickRandomTargetRoot()
		local humanoidRootParts = {}
		local humanoidRootParts2 = {}

		for _, v2 in Players:GetPlayers() do
			local character = v2.Character
			local humanoid

			if character then
				humanoid = character:FindFirstChildOfClass("Humanoid")
			end

			local humanoidRootPart

			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if not (humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				continue
			end

			table.insert(humanoidRootParts, humanoidRootPart)

			if Zone.isInside(v.zoneBoxes, humanoidRootPart.Position) then
				table.insert(humanoidRootParts2, humanoidRootPart)
			end
		end

		if #humanoidRootParts2 > 0 then
			humanoidRootParts = humanoidRootParts2
		end

		if #humanoidRootParts > 0 then
			return humanoidRootParts[math.random(1, #humanoidRootParts)]
		end

		return nil
	end

	local function resolveSlotTargetRoot(p, p2)
		local v2 = v.slotsByNpc[p]

		if not v2 then
			return p2
		end

		local now = os.clock()
		local targetRoot = v2.targetRoot

		if targetRoot == nil or targetRoot.Parent == nil or v2.targetExpiresClock <= now then
			v2.targetRoot = pickRandomTargetRoot()
			v2.targetExpiresClock = now + Config.targetHoldSec
		else
			local parent = targetRoot.Parent
			local humanoid

			if parent then
				humanoid = parent:FindFirstChildOfClass("Humanoid")
			end

			local v3

			if humanoid == nil then
				v3 = false
			else
				v3 = humanoid.Health > 0
			end

			if not v3 then
				v2.targetRoot = pickRandomTargetRoot()
				v2.targetExpiresClock = now + Config.targetHoldSec
			end
		end

		return v2.targetRoot or p2
	end

	local function resolveChaserWalkSpeed(p, p2)
		local parent = resolveSlotTargetRoot(p, p2).Parent
		local playerFromCharacter

		if parent then
			playerFromCharacter = Players:GetPlayerFromCharacter(parent)
		end

		local humanoid

		if parent then
			humanoid = parent:FindFirstChildOfClass("Humanoid")
		end

		local v2

		if playerFromCharacter and humanoid and humanoid.WalkSpeed > 0 then
			v2 = humanoid.WalkSpeed
		else
			v2 = Config.chaserFallbackWalkSpeed
		end

		return v2 + Config.chaserSpeedBonus
	end

	local function resolveChaserDestination(instance, p)
		local v2 = v.slotsByNpc[instance]
		local v3 = not v2 and 1 or v2.scale
		local slotTargetRoot = resolveSlotTargetRoot(instance, p)
		local position = instance:GetPivot().Position
		local clamped = Zone.clamp(v.zoneBoxes, slotTargetRoot.Position, v3)
		local clamped2

		if v2 then
			clamped2 = Zone.clamp(
				v.zoneBoxes,
				Chaser.applyMoveNoise(v2.noiseSeed, position, slotTargetRoot.Position, v3),
				v3
			)
		else
			clamped2 = clamped
		end

		if Zone.hasFloorBelow(v.floorRaycastParams, clamped2, v3) then
			return clamped2
		end

		if Zone.hasFloorBelow(v.floorRaycastParams, clamped, v3) then
			return clamped
		end

		return position
	end

	local function refreshFloorRaycastFilter()
		local npcs = {}

		for _, slot in v.slots do
			if slot.npc then
				table.insert(npcs, slot.npc)
			end
		end

		v.floorRaycastParams.FilterDescendantsInstances = npcs
	end

	local function spawnChaser(object, slot, lastSpawnClock: number)
		slot.lastSpawnClock = lastSpawnClock

		if slot.npc then
			v.slotsByNpc[slot.npc] = nil
		end

		slot.npc = object:spawnNpc({
			source = "template",
			templateModel = slot.template,
			archetypeId = Config.chaserArchetypeId,
			scale = Chaser.getScale(slot.template),
			walkSpeed = Config.chaserFallbackWalkSpeed,
			instantKill = false,
			damage = 0,
			showHighlight = Config.chaserShowHighlight,
			namePrefix = Config.chaserArchetypeId
		}, slot.spawnCFrame)

		if slot.npc then
			Collision.apply(slot.npc)
			v.slotsByNpc[slot.npc] = slot
			slot.lastGroundedCFrame = slot.spawnCFrame
			slot.grounded = false
		end

		refreshFloorRaycastFilter()
	end

	local function startSession(data2, arenaModel, seenClock: number)
		local rigsPath = data2.rigsPath or Config.defaultRigsPath
		local sourceRigs = Chaser.collectSourceRigs(arenaModel, rigsPath, data2.rigNames or Config.defaultRigNames)
		local resolved = Zone.resolve(arenaModel, data2.zoneName or Config.defaultZoneName, sourceRigs)
		v.zoneBoxes = resolved.boxes
		v.fallbackZoneFolder = resolved.generatedFolder
		logger:info(string.format(
			"Arena zone from %s: %d box(es), footprint %.0fx%.0f studs",
			resolved.source,
			#resolved.boxes,
			Zone.describeFootprint(resolved.boxes)
		))
		local session = AABossNpcs.new({
			arenaModel = arenaModel,
			playerBoundsZoneName = resolved.engineFolderName,
			archetypes = {
				[Config.chaserArchetypeId] = {
					chaseUpdateSec = Config.chaseUpdateSec,
					resolveWalkSpeed = resolveChaserWalkSpeed,
					resolveDestination = resolveChaserDestination
				}
			}
		})
		v.session = session

		local function isInsideChaseZone(vector: Vector3)
			return Zone.isInside(v.zoneBoxes, vector)
		end

		for _, sourceRig in sourceRigs do
			local spawnCFrame = Chaser.computeSpawnCFrame(sourceRig, isInsideChaseZone)
			logger:info(string.format(
				"Chaser for '%s': original at (%.0f, %.0f, %.0f), spawn at (%.0f, %.0f, %.0f)",
				sourceRig.Name,
				sourceRig:GetPivot().Position.X,
				sourceRig:GetPivot().Position.Y,
				sourceRig:GetPivot().Position.Z,
				spawnCFrame.X,
				spawnCFrame.Y,
				spawnCFrame.Z
			))
			local slot = Chaser.createSlot(sourceRig, spawnCFrame)
			table.insert(v.slots, slot)
			spawnChaser(session, slot, seenClock)
		end

		if #sourceRigs == 0 then
			logger:warn(string.format("No Humanoid rig found under '%s' of '%s'", rigsPath, arenaModel.Name))
		end
	end

	local function destroySession()
		if v.session then
			v.session:teardown()
			v.session = nil
		end

		for _, slot in v.slots do
			slot.template:Destroy()
		end

		table.clear(v.slots)
		table.clear(v.slotsByNpc)
		table.clear(v.zoneBoxes)

		if v.fallbackZoneFolder then
			v.fallbackZoneFolder:Destroy()
			v.fallbackZoneFolder = nil
		end
	end

	local function catchPlayers()
		local characters = {}

		for _, v2 in Players:GetPlayers() do
			local character = v2.Character
			local humanoid

			if character then
				humanoid = character:FindFirstChildOfClass("Humanoid")
			end

			if character and humanoid and humanoid.Health > 0 then
				table.insert(characters, character)
			end
		end

		if #characters > 0 then
			v.catchOverlapParams.FilterDescendantsInstances = characters

			for _, slot in v.slots do
				local npc = slot.npc
				local humanoid

				if npc then
					humanoid = npc:FindFirstChildOfClass("Humanoid")
				end

				if npc and npc.Parent and humanoid and humanoid.Health > 0 then
					Catch.killOverlappingPlayers(npc, v.catchOverlapParams)
				end
			end
		end
	end

	local function confineChasers()
		for _, slot in v.slots do
			local npc = slot.npc

			if npc and npc.Parent ~= nil then
				Chaser.confine(slot, npc, v.zoneBoxes, v.floorRaycastParams)
			end
		end
	end

	local function checkChaserNeedsRespawn(p, p2: number, object)
		local npc = p.npc
		return (npc == nil or npc.Parent == nil) and p2 - p.lastSpawnClock >= Config.respawnDelaySec and object:anyAlivePlayerInArena()
	end

	local function respawnMissingChasers(session, now: number)
		for _, slot in v.slots do
			local npc = slot.npc
			local v2

			if (npc == nil or npc.Parent == nil) and now - slot.lastSpawnClock >= Config.respawnDelaySec then
				v2 = session:anyAlivePlayerInArena()
			else
				v2 = false
			end

			if v2 then
				spawnChaser(session, slot, now)
			end
		end
	end

	local function pollHostMap(now: number)
		local v2 = nil
		local flag = true
		local seenMap

		for _, host in Config.hosts do
			seenMap = AdminAbuseUtils.Map.getMap(host.mapLiveName)

			if not seenMap then
				continue
			end

			v2 = host
			flag = false
			break
		end

		if flag then
			seenMap = nil
		end

		if v2 and seenMap then
			if v.seenMap ~= seenMap then
				v.seenMap = seenMap
				v.seenClock = now
			end

			-- equivalent call inferred; original call site unknown
			if isHostMapLoaded(v2, seenMap, v.seenClock, now) then
				startSession(v2, seenMap, now)
			end
		else
			v.seenMap = nil

			if not v.warnedTimeout and now - v.waitStartedClock >= Config.mapWaitTimeoutSec then
				v.warnedTimeout = true
				logger:warn(string.format(
					"No host map loaded after %d seconds; chasers were not spawned",
					Config.mapWaitTimeoutSec
				))
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onHostGone()
		logger:info("Host map removed; stopping Survival Chase")
		destroySession()
		task.defer(function()
			parentModule.stopModule(data.name, "manual")
		end)
	end

	local function onUpdate(p: number)
		local now = os.clock()
		local session = v.session

		if session == nil then
			if now - v.lastPollClock >= Config.mapPollIntervalSec then
				v.lastPollClock = now
				pollHostMap(now)
			end
		elseif session:isActive() then
			confineChasers()
			catchPlayers()
			stepRewards(p)

			if now - v.lastTickClock >= Config.chaseTickSec then
				v.lastTickClock = now
				respawnMissingChasers(session, now)
			end
		else
			onHostGone() -- equivalent call inferred; original call site unknown
		end
	end

	data.janitor:Add(destroySession, true)
	data.janitor:Add(function()
		table.clear(v.rewards)
	end, true)
	return {
		onUpdate = onUpdate
	}
end

local function buildClientRuntime(p)
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	local v = {
		visuals = {},
		lastScanClock = 0,
		zoneBoxes = {},
		rewardBar = RewardBar.mount(playerGui),
		reward = Rewards.newState()
	}

	local function scanZoneBoxes()
		local flag = true
		local v2

		for _, host in Config.hosts do
			v2 = AdminAbuseUtils.Map.getMap(host.mapLiveName)

			if not v2 then
				continue
			end

			flag = false
			break
		end

		if flag then
			v2 = nil
		end

		local child

		if v2 then
			child = v2:FindFirstChild(Zone.getBoundsFolderName())
		end

		v.zoneBoxes = not child and {} or Zone.readParts(child)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stepLocalReward(p2: number)
		local reward = v.reward
		Rewards.step(reward, localPlayer, v.zoneBoxes, p2, false)
		v.rewardBar.update(
			reward.progress,
			Rewards.getStreakMultiplier(reward.survivedSeconds),
			reward.survivedSeconds,
			#v.zoneBoxes > 0
		)
	end

	local function checkChaserVisualReady(model)
		if not (model:IsA("Model") and Chaser.isModel(model)) then
			model = nil
		end

		local humanoid

		if model then
			humanoid = model:FindFirstChildOfClass("Humanoid")
		end

		local animator

		if humanoid then
			animator = humanoid:FindFirstChildOfClass("Animator")
		end

		local humanoidRootPart

		if model then
			humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
		end

		if model and humanoid and animator and humanoidRootPart and humanoidRootPart:IsA("BasePart") and Config.runAnimations[humanoid.RigType] then
			return true, model, humanoid, humanoidRootPart
		end

		return false, nil, nil, nil
	end

	local function attachVisual(object, p2, rootPart)
		local animation = AdminAbuseUtils.Animations.loadAnimation(object, Config.runAnimations[p2.RigType])
		animation.Looped = true
		animation.Priority = Enum.AnimationPriority.Movement
		v.visuals[object] = {
			rootPart = rootPart,
			runTrack = animation,
			scale = object:GetScale()
		}
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function releaseVisual(k, visual)
		visual.runTrack:Stop(0)
		visual.runTrack:Destroy()
		v.visuals[k] = nil
	end

	local function scanChasers()
		for _, v2 in CollectionService:GetTagged(Config.npcTag) do
			if v.visuals[v2] ~= nil then
				continue
			end

			local v3, v4, v5, rootPart = checkChaserVisualReady(v2)

			if v3 then
				attachVisual(v4, v5, rootPart)
			end
		end
	end

	local function updateVisual(visual)
		local assemblyLinearVelocity = visual.rootPart.AssemblyLinearVelocity
		local magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude

		if Config.runAnimationMinSpeed <= magnitude then
			if not visual.runTrack.IsPlaying then
				visual.runTrack:Play(0.1)
			end

			visual.runTrack:AdjustSpeed(magnitude / (Config.runAnimationReferenceSpeed * visual.scale))
		elseif visual.runTrack.IsPlaying then
			visual.runTrack:Stop(0.2)
		end
	end

	local function updateVisuals()
		for k, visual in v.visuals do
			if k.Parent == nil then
				releaseVisual(k, visual) -- equivalent call inferred; original call site unknown
			else
				updateVisual(visual)
			end
		end
	end

	local function clearVisuals()
		for k, visual in v.visuals do
			releaseVisual(k, visual) -- equivalent call inferred; original call site unknown
		end
	end

	p.janitor:Add(clearVisuals, true)
	p.janitor:Add(v.rewardBar.destroy, true)
	return {
		onUpdate = function(p2: number)
			local now = os.clock()

			if now - v.lastScanClock >= Config.mapPollIntervalSec then
				v.lastScanClock = now
				scanChasers()
				scanZoneBoxes()
			end

			updateVisuals()
			stepLocalReward(p2) -- equivalent call inferred; original call site unknown
		end,
		onServerEvent = function(list)
			if type(list) ~= "table" then
				list = nil
			end

			if list and list[1] == "SurvivalWin" then
				v.reward.progress = 0
			end
		end
	}
end

parentModule.register(script.Name, {
	displayName = "Survival Chase",
	slot = "event",
	needsDuration = false,
	defaultDurationSeconds = 300,
	maxDurationSeconds = 1800,
	load = function(p)
		if RunService:IsServer() then
			return (buildServerRuntime(p))
		end

		return (buildClientRuntime(p))
	end,
	canStart = checkCanStart
})
return nil