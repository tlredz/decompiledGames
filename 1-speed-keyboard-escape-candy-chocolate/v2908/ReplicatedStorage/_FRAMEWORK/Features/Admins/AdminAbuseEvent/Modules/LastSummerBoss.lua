-- failed to load script (decompiled with syntax error):
-- JKmutopmbojXApwBILShcAzvw:533: Expected identifier when parsing expression, got ';'

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local Config = require(script.Config)
local Cutscenes = require(script.Cutscenes)
local Credits = require(script.Credits)
local BossProgressBar = require(script.BossProgressBar)
local WinRing = require(script.WinRing)
local Attacks = require(script.Attacks)
local StoneTsunami = require(script.Attacks.StoneTsunami)
local MeteorRain = require(script.Attacks.MeteorRain)
local LavaFlood = require(script.Attacks.LavaFlood)
local MaskClones = require(script.MaskClones)
local PhaseThreeGravity = require(script.PhaseThreeGravity)
local parentModule = require(script.Parent.Parent)
local AdminAbuseUtils = require(script.Parent.Parent.AdminAbuseUtils)
local InstanceUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.InstanceUtils)
local SpacialQuery = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.SpacialQuery)
local AdminAbuseDoorConfig = require(ReplicatedStorage.Shared.AdminAbuseDoorConfig)
local Promise = require(ReplicatedStorage.Utilities.Promise)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local v = (AdminAbuseDoorConfig.TransitionBlackIn or 0) + (AdminAbuseDoorConfig.TransitionBlackHold or 0) + (AdminAbuseDoorConfig.TransitionApproachSeconds or 0) + (AdminAbuseDoorConfig.LobbyDoorOpenExtraDelaySec or 0)
local idleBossAnimation = Config.idleBossAnimation
local cframe = CFrame.Angles(0, 0, 180)
local v2 = math.max(0, Config.winRingFillSeconds * 0.75)
local v3 = Config.sequenceOffset + 27
local v4 = v3 + Config.phase1DurationSeconds
local v5 = v4 + 5
local v6 = v4 + Config.phase2DurationSeconds
local v7 = v6 + 5
local v8 = v6 + Config.phase3DurationSeconds
local v9 = v8 + 5
local v10 = v9 + 6
local v11 = math.max(v10 + 10, v8 + Config.phase4DurationSeconds)
local v12 = v11 + Config.endingAttackCooldownSeconds
local v13 = Config.creditsFadeSeconds * 4 + Config.creditsHoldSeconds
local defaultDurationSeconds = v12 + (Config.endingCutsceneClientStartLeadSeconds + Config.endingCutsceneLeadSeconds + v13 + Config.endingTeardownGraceSeconds)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})

local function load(data)
	logger:info(`load() reached -- context={RunService:IsServer() and "server" or "client"} ` .. `isCatchUp={tostring(data.isCatchUp)} startedAt={data.startedAt} JobId={game.JobId}`)
	local v15 = nil
	local v16 = nil
	local flag = false
	local adminAbuseTransition = nil
	local lobbyDoorServer = nil
	local module = nil
	local module2 = nil
	local module3 = nil
	local module4 = nil
	local module5 = nil
	local v17 = {}
	local sequence = nil
	local v18 = {}
	local v19 = nil
	local v20 = nil
	local parts = {}
	local parts2 = {}
	local v21 = nil
	local flag2 = false
	local v22 = false
	local v23 = false
	local v24 = false
	local v25 = nil
	local v26 = false
	local v27 = nil
	local cFrame = nil
	local v28 = nil
	local v29 = nil
	local v30 = nil
	local v31 = nil
	local v32 = nil
	Config.attackConfigIndex = 1

	if RunService:IsServer() then
		local server = ServerScriptService:FindFirstChild("Server")

		if server then
			lobbyDoorServer = server:FindFirstChild("LobbyDoorServer")
		else
			lobbyDoorServer = nil
		end

		assert(lobbyDoorServer and lobbyDoorServer:IsA("ModuleScript"), "Server.LobbyDoorServer was not found")
		local utilities = ServerScriptService:FindFirstChild("Utilities")
		local playerTeleport

		if utilities then
			playerTeleport = utilities:FindFirstChild("PlayerTeleport")
		end

		assert(
			playerTeleport and playerTeleport:IsA("ModuleScript"),
			"ServerScriptService.Utilities.PlayerTeleport was not found"
		)
		module = require(playerTeleport)
		local dataManager = ServerScriptService:FindFirstChild("DataManager")
		assert(dataManager and dataManager:IsA("ModuleScript"), "ServerScriptService.DataManager was not found")
		module2 = require(dataManager)
		local boostsManager = ServerScriptService:FindFirstChild("BoostsManager")
		assert(boostsManager and boostsManager:IsA("ModuleScript"), "ServerScriptService.BoostsManager was not found")
		module3 = require(boostsManager)
		local bonusManager = ReplicatedStorage:FindFirstChild("BonusManager")
		assert(bonusManager and bonusManager:IsA("ModuleScript"), "ReplicatedStorage.BonusManager was not found")
		module4 = require(bonusManager)
		local config = ReplicatedStorage:FindFirstChild("Config")
		assert(config and config:IsA("ModuleScript"), "ReplicatedStorage.Config was not found")
		module5 = require(config)
	else
		local playerScripts = assert(Players.LocalPlayer, "Players.LocalPlayer was not found"):FindFirstChild("PlayerScripts")
		local client

		if playerScripts then
			client = playerScripts:FindFirstChild("Client")
		end

		if client then
			adminAbuseTransition = client:FindFirstChild("AdminAbuseTransition")
		else
			adminAbuseTransition = nil
		end

		assert(
			adminAbuseTransition and adminAbuseTransition:IsA("ModuleScript"),
			"PlayerScripts.Client.AdminAbuseTransition was not found"
		)
	end

	local function waitForLiveMap()
		local adminAbuse = Workspace:WaitForChild("AdminAbuse", 10)
		local map

		if adminAbuse then
			map = adminAbuse:WaitForChild("Map", 10)
		end

		local lastSummerBossAA_Live

		if map then
			lastSummerBossAA_Live = map:WaitForChild("LastSummerBossAA_Live", 10)
		end

		if lastSummerBossAA_Live and lastSummerBossAA_Live:IsA("Model") then
			return lastSummerBossAA_Live
		end

		return nil
	end

	local function returnPlayersInMapToSpawn(mapClone)
		local boundingBox, v33 = mapClone:GetBoundingBox()
		local v34 = assert(module, "PlayerTeleport is unavailable on the server")

		for _, v35 in Players:GetPlayers() do
			local character = v35.Character

			if not (character ~= nil and SpacialQuery.isPointInVolume(character:GetPivot().Position, boundingBox, v33)) then
				continue
			end

			v34.toLobby(v35, "Event")
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health > 0 then
				humanoid.Health = humanoid.MaxHealth
			end
		end
	end

	local function showMaskedMessage(p)
		for _, bindableEvent in CollectionService:GetTagged("AdminAnnounceListener") do
			if bindableEvent:IsA("BindableEvent") and bindableEvent:IsDescendantOf(game) then
				bindableEvent:Fire(p)
			end
		end
	end

	local function showCutsceneMaskedMessage(text: string, value: number?)
		showMaskedMessage({
			text = text,
			senderName = "The Mask",
			senderUserId = 1,
			isOwner = false,
			icon = "rbxassetid://74389556285578",
			Duration = value or 5
		})
	end

	local function showCutscenePlayerMessage(text: string, value: number?)
		local localPlayer = Players.LocalPlayer
		showMaskedMessage({
			text = text,
			senderName = not localPlayer and "You" or localPlayer.DisplayName,
			senderUserId = not localPlayer and 1 or localPlayer.UserId,
			isOwner = false,
			icon = nil,
			Duration = value or 5
		})
	end

	local function setup()
		if flag then
			return
		end

		flag = true
		local parent = waitForLiveMap()

		if not parent then
			warn("[LastSummerBoss] Timed out waiting for live map 'LastSummerBossAA_Live'")
			return
		end

		local v34 = nil
		local v35 = nil

		if RunService:IsClient() then
			v34 = InstanceUtils.getPotentialInstance(parent, "Scriptables/BossSpawnPart")

			if not v34 then
				warn("[LastSummerBoss] setup: Scriptables/BossSpawnPart not found under 'LastSummerBossAA_Live', skipping the boss rig")
			end

			v35 = InstanceUtils.getPotentialInstance(parent, "Scriptables/CageAnchor")

			if not v35 then
				warn("[LastSummerBoss] setup: Scriptables/CageAnchor not found under 'LastSummerBossAA_Live', skipping the jailed characters")
			end
		else
			v19 = InstanceUtils.getPotentialInstance(parent, "Scriptables/AttackAreaBottom")

			if not v19 then
				warn("[LastSummerBoss] setup: Scriptables/AttackAreaBottom not found under 'LastSummerBossAA_Live' (MeteorRain and LavaFlood's phase 1/3 zone depend on this)")
			end

			v20 = InstanceUtils.getPotentialInstance(parent, "Scriptables/AttackAreaTop")

			if not v20 then
				warn("[LastSummerBoss] setup: Scriptables/AttackAreaTop not found under 'LastSummerBossAA_Live' (MeteorRain and LavaFlood's phase 3 zone depend on this)")
			end

			local potentialInstance = InstanceUtils.getPotentialInstance(parent, "Scriptables/TsunamiSpawnsBottom")

			if potentialInstance then
				for _, part in potentialInstance:GetChildren() do
					if part:IsA("BasePart") then
						table.insert(parts, part)
					end
				end
			else
				warn("[LastSummerBoss] setup: Scriptables/TsunamiSpawnsBottom not found under 'LastSummerBossAA_Live' (StoneTsunami's phase 1/3 zone depends on this)")
			end

			local potentialInstance2 = InstanceUtils.getPotentialInstance(parent, "Scriptables/TsunamiSpawnsTop")

			if potentialInstance2 then
				for _, part in potentialInstance2:GetChildren() do
					if part:IsA("BasePart") then
						table.insert(parts2, part)
					end
				end
			else
				warn("[LastSummerBoss] setup: Scriptables/TsunamiSpawnsTop not found under 'LastSummerBossAA_Live' (StoneTsunami's phase 3 zone depends on this)")
			end

			v21 = InstanceUtils.getPotentialInstance(parent, "Scriptables/MaskCloneSpawnZone")

			if not v21 then
				warn("[LastSummerBoss] setup: Scriptables/MaskCloneSpawnZone not found under 'LastSummerBossAA_Live' (phase 4's Mask Clones depend on this)")
			end

			v30 = InstanceUtils.getPotentialInstance(parent, "Scriptables/GravityZone")

			if not v30 then
				warn("[LastSummerBoss] setup: Scriptables/GravityZone not found under 'LastSummerBossAA_Live' (ceiling-walk gravity reversal depends on this)")
			end
		end

		local scriptables = parent:FindFirstChild("Scriptables")

		if scriptables then
			local vFXPortals = scriptables:FindFirstChild("VFXPortals")

			for _, v36 in scriptables:QueryDescendants("BasePart") do
				if vFXPortals and v36:IsDescendantOf(vFXPortals) then
					continue
				end

				v36.Transparency = 1
				v36:ClearAllChildren()
			end
		end

		if not RunService:IsClient() then
			data.FireServerEventToAll({ "ForceSetup" })
			return
		end

		local clone

		if v34 then
			clone = ReplicatedStorage.AdminAbuse.LastSummerBoss.Assets.TheMasked:Clone()
			v27 = clone
			cFrame = v34.CFrame
			clone:PivotTo(v34.CFrame)
			clone.Parent = parent
			AdminAbuseUtils.Animations.loadAnimation(clone, idleBossAnimation):Play(0)
		else
			clone = nil
		end

		local clone2 = nil
		local jailedCharacters = ReplicatedStorage.AdminAbuse.LastSummerBoss.Assets:FindFirstChild("JailedCharacters")

		if v35 and jailedCharacters and jailedCharacters:IsA("Model") then
			clone2 = jailedCharacters:Clone()
			v28 = clone2
			clone2:PivotTo(v35.CFrame)

			if data.isCatchUp and not flag2 then
				clone2.Parent = parent
			end
		elseif v35 and not jailedCharacters then
			warn("[LastSummerBoss] setup: AdminAbuse.LastSummerBoss.Assets.JailedCharacters was not found")
		end

		if not data.isCatchUp then
			Cutscenes.playOpening(parent, function()
				if clone and clone == v27 and parent.Parent then
					clone.Parent = parent
				end

				if clone2 and clone2 == v28 and parent.Parent then
					clone2.Parent = parent
				end
			end, showCutsceneMaskedMessage, function()
				if clone then
					clone.Parent = nil
				end
			end, showCutscenePlayerMessage)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getLobbyDoor()
		local v33 = assert(lobbyDoorServer, "LobbyDoorServer is unavailable on the server")
		local module6 = require(v33)
		return module6
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cancelOpeningPromise()
		if v16 then
			v16:cancel()
			v16 = nil
		end
	end

	local function moveLobbyPortal(flag3: boolean)
		if RunService:IsClient() then
			return
		end

		local portal = Workspace:FindFirstChild("Portal")
		local adminAbuse = Workspace:FindFirstChild("AdminAbuse")
		local portalAATPSpot

		if flag3 and adminAbuse then
			portalAATPSpot = adminAbuse:FindFirstChild("PortalAATPSpot")
		else
			portalAATPSpot = Workspace:FindFirstChild("PortalDefaultSpot")
		end

		if portal and portal:IsA("Model") and portalAATPSpot and portalAATPSpot:IsA("BasePart") then
			portal:PivotTo(portalAATPSpot.CFrame)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function registerMapCleanup(p)
		data.janitor:Add(function()
			if v15 == p then
				AdminAbuseUtils.Map.removeMap(p)
				v15 = nil
			end
		end)
	end

	local function beginOpeningSequence(p)
		local lobbyDoor = getLobbyDoor() -- equivalent call inferred; original call site unknown
		local v33 = p.mapLoaded:andThen(function()
			if v15 ~= p then
				return
			end

			setup()

			if not data.isCatchUp then
				return Promise.delay(v):andThen(function()
					if v15 == p then
						lobbyDoor.open(false)
					end
				end)
			end

			lobbyDoor.open(true)
		end):catch(function(p2)
			warn((`[LastSummerBoss] Opening sequence failed: {tostring(p2)}`))
		end)
		v16 = v33
		data.janitor:Add(function()
			v33:cancel()

			if v16 == v33 then
				v16 = nil
			end
		end)
	end

	local function onStart()
		logger:info((`onStart() reached -- context={RunService:IsServer() and "server" or "client"} JobId={game.JobId}`))
		sequence.Start(data.elapsedSeconds)

		if RunService:IsClient() then
			local v33 = assert(
				assert(Players.LocalPlayer, "Players.LocalPlayer was not found"):FindFirstChildOfClass("PlayerGui"),
				"PlayerGui was not found"
			)
			local v34 = math.max(v12 - v3, 0.001)
			local v35 = math.clamp((v5 - v3) / v34, 0, 1)
			local v36 = math.clamp((v7 - v3) / v34, 0, 1)
			local v37 = math.clamp((v9 - v3) / v34, 0, 1)
			v29 = BossProgressBar.mount(v33, v35, v36, v37)
			data.janitor:Add(function()
				if v29 then
					v29.destroy()
					v29 = nil
				end
			end)
		else
			moveLobbyPortal(true)
			data.janitor:Add(function()
				moveLobbyPortal(false)
			end)
			data.janitor:Add(task.spawn(function()
				local success, result = pcall(Cutscenes.getEndingDurationSeconds)

				if success then
					v25 = result
				else
					warn((`[LastSummerBoss] Failed to resolve ending cutscene duration: {result}`))
				end
			end))
			local v33 = AdminAbuseUtils.Map.addMap({
				templateName = "LastSummerBossAA",
				liveName = "LastSummerBossAA_Live",
				streamedKeycapsFolderName = "LastSummerBoss_Keycaps"
			})
			assert(v33, "LastSummerBoss map placement unexpectedly returned nil on the server")
			v15 = v33
			registerMapCleanup(v33) -- equivalent call inferred; original call site unknown
			beginOpeningSequence(v33)
		end
	end

	local function stopClient(p)
		local v33 = assert(adminAbuseTransition, "AdminAbuseTransition is unavailable on the client")
		local module6 = require(v33)
		module6.cancel()

		if p ~= "shutdown" and (p ~= "durationElapsed" or not v24) then
			module6.play(nil, {
				skip = false,
				skipDoor = true
			})
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function removeMap(p)
		local v33 = AdminAbuseUtils.Map.removeMap(p)

		if v33 then
			local v34, v35 = v33:await()

			if not v34 then
				warn((`[LastSummerBoss] Failed to remove the event map: {tostring(v35)}`))
			end
		end

		if v15 == p then
			v15 = nil
		end
	end

	local function stopServer(p)
		cancelOpeningPromise() -- equivalent call inferred; original call site unknown
		;(getLobbyDoor()).close(false)
		moveLobbyPortal(false)

		if v32 then
			v32.stop()
		end

		if v31 then
			v31.stop()
		end

		local v33 = v15

		if not v33 then
			return
		end

		if p ~= "shutdown" then
			parentModule.remotes.Deactivated:fireAll(data.name, p)
			task.wait(AdminAbuseDoorConfig.TransitionBlackIn or 0)
			returnPlayersInMapToSpawn(v33.mapClone)
		end

		removeMap(v33) -- equivalent call inferred; original call site unknown
	end

	local function handleEndingUnderCover()
		;(getLobbyDoor()).close(false)
		moveLobbyPortal(false)
		local v33 = v15

		if v33 then
			returnPlayersInMapToSpawn(v33.mapClone)
		end
	end

	local v33 = {}
	local v34 = {}
	local v35 = {}
	local flag3 = false

	local function getWorldXZSize(instance)
		local cFrame2 = instance.CFrame
		local size = instance.Size
		local v36 = math.abs(cFrame2.RightVector.X) * size.X + math.abs(cFrame2.UpVector.X) * size.Y + math.abs(cFrame2.LookVector.X) * size.Z
		local v37 = math.abs(cFrame2.RightVector.Z) * size.X + math.abs(cFrame2.UpVector.Z) * size.Y + math.abs(cFrame2.LookVector.Z) * size.Z
		return (Vector3.new(v36, size.Y, v37))
	end

	local attackConfigIndex = Config.attackConfigIndex

	local function getWinAreaFolderName()
		return "WinAreaBottom"
	end

	local function getWinAreaPart(p: number)
		local v36 = v18[p]

		if v36 and v36.Parent then
			return v36
		end

		return nil
	end

	local function getAttackAreaPart()
		local v36 = v19

		if v36 and v36.Parent then
			return v36
		end

		return nil
	end

	local function getStoneTsunamiSpawnPart()
		local v36 = parts

		if #v36 == 0 then
			return nil
		end

		return v36[math.random(1, #v36)]
	end

	local function getMaskCloneSpawnZone()
		if v21 and v21.Parent then
			return v21
		end

		return nil
	end

	local v36 = false

	local function createAttackController(p: number)
		local attackDelaySeconds = Config.attackDelaySecondsByPhase[p]
		assert(attackDelaySeconds ~= nil, (`Missing attack delay for LastSummerBoss phase {p}`))
		local attacks = { StoneTsunami.new(p, function()
				data.FireClientEvent({ "AttackHit", "StoneTsunami" })
			end), (MeteorRain.new(p, function()
				data.FireClientEvent({ "AttackHit", "MeteorRain" })
			end)) }

		if p > 1 then
			table.insert(attacks, (LavaFlood.new(p, function()
				data.FireClientEvent({ "AttackHit", "LavaFlood" })
			end)))
		end

		return Attacks.new({
			attacks = attacks,
			attackDelaySeconds = attackDelaySeconds,
			getZone = function(p2: string)
				if p2 == "StoneTsunami" then
					local v39 = parts

					if #v39 == 0 then
						return nil
					end

					return v39[math.random(1, #v39)]
				else
					local v39 = v19

					if v39 and v39.Parent then
						return v39
					end

					return nil
				end
			end,
			sendToClients = function(p2)
				data.FireServerEventToAll(p2)
			end
		})
	end

	local attackController = createAttackController(attackConfigIndex)

	if RunService:IsServer() then
		v32 = MaskClones.new({
			config = {
				cloneCount = Config.maskCloneCount,
				hitPoints = Config.maskCloneHitPoints,
				swordDamage = Config.maskCloneSwordDamage,
				chaseWalkSpeed = Config.maskCloneChaseWalkSpeed,
				touchDamage = Config.maskCloneTouchDamage,
				respawnIntervalSeconds = Config.maskCloneRespawnIntervalSeconds
			},
			getArenaModel = function()
				return AdminAbuseUtils.Map.getMap("LastSummerBossAA_Live")
			end,
			getSpawnZone = getMaskCloneSpawnZone,
			onKilled = function(player)
				local v37 = assert(module2, "DataManager is unavailable on the server")
				local v38 = assert(module3, "BoostsManager is unavailable on the server")
				local v39 = assert(module4, "BonusManager is unavailable on the server")
				local DEPRECATED_BOSS_WIN_TIERS = assert(module5, "World config is unavailable on the server").DEPRECATED_BOSS_WIN_TIERS
				assert(#DEPRECATED_BOSS_WIN_TIERS > 0, "World config has no boss win tiers")
				local v40 = v37.LevelCache[player.UserId] or 1
				local wins = DEPRECATED_BOSS_WIN_TIERS[#DEPRECATED_BOSS_WIN_TIERS].wins

				for _, v42 in DEPRECATED_BOSS_WIN_TIERS do
					if not (v40 <= v42.maxLevel) then
						continue
					end

					wins = v42.wins
					break
				end

				local v42 = math.max(1, (math.ceil(wins / Config.winRingAwardDivisor)))
				local v43 = v38.HasWinsBoost(v38, player) and 2 or 1
				local winsMultiplier = v39.GetWinsMultiplier(v39, player)
				local v44 = math.ceil(v42 * v43 * winsMultiplier * Config.maskCloneWinMultiplier)
				v37:IncrementStat(player, "Wins", v44, {
					source = "LastSummerBoss:MaskClone"
				})
				local remotes = ReplicatedStorage:FindFirstChild("Remotes")
				local showWin = remotes and remotes:FindFirstChild("ShowWin")

				if showWin and showWin:IsA("RemoteEvent") then
					showWin:FireClient(player, v44)
				end
			end
		})
		v31 = PhaseThreeGravity.new()
	else
		v32 = MaskClones.newRenderer()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function startWinRingMovement(p, p2, p3: number)
		local winRingConfig = Config.winRingConfigs[p3]

		if not winRingConfig then
			return
		end

		p.startMovement(
			p2.Position,
			getWorldXZSize(p2),
			Config.sequenceOffset + 35,
			Config.winRingMovementSeed + p3 - 1,
			winRingConfig.movementSpeed
		)
	end

	local function spawnWinRing(p: number, flag4: boolean?)
		local winRingConfig = Config.winRingConfigs[p]

		if RunService:IsServer() or not winRingConfig or v33[p] or v34[p] then
			return
		end

		v34[p] = true
		data.janitor:Add(task.spawn(function()
			local v37 = waitForLiveMap()
			local v38 = "WinAreaBottom"
			local v39

			if v37 then
				v39 = InstanceUtils.waitForPotentialInstance(v37, (`Scriptables/{v38}`))
			end

			if v39 then
				v18[p] = v39
				local mountedOnCeiling = v38 == "WinAreaTop"
				local success, result = pcall(WinRing.new, {
					position = v39.Position,
					radius = winRingConfig.radius,
					winMultiplier = winRingConfig.winMultiplier,
					fillDurationSeconds = Config.winRingFillSeconds,
					depleteDurationSeconds = Config.winRingDepleteSeconds,
					onWin = function()
						data.FireClientEvent({ "AwardWin", p })
					end,
					mountedOnCeiling = mountedOnCeiling
				})
				v34[p] = nil

				if not success then
					logger:warn((`spawnWinRing({p}) failed to construct WinRing: {tostring(result)}`))
					return
				end

				v33[p] = result
				local spawn = result.Spawn
				local v41

				if flag4 == nil then
					v41 = not data.isCatchUp
				else
					v41 = flag4
				end

				spawn(v41)

				if flag3 then
					startWinRingMovement(result, v39, p) -- equivalent call inferred; original call site unknown
				end
			else
				v34[p] = nil
				warn((`[LastSummerBoss] Timed out waiting for {v38}`))
			end
		end))
	end

	local function awardWin(player, p: number)
		local winRingConfig = Config.winRingConfigs[p]

		if not (winRingConfig and v35[p]) then
			return
		end

		local now = os.clock()
		local nows = v17[player]

		if not nows then
			nows = {}
			v17[player] = nows
		end

		local v37 = nows[p]

		if v37 and now - v37 < v2 then
			return
		end

		nows[p] = now
		local v38 = assert(module2, "DataManager is unavailable on the server")
		local v39 = assert(module3, "BoostsManager is unavailable on the server")
		local v40 = assert(module4, "BonusManager is unavailable on the server")
		local DEPRECATED_BOSS_WIN_TIERS = assert(module5, "World config is unavailable on the server").DEPRECATED_BOSS_WIN_TIERS
		assert(#DEPRECATED_BOSS_WIN_TIERS > 0, "World config has no boss win tiers")
		local v41 = v38.LevelCache[player.UserId] or 1
		local wins = DEPRECATED_BOSS_WIN_TIERS[#DEPRECATED_BOSS_WIN_TIERS].wins

		for _, v43 in DEPRECATED_BOSS_WIN_TIERS do
			if not (v41 <= v43.maxLevel) then
				continue
			end

			wins = v43.wins
			break
		end

		local v43 = math.max(1, (math.ceil(wins / Config.winRingAwardDivisor)))
		local v44 = v39.HasWinsBoost(v39, player) and 2 or 1
		local winsMultiplier = v40.GetWinsMultiplier(v40, player)
		local v45 = v43 * v44 * winsMultiplier * winRingConfig.winMultiplier
		v38:IncrementStat(player, "Wins", v45, {
			source = "LastSummerBoss:WinRing"
		})
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local showWin = remotes and remotes:FindFirstChild("ShowWin")

		if showWin and showWin:IsA("RemoteEvent") then
			showWin:FireClient(player, v45)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function damagePlayer(player, damage: number)
		local character = player.Character
		local humanoid

		if character then
			humanoid = character:FindFirstChildOfClass("Humanoid")
		end

		if humanoid and humanoid.Health > 0 then
			humanoid:TakeDamage(damage)
		end
	end

	local function startMainEvent()
		flag3 = true

		if RunService:IsServer() then
			return
		end

		if not v33[1] then
			spawnWinRing(1)
		end

		local v37 = v33[1]
		local v38 = v18[1]

		if not (v38 and v38.Parent) then
			v38 = nil
		end

		if not (v37 and v38) then
			return
		end

		startWinRingMovement(v37, v38, 1) -- equivalent call inferred; original call site unknown
	end

	local function startAttacks()
		if RunService:IsServer() then
			v36 = true

			if attackConfigIndex ~= 3 then
				attackController.start(data.elapsedSeconds)
			end
		end
	end

	local function setMaskedRigCeilingFlip(flag4: boolean)
		if RunService:IsServer() or not (v27 and cFrame) then
			return
		end

		local v37 = v27
		local v38

		if flag4 then
			v38 = cFrame * cframe
		else
			v38 = cFrame
		end

		v37:PivotTo(v38)
	end

	local function setPhase(p: number)
		if attackConfigIndex == p then
			return
		end

		attackController.cleanup()
		attackConfigIndex = p
		attackController = createAttackController(p)

		if RunService:IsServer() and v36 and not v26 then
			attackController.start(data.elapsedSeconds)
		end
	end

	local function startMaskClonesPhase()
		if v32 then
			v32.start()
		end
	end

	local function stopMaskClonesPhase()
		if v32 then
			v32.stop()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function retireWinRing(p: number)
		local v37 = v33[p]

		if not v37 then
			logger:info((`retireWinRing({p}): nothing to destroy, winRings[{p}] was already nil`))
			return
		end

		v37.destroy()
		v33[p] = nil
	end

	local function relocateWinRingForCurrentPhase(p: number)
		if v33[p] then
			retireWinRing(p) -- equivalent call inferred; original call site unknown
			spawnWinRing(p, true)
		end
	end

	local function stopAttacksForEnding()
		if RunService:IsServer() and not v26 then
			v26 = true
			attackController.stop()
		end
	end

	local function startEndingCutscene()
		if flag2 then
			return
		end

		flag2 = true

		if not RunService:IsServer() then
			data.janitor:Add(task.spawn(function()
				AdminAbuseUtils.Musics.play(Config.ambiance, {
					fadeDuration = Config.endingMusicCrossfadeSeconds
				})
				local map = AdminAbuseUtils.Map.getMap("LastSummerBossAA_Live")

				if map then
					Cutscenes.playEnding(map, function(flag4: boolean)
						if not flag4 then
							return
						end

						v24 = true
						Credits.play()
						data.FireClientEvent({ "EndingOutroCovered" })
					end, showCutsceneMaskedMessage, function()
						if v27 then
							v27.Parent = nil
						end

						if v28 then
							v28.Parent = nil
						end

						for k, v37 in v33 do
							v37.destroy()
							v33[k] = nil
						end
					end)
				else
					warn("[LastSummerBoss] Could not play the ending cutscene because the live map was unavailable")
				end
			end))
			return
		end

		attackController.cleanup()
		local v37 = Config.endingCutsceneClientStartLeadSeconds + (v25 or Config.endingCutsceneLeadSeconds) + v13 + Config.endingTeardownGraceSeconds
		local thread = task.delay(v37, function()
			if flag2 and not v22 then
				v22 = true
				local v38, v39 = parentModule.stopModuleLocally(data.name, "durationElapsed")

				if not v38 then
					warn((`[LastSummerBoss] Failed to stop locally after the ending cutscene: {v39 or "unknown error"}`))
				end
			end
		end)
		data.janitor:Add(thread)
	end

	local function sendAdminMessage(text: string, value: number?, senderName: string, senderUserId: number, icon: string?)
		showMaskedMessage({
			text = text,
			senderName = senderName,
			senderUserId = senderUserId,
			isOwner = false,
			icon = icon,
			Duration = value or 5
		})
	end

	local function sendMaskedMessage(text: string, value: number?)
		showMaskedMessage({
			text = text,
			senderName = "The Mask",
			senderUserId = 1,
			isOwner = false,
			icon = "rbxassetid://74389556285578",
			Duration = value or 5
		})
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function playMusic(p: number)
		AdminAbuseUtils.Musics.play(p)
	end

	local sequenceOffset = Config.sequenceOffset
	sequence = AdminAbuseUtils.Sequence.new()
	sequence.push(0, "client", function()
		playMusic(Config.ambiance) -- equivalent call inferred; original call site unknown
	end, true)
	sequence.push(sequenceOffset + 18, "client", function()
		spawnWinRing(1)
	end, true)
	sequence.push(sequenceOffset + 18, "server", function()
		v35[1] = true
	end, true)
	sequence.push(v3, "client", function()
		startMainEvent()
		playMusic(Config.bossMusic) -- equivalent call inferred; original call site unknown
	end, true)
	sequence.push(v3, "server", startAttacks, true)
	sequence.push(v5, "both", function()
		if attackConfigIndex == 2 then
			return
		end

		attackController.cleanup()
		attackConfigIndex = 2
		attackController = createAttackController(2)

		if RunService:IsServer() and v36 and not v26 then
			attackController.start(data.elapsedSeconds)
		end
	end, true)
	sequence.push(v5, "client", function()
		spawnWinRing(2, true)
	end, true)
	sequence.push(v5, "server", function()
		v35[2] = true
	end, true)
	sequence.push(v6, "client", function()
		showMaskedMessage({
			text = "In this new galaxy, you'll have new powers...",
			senderName = "The Mask",
			senderUserId = 1,
			isOwner = false,
			icon = "rbxassetid://74389556285578",
			Duration = 4
		})
	end)
	sequence.push(v6 + 4, "client", function()
		showMaskedMessage({
			text = "The new world will have new mechanics.. I can't wait",
			senderName = "The Mask",
			senderUserId = 1,
			isOwner = false,
			icon = "rbxassetid://74389556285578",
			Duration = 4
		})
	end)
	sequence.push(v7, "both", function()
		if attackConfigIndex == 3 then
			return
		end

		attackController.cleanup()
		attackConfigIndex = 3
		attackController = createAttackController(3)

		if RunService:IsServer() and v36 and not v26 then
			attackController.start(data.elapsedSeconds)
		end
	end, true)
	sequence.push(v8, "client", function()
		showMaskedMessage({
			text = "I really can't wait for those new mechanics!",
			senderName = "The Mask",
			senderUserId = 1,
			isOwner = false,
			icon = "rbxassetid://74389556285578",
			Duration = 4
		})
	end)
	sequence.push(v9, "both", function()
		if attackConfigIndex == 4 then
			return
		end

		attackController.cleanup()
		attackConfigIndex = 4
		attackController = createAttackController(4)

		if RunService:IsServer() and v36 and not v26 then
			attackController.start(data.elapsedSeconds)
		end
	end, true)
	sequence.push(v9, "client", function()
		local v37 = v33[2]

		if not v37 then
			logger:info((`retireWinRing({2}): nothing to destroy, winRings[{2}] was already nil`))
			return
		end

		v37.destroy()
		v33[2] = nil
	end, true)
	sequence.push(v9, "server", function()
		v35[2] = nil
	end, true)
	sequence.push(v10, "client", function()
		showMaskedMessage({
			text = "Here comes the cavalry~",
			senderName = "The Mask",
			senderUserId = 1,
			isOwner = false,
			icon = "rbxassetid://74389556285578",
			Duration = 5
		})
	end)
	sequence.push(v10 + 4, "client", function()
		showMaskedMessage({
			text = "Take them down. The wins are worth it.",
			senderName = "The Mask",
			senderUserId = 1,
			isOwner = false,
			icon = "rbxassetid://74389556285578",
			Duration = 3.5
		})
	end)
	sequence.push(v10 + 4, "both", startMaskClonesPhase, true)
	sequence.push(v11, "client", function()
		showMaskedMessage({
			text = "It is time!",
			senderName = "The Mask",
			senderUserId = 1,
			isOwner = false,
			icon = "rbxassetid://74389556285578",
			Duration = 4
		})
	end)
	sequence.push(v11, "both", stopMaskClonesPhase, true)
	sequence.push(v11, "server", stopAttacksForEnding, true)
	sequence.push(v12, "client", startEndingCutscene, true)
	sequence.push(v12, "server", startEndingCutscene, true)
	data.janitor:Add(function()
		AdminAbuseUtils.cleanupAll()
	end)
	data.janitor:Add(function()
		Cutscenes.cleanup()
	end)
	data.janitor:Add(function()
		Credits.cleanup()
	end)
	data.janitor:Add(function()
		attackController.cleanup()
	end)
	data.janitor:Add(function()
		if v32 then
			v32.cleanup()
		end
	end)
	data.janitor:Add(function()
		if v31 then
			v31.stop()
		end
	end)
	data.janitor:Add(function()
		for k, v37 in v33 do
			v37.destroy()
			v33[k] = nil
		end
	end)
	data.janitor:Add(function()
		if v28 then
			v28:Destroy()
			v28 = nil
		end
	end)
	data.janitor:Add(function()
		if v27 then
			v27:Destroy()
			v27 = nil
		end
	end)
	return {
		onStart = onStart,
		onStop = function(p)
			if RunService:IsClient() then
				stopClient(p)
			else
				stopServer(p)
			end
		end,
		onUpdate = function(p: number)
			sequence.Run(data.elapsedSeconds)
			attackController.update(data.elapsedSeconds)

			if v32 then
				v32.update()
			end

			if v29 then
				local v37 = math.max(v12 - v3, 0.001)
				local v38 = (data.elapsedSeconds - v3) / v37
				v29.update(v38, v3 <= data.elapsedSeconds and data.elapsedSeconds < v12)
			end

			for _, v37 in v33 do
				v37.update(data.elapsedSeconds, p)
			end
		end,
		onServerEvent = function(list)
			attackController.handleServerEvent(list)

			if typeof(list) ~= "table" then
				return
			end

			if list[1] == "ForceSetup" then
				setup()
			end
		end,
		onClientEvent = function(player, list)
			if typeof(list) ~= "table" then
				return
			end

			if list[1] == "AwardWin" and type(list[2]) == "number" and list[2] % 1 == 0 and list[2] > 0 then
				awardWin(player, list[2])
			elseif list[1] == "AttackHit" and list[2] == "StoneTsunami" then
				damagePlayer(player, Config.stoneTsunamiAttackConfigs[attackConfigIndex].damage) -- equivalent call inferred; original call site unknown
			elseif list[1] == "AttackHit" and list[2] == "MeteorRain" then
				damagePlayer(player, Config.meteorRainAttackConfigs[attackConfigIndex].damage) -- equivalent call inferred; original call site unknown
			elseif list[1] == "AttackHit" and list[2] == "LavaFlood" then
				damagePlayer(player, Config.lavaFloodAttackConfigs[attackConfigIndex].damage) -- equivalent call inferred; original call site unknown
			elseif list[1] == "EndingOutroCovered" and flag2 and not v23 then
				local elapsedSeconds = data.elapsedSeconds

				if v12 + (v25 or 0) <= elapsedSeconds then
					v23 = true
					task.spawn(handleEndingUnderCover)
				end
			end
		end,
		onPlayerAdded = function(p)
			if RunService:IsServer() and flag then
				data.FireServerEventToPlayer(p, { "ForceSetup" })
			end
		end
	}
end

logger:info((`registering with AdminAbuseEvent -- context={RunService:IsServer() and "server" or "client"} JobId={game.JobId}`))
parentModule.register(script.Name, {
	displayName = "Last Summer Boss",
	slot = "main",
	defaultDurationSeconds = defaultDurationSeconds,
	needsDuration = false,
	load = load
})
return nil