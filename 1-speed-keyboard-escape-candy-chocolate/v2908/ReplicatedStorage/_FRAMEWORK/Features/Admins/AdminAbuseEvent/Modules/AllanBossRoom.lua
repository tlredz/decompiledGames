local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local Config = require(script.Config)
local Attacks = require(script.Attacks)
local MeteorRain = require(script.Attacks.MeteorRain)
local Movement = require(script.Movement)
local Keycaps = require(script.Keycaps)
local KeycapRepairWins = require(script.KeycapRepairWins)
local Collision = require(script.Collision)
local RigNametag = require(script.RigNametag)
local Bridges = require(script.Bridges)
local BridgeRepair = require(script.BridgeRepair)
local BridgeRings = require(script.BridgeRings)
local KeycapVisibilityClient = require(script.KeycapVisibilityClient)
local VoidCatch = require(script.VoidCatch)
local NpcAnimationClient = require(script.NpcAnimationClient)
local NpcJumpClient = require(script.NpcJumpClient)
local LandingDebris = require(script.LandingDebris)
local TopBanner = require(script.TopBanner)
local TesterNametag = require(script.TesterNametag)
local Credits = require(script.Credits)
local Cutscenes = require(script.Cutscenes)
local parentModule = require(script.Parent.Parent)
local AdminAbuseUtils = require(script.Parent.Parent.AdminAbuseUtils)
local InstanceUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.InstanceUtils)
local SpacialQuery = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.SpacialQuery)
local AAEventWinAward = require(ReplicatedStorage._FRAMEWORK.Libraries.AAEventWinAward)
local floatingOrbWins = require(ReplicatedStorage._FRAMEWORK.Libraries.floatingOrbWins)
require(ReplicatedStorage._FRAMEWORK.Libraries.floatingOrbWins.Types)
local AdminAbuseDoorConfig = require(ReplicatedStorage.Shared.AdminAbuseDoorConfig)
local Promise = require(ReplicatedStorage.Utilities.Promise)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local formatted = `{Config.mapTemplateName}_Live`
local v = (AdminAbuseDoorConfig.TransitionBlackIn or 0) + (AdminAbuseDoorConfig.TransitionBlackHold or 0) + (AdminAbuseDoorConfig.TransitionApproachSeconds or 0) + (AdminAbuseDoorConfig.LobbyDoorOpenExtraDelaySec or 0)
local v2 = Config.sequenceOffsetSeconds + Config.introLeadSeconds
local v3 = v2 + Config.phaseDurationsSeconds[1]
local v4 = v3 + Config.phaseDurationsSeconds[2]
local v5 = v4 + Config.phaseDurationsSeconds[3]
local v6 = v5 + Config.endingLeadSeconds
local v7 = Config.creditsFadeSeconds * 3 + Config.creditsHoldSeconds
local defaultDurationSeconds = v6 + Config.endingCutsceneFallbackSeconds + v7 + Config.endingTeardownGraceSeconds
parentModule.register(script.Name, {
	displayName = "Allan Boss Room",
	slot = "main",
	needsDuration = false,
	defaultDurationSeconds = defaultDurationSeconds,
	load = function(data)
		local isServer = RunService:IsServer()
		local flag = false
		local v9 = 1
		local v10 = nil
		local v11 = nil
		local flag2 = false
		local v12 = false
		local v13 = nil
		local elapsedSeconds = nil
		local v14 = 0
		local v15 = 0
		local lobbyDoorServer = nil
		local module = nil
		local adminAbuseTransition = nil
		local v16 = nil
		local v17 = nil
		local v18 = nil
		local v19 = nil
		local v20 = nil
		local v21 = nil
		local v22 = nil
		local resolved = nil
		local v23 = nil
		local v24 = nil
		local threads = {}
		local thread = nil
		local v25 = nil
		local v26 = nil
		local v27 = nil
		local v28 = nil
		local v29 = nil
		local v30 = nil
		local sequence = nil

		if isServer then
			local server = ServerScriptService:FindFirstChild("Server")

			if server then
				lobbyDoorServer = server:FindFirstChild("LobbyDoorServer")
			else
				lobbyDoorServer = nil
			end

			assert(
				lobbyDoorServer and lobbyDoorServer:IsA("ModuleScript"),
				"AllanBossRoom: Server.LobbyDoorServer was not found"
			)
			local utilities = ServerScriptService:FindFirstChild("Utilities")
			local playerTeleport

			if utilities then
				playerTeleport = utilities:FindFirstChild("PlayerTeleport")
			end

			assert(
				playerTeleport and playerTeleport:IsA("ModuleScript"),
				"AllanBossRoom: ServerScriptService.Utilities.PlayerTeleport was not found"
			)
			module = require(playerTeleport)
		else
			local playerScripts = assert(Players.LocalPlayer, "AllanBossRoom: Players.LocalPlayer was not found"):FindFirstChild("PlayerScripts")
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
				"AllanBossRoom: PlayerScripts.Client.AdminAbuseTransition was not found"
			)
		end

		local function waitForLiveMap()
			local adminAbuse = Workspace:WaitForChild("AdminAbuse", 10)
			local map

			if adminAbuse then
				map = adminAbuse:WaitForChild("Map", 10)
			end

			local model

			if map then
				model = map:WaitForChild(formatted, 10)
			end

			if model and model:IsA("Model") then
				return model
			end

			return nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getLiveMap()
			return AdminAbuseUtils.Map.getMap(formatted)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function makeRigResolver(p: string)
			local v31 = nil
			return function()
				if v31 and v31:IsDescendantOf(Workspace) then
					return v31
				end

				local liveMap = getLiveMap() -- equivalent call inferred; original call site unknown
				local v32

				if liveMap then
					v32 = InstanceUtils.getPotentialInstance(liveMap, p)
				end

				v31 = v32
				return v31
			end
		end

		local rigResolver = makeRigResolver(Config.lokiiBossRigPath) -- equivalent call inferred; original call site unknown
		local rigResolver2 = makeRigResolver(Config.allanBossRigPath) -- equivalent call inferred; original call site unknown

		local function getPlatformZones()
			local liveMap = getLiveMap() -- equivalent call inferred; original call site unknown
			local v31

			if liveMap then
				v31 = InstanceUtils.getPotentialInstance(liveMap, Config.platformZonesPath)
			end

			local parts = {}

			if v31 then
				for _, part in v31:GetChildren() do
					if part:IsA("BasePart") then
						table.insert(parts, part)
					end
				end
			end

			return parts
		end

		local v31 = nil

		local function getKeycapsFolder()
			if v24 and v24.Parent then
				return v24
			end

			if v31 and v31.Parent then
				return v31
			end

			local liveMap = getLiveMap() -- equivalent call inferred; original call site unknown
			local v32

			if liveMap then
				v32 = liveMap:FindFirstChild(Config.keycapsFolderName, true)
			end

			v31 = v32
			return v31
		end

		local v32 = nil

		local function getVoidTrigger()
			if v32 and v32:IsDescendantOf(Workspace) then
				return v32
			end

			local liveMap = getLiveMap() -- equivalent call inferred; original call site unknown
			local part

			if liveMap then
				part = InstanceUtils.getPotentialInstance(liveMap, Config.voidTriggerPath)
			end

			if not (part and part:IsA("BasePart")) then
				part = nil
			end

			v32 = part
			return v32
		end

		local function relocateKeycapsToWorkspace(instance)
			if v24 then
				return
			end

			local child = instance:FindFirstChild(Config.keycapsFolderName, true)

			if not child then
				logger:warn((`No '{Config.keycapsFolderName}' folder in the live map — keycaps will not appear`))
				return
			end

			local parent = Workspace:FindFirstChild("Keycaps")

			if not parent then
				parent = Instance.new("Folder")
				parent.Name = "Keycaps"
				parent.Parent = Workspace
			end

			child.Name = formatted
			child.Parent = parent
			v24 = child
			data.janitor:Add(function()
				if v24 then
					v24:Destroy()
					v24 = nil
				end
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getLobbyDoor()
			local v33 = assert(lobbyDoorServer, "AllanBossRoom: LobbyDoorServer is unavailable on the server")
			local module2 = require(v33)
			return module2
		end

		local function moveLobbyPortal(flag3: boolean)
			if not isServer then
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

		local function returnPlayersInMapToSpawn(mapClone)
			local boundingBox, v33 = mapClone:GetBoundingBox()
			local v34 = assert(module, "AllanBossRoom: PlayerTeleport is unavailable on the server")

			for _, v35 in Players:GetPlayers() do
				local character = v35.Character

				if not (character ~= nil and SpacialQuery.isPointInVolume(
					character:GetPivot().Position,
					boundingBox,
					v33
				)) then
					continue
				end

				v34.toLobby(v35, "Event")
				local humanoid = character:FindFirstChildOfClass("Humanoid")

				if humanoid and humanoid.Health > 0 then
					humanoid.Health = humanoid.MaxHealth
				end
			end
		end

		local function isLokiiTaunting()
			return os.clock() < v14
		end

		local function isAllanTaunting()
			return os.clock() < v15
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getNpcBarriersFolder()
			local liveMap = getLiveMap() -- equivalent call inferred; original call site unknown

			if liveMap then
				return (InstanceUtils.getPotentialInstance(liveMap, Config.npcBarriersPath))
			end

			return nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function watchNpcCollision()
			if thread then
				return
			end

			Collision.setup(Config)
			thread = task.spawn(function()
				local v33 = os.clock() + 20
				local v34 = false
				local v35 = false
				local v36 = false

				while not (v34 and v35 and v36) and os.clock() < v33 do
					if not v34 then
						local v37 = rigResolver()

						if v37 then
							Collision.applyNpc(v37, Config)
							v34 = true
						end
					end

					if not v35 then
						local v37 = rigResolver2()

						if v37 then
							Collision.applyNpc(v37, Config)
							v35 = true
						end
					end

					if not v36 then
						local npcBarriersFolder = getNpcBarriersFolder() -- equivalent call inferred; original call site unknown

						if npcBarriersFolder then
							Collision.applyBarriers(npcBarriersFolder, Config)
							v36 = true
						end
					end

					if not (v34 and v35 and v36) then
						task.wait(0.5)
					end
				end

				if not v34 then
					logger:warn((`Never resolved the LokiiNPC rig at '{Config.lokiiBossRigPath}' — collision group not applied`))
				end

				if not v35 then
					logger:warn((`Never resolved the AllanNPC rig at '{Config.allanBossRigPath}' — collision group not applied`))
				end

				if not v36 then
					logger:warn((`No barrier folder at '{Config.npcBarriersPath}' — the NPCs rely on the floor check alone`))
				end

				thread = nil
			end)
		end

		local function makeJumpEmitter(p: string)
			return function(vector: Vector3, vector2: Vector3, p2: number, p3: number, color: Color3?)
				data.FireServerEventToAll({
					"Jump",
					p,
					vector,
					vector2,
					p2,
					p3,
					color
				})
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function startTauntLoop(p: string, data2, fn)
			table.insert(threads, task.spawn(function()
				while true do
					task.wait(data2.intervalMinSeconds + math.random() * (data2.intervalMaxSeconds - data2.intervalMinSeconds))

					if flag2 or data.elapsedSeconds < v2 then
						continue
					end

					local v33

					if v9 >= data2.roarChanceFromPhase then
						v33 = math.random() < data2.roarChance
					else
						v33 = false
					end

					local v35

					if v33 then
						v35 = data2.roarHoldSeconds
					else
						v35 = data2.laughHoldSeconds
					end

					fn(os.clock() + v35)
					data.FireServerEventToAll({ "Taunt", p, v33 and "Roar" or "Laugh" })
				end
			end))
		end

		local function startServerLoops()
			if v16 or v18 then
				return
			end

			watchNpcCollision() -- equivalent call inferred; original call site unknown
			local start = Movement.start
			local v33 = {
				getRig = rigResolver,
				getZones = getPlatformZones,
				isTaunting = isLokiiTaunting,
				onJump = 0,
				logger = 0,
				config = 0
			}
			local v34 = "Lokii"

			function v33.onJump(vector: Vector3, vector2: Vector3, p: number, p2: number, color: Color3?)
				data.FireServerEventToAll({
					"Jump",
					v34,
					vector,
					vector2,
					p,
					p2,
					color
				})
			end

			v33.logger = logger
			v33.config = Config
			v16 = start(v33)
			local start2 = Movement.start
			local v35 = {
				getRig = rigResolver2,
				getZones = getPlatformZones,
				isTaunting = isAllanTaunting,
				onJump = 0,
				logger = 0,
				config = 0
			}
			local v36 = "Allan"

			function v35.onJump(vector: Vector3, vector2: Vector3, p: number, p2: number, color: Color3?)
				data.FireServerEventToAll({
					"Jump",
					v36,
					vector,
					vector2,
					p,
					p2,
					color
				})
			end

			v35.logger = logger
			v35.config = Config
			v17 = start2(v35)
			v19 = KeycapRepairWins.start({
				config = Config.keycapRepairWins,
				awardWin = AAEventWinAward.create(Config.keycapRepairAward)
			})
			v18 = Keycaps.setup({
				getKeycapsFolder = getKeycapsFolder,
				getLokiiRig = rigResolver,
				getAllanRig = rigResolver2,
				config = Config,
				logger = logger,
				onPlayerRestoredKeycaps = function(p, p2: number)
					if v19 then
						v19.record(p, p2)
					end
				end
			})
			v22 = RigNametag.start({
				getLokiiRig = rigResolver,
				getAllanRig = rigResolver2,
				config = Config,
				logger = logger
			})
			local taunts = Config.taunts

			local function fn(p: number)
				v14 = p
			end

			startTauntLoop("Lokii", taunts, fn) -- equivalent call inferred; original call site unknown
			local allanTaunts = Config.allanTaunts

			local function fn2(p: number)
				v15 = p
			end

			startTauntLoop("Allan", allanTaunts, fn2) -- equivalent call inferred; original call site unknown
		end

		local function stopServerLoops()
			if v16 then
				v16.stop()
				v16 = nil
			end

			if v17 then
				v17.stop()
				v17 = nil
			end

			if v18 then
				v18.stop()
				v18 = nil
			end

			if v19 then
				v19.stop()
				v19 = nil
			end

			if v22 then
				v22.stop()
				v22 = nil
			end

			for _, v33 in threads do
				pcall(task.cancel, v33)
			end

			table.clear(threads)

			if thread then
				pcall(task.cancel, thread)
				thread = nil
			end
		end

		local v33 = false
		local v34 = false

		local function getRandomPlatformZone()
			local platformZones = getPlatformZones()

			if #platformZones == 0 then
				return nil
			end

			return platformZones[math.random(1, #platformZones)]
		end

		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Include

		local function hideKeycapsAroundImpact(vector: Vector3)
			local v35

			if v24 and v24.Parent then
				v35 = v24
			else
				if not (v31 and v31.Parent) then
					local liveMap = getLiveMap() -- equivalent call inferred; original call site unknown
					local v36

					if liveMap then
						v36 = liveMap:FindFirstChild(Config.keycapsFolderName, true)
					end

					v31 = v36
				end

				v35 = v31
			end

			if v35 then
				overlapParams.FilterDescendantsInstances = { v35 }

				for _, instance in Workspace:GetPartBoundsInRadius(
					vector,
					Config.meteorRainKeycapHideRadiusStuds,
					overlapParams
				) do
					if not CollectionService:HasTag(instance, Config.keycapTag) or CollectionService:HasTag(
						instance,
						Config.keycapHiddenTag
					) then
						continue
					end

					CollectionService:AddTag(instance, Config.keycapHiddenTag)
				end
			end
		end

		local function onMeteorImpactServer(vector: Vector3)
			hideKeycapsAroundImpact(vector)

			if resolved then
				resolved.breakNearPosition(vector, Config.meteorRainBridgeBreakRadiusStuds)
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

		local function buildAttackController(p: number)
			local v35 = MeteorRain.new(p, function()
				data.FireClientEvent({ "AttackHit", "MeteorRain" })
			end, onMeteorImpactServer, getRandomPlatformZone, function()
				if resolved then
					return (resolved.getRandomIntactTargetPosition())
				end

				return nil
			end)
			return Attacks.new({
				attacks = { v35 },
				attackDelaySeconds = Config.attackDelaySecondsByPhase[p],
				getZone = function(_: string)
					local platformZones = getPlatformZones()

					if #platformZones == 0 then
						return nil
					end

					return platformZones[math.random(1, #platformZones)]
				end,
				sendToClients = function(p2)
					data.FireServerEventToAll(p2)
				end
			})
		end

		local attackController = buildAttackController(v9)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function startAttacks()
			if isServer and not (v33 or v34) then
				v33 = true
				attackController.start(data.elapsedSeconds)
			end
		end

		local function stopAttacksForEnding()
			v34 = true
			attackController.stop()
		end

		local function isPlayerInArena(player)
			local liveMap = getLiveMap() -- equivalent call inferred; original call site unknown
			local character = player.Character

			if liveMap and character then
				local boundingBox, v35 = liveMap:GetBoundingBox()
				return SpacialQuery.isPointInVolume(character:GetPivot().Position, boundingBox, v35)
			else
				return false
			end
		end

		local function startWinOrbs()
			if isServer and not (v20 or v34) then
				v20 = floatingOrbWins.startServer({
					config = Config.floatingOrbWins,
					getSpawnZones = getPlatformZones,
					isPlayerEligible = isPlayerInArena,
					awardWin = AAEventWinAward.create(Config.floatingOrbWinsAward),
					sendSpawn = function(p, p2: string, vector: Vector3)
						data.FireServerEventToPlayer(p, { "WinOrbSpawn", p2, vector })
					end,
					sendDespawn = function(p, p2: string)
						data.FireServerEventToPlayer(p, { "WinOrbDespawn", p2 })
					end,
					logger = logger
				})
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopWinOrbs()
			if v20 then
				v20.stop()
				v20 = nil
			end
		end

		local function beginFight()
			startServerLoops()
			startAttacks() -- equivalent call inferred; original call site unknown
			startWinOrbs()

			if isServer and not elapsedSeconds then
				elapsedSeconds = data.elapsedSeconds
				data.FireServerEventToAll({ "FightStarted", elapsedSeconds })
			end
		end

		local function startBridgeRepair()
			if isServer and resolved and not v23 then
				v23 = BridgeRepair.start({
					config = Config.bridgeRepair,
					getBridges = function()
						return resolved
					end,
					isPlayerEligible = isPlayerInArena,
					awardWin = AAEventWinAward.create(Config.bridgeRepairAward),
					sendRingSpawn = function(p: string, p2: number, vector: Vector3, p3: number)
						data.FireServerEventToAll({
							"BridgeRingSpawn",
							p,
							p2,
							vector,
							p3
						})
					end,
					sendRingProgress = function(p: string, p2: number)
						data.FireServerEventToAll({ "BridgeRingProgress", p, p2 })
					end,
					sendRingDespawn = function(p: string)
						data.FireServerEventToAll({ "BridgeRingDespawn", p })
					end
				})
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopBridgeRepair()
			if v23 then
				v23.stop()
				v23 = nil
			end
		end

		local function fireAdminAnnounce(p)
			for _, bindableEvent in CollectionService:GetTagged("AdminAnnounceListener") do
				if bindableEvent:IsA("BindableEvent") and bindableEvent:IsDescendantOf(game) then
					bindableEvent:Fire(p)
				end
			end
		end

		local function showBossMessage(text: string, p2, value: number?)
			local dialogueSpeaker = Config.dialogueSpeakers[p2]
			fireAdminAnnounce({
				text = text,
				senderName = dialogueSpeaker.name,
				isOwner = false,
				icon = dialogueSpeaker.icon,
				Duration = value or 5
			})
		end

		local function showVoidCatchMessage()
			local voidCatchMessages = Config.voidCatchMessages
			local pinpin = Config.dialogueSpeakers.pinpin
			fireAdminAnnounce({
				text = voidCatchMessages[math.random(1, #voidCatchMessages)],
				senderName = pinpin.name,
				isOwner = false,
				icon = pinpin.icon,
				Duration = Config.voidCatchMessageDurationSeconds
			})
		end

		local function setup()
			if flag then
				return
			end

			flag = true
			local v35 = waitForLiveMap()

			if not v35 then
				logger:warn((`Timed out waiting for live map '{formatted}'`))
				return
			end

			local scriptables = v35:FindFirstChild("Scriptables")

			if scriptables then
				local potentialInstance = InstanceUtils.getPotentialInstance(v35, Config.lokiiBossRigPath)
				local potentialInstance2 = InstanceUtils.getPotentialInstance(v35, Config.allanBossRigPath)
				local potentialInstance3 = InstanceUtils.getPotentialInstance(v35, Config.bridgesGroupPath)

				for _, part in scriptables:GetDescendants() do
					local v36 = potentialInstance ~= nil and part:IsDescendantOf(potentialInstance) or potentialInstance2 ~= nil and part:IsDescendantOf(potentialInstance2)

					if not v36 then
						if potentialInstance3 == nil then
							v36 = false
						else
							v36 = part:IsDescendantOf(potentialInstance3)
						end
					end

					if not part:IsA("BasePart") or v36 then
						continue
					end

					part.Transparency = 1
				end
			end

			if isServer then
				relocateKeycapsToWorkspace(v35)
				resolved = Bridges.resolve(v35, Config)

				if not resolved then
					logger:warn((`No bridge group at '{Config.bridgesGroupPath}' — MeteorRain will not break bridges`))
				end

				startBridgeRepair()
				data.FireServerEventToAll({ "ForceSetup" })
			else
				KeycapVisibilityClient.start(Config.keycapHiddenTag)
				v25 = VoidCatch.start({
					getVoidTrigger = getVoidTrigger,
					onCaught = showVoidCatchMessage,
					logger = logger,
					safeMarginStuds = Config.voidCatchSafeMarginStuds,
					standingHistorySeconds = Config.voidCatchStandingHistorySeconds
				})
				v21 = floatingOrbWins.startClient({
					config = Config.floatingOrbWins,
					requestCollect = function(p: string)
						data.FireClientEvent({ "WinOrbCollect", p })
					end,
					logger = logger
				})
				local v36 = NpcJumpClient.start({
					getRig = rigResolver
				})
				local v37 = NpcJumpClient.start({
					getRig = rigResolver2
				})
				v29 = v36
				v30 = v37
				v27 = NpcAnimationClient.start({
					getRig = rigResolver,
					isJumping = function()
						return v36.isJumping()
					end,
					config = Config
				})
				v28 = NpcAnimationClient.start({
					getRig = rigResolver2,
					isJumping = function()
						return v37.isJumping()
					end,
					config = {
						walkAnimation = Config.allanWalkAnimation,
						idleAnimation = Config.allanIdleAnimation,
						walkAnimationMinSpeed = Config.walkAnimationMinSpeed,
						taunts = Config.allanTaunts
					}
				})

				if not data.isCatchUp then
					Cutscenes.playOpening(v35, Config, showBossMessage, function(flag3: boolean)
						if flag3 then
							data.FireClientEvent({ "IntroCutsceneFinished" })
						end
					end)
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cancelOpeningPromise()
			if v11 then
				v11:cancel()
				v11 = nil
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function registerMapCleanup(p)
			data.janitor:Add(function()
				if v10 == p then
					Cutscenes.releaseRigs()
					AdminAbuseUtils.Map.removeMap(p)
					v10 = nil
				end
			end)
		end

		local function beginOpeningSequence(p)
			local lobbyDoor = getLobbyDoor() -- equivalent call inferred; original call site unknown
			local v35 = p.mapLoaded:andThen(function()
				if v10 ~= p then
					return
				end

				setup()

				if not data.isCatchUp then
					return Promise.delay(v):andThen(function()
						if v10 == p then
							lobbyDoor.open(false)
						end
					end)
				end

				lobbyDoor.open(true)
			end):catch(function(p2)
				logger:warn((`Opening sequence failed: {tostring(p2)}`))
			end)
			v11 = v35
			data.janitor:Add(function()
				v35:cancel()

				if v11 == v35 then
					v11 = nil
				end
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function playPhaseMusic(p: number)
			local v35 = Config.soundtracksByPhase[p]

			if v35 then
				AdminAbuseUtils.Musics.play(v35)
			end
		end

		local function setPhase(p: number)
			if v9 == p then
				return
			end

			v9 = p

			if isServer then
				attackController.cleanup()
				attackController = buildAttackController(p)

				if v33 and not v34 then
					attackController.start(data.elapsedSeconds)
				end
			else
				playPhaseMusic(p) -- equivalent call inferred; original call site unknown
			end
		end

		local function startEndingCutscene()
			if flag2 then
				return
			end

			flag2 = true

			if not isServer then
				data.janitor:Add(task.spawn(function()
					local liveMap = getLiveMap() -- equivalent call inferred; original call site unknown

					if liveMap then
						Cutscenes.playEnding(liveMap, Config, showBossMessage, function()
							Credits.play()
						end)
					else
						Credits.play()
					end
				end))
				return
			end

			local v35 = (v13 or Config.endingCutsceneFallbackSeconds) + v7 + Config.endingTeardownGraceSeconds
			data.janitor:Add(task.delay(v35, function()
				if not v12 then
					v12 = true
					local v36, v37 = parentModule.stopModuleLocally(data.name, "durationElapsed")

					if not v36 then
						logger:warn((`Failed to stop after the ending cutscene: {v37 or "unknown error"}`))
					end
				end
			end))
		end

		local function stopClient(p)
			local module2 = require(assert(adminAbuseTransition))
			module2.cancel()

			if p ~= "shutdown" then
				module2.play(nil, {
					skip = false,
					skipDoor = true
				})
			end
		end

		local function stopServer(p)
			cancelOpeningPromise() -- equivalent call inferred; original call site unknown
			stopServerLoops()
			;(getLobbyDoor()).close(false)
			moveLobbyPortal(false)
			local v35 = v10

			if not v35 then
				return
			end

			if p ~= "shutdown" then
				parentModule.remotes.Deactivated:fireAll(data.name, p)
				task.wait(AdminAbuseDoorConfig.TransitionBlackIn or 0)
				returnPlayersInMapToSpawn(v35.mapClone)
			end

			local v36 = AdminAbuseUtils.Map.removeMap(v35)

			if v36 then
				local v37, v38 = v36:await()

				if not v37 then
					logger:warn((`Failed to remove the event map: {tostring(v38)}`))
				end
			end

			if v10 == v35 then
				v10 = nil
			end
		end

		local function onStart()
			sequence.Start(data.elapsedSeconds)

			if isServer then
				moveLobbyPortal(true)
				TesterNametag.start()
				data.janitor:Add(function()
					moveLobbyPortal(false)
				end)
				data.janitor:Add(task.spawn(function()
					local success, result = pcall(Cutscenes.getEndingDurationSeconds, Config)

					if success then
						v13 = result
					else
						logger:warn((`Failed to resolve ending cutscene duration: {result}`))
					end
				end))
				local v35 = AdminAbuseUtils.Map.addMap({
					templateName = Config.mapTemplateName,
					liveName = formatted,
					prepareSource = function(p, cframe: CFrame)
						Cutscenes.extractRigs(p, Config, cframe)
					end
				})
				assert(v35, "AllanBossRoom map placement unexpectedly returned nil on the server")
				v10 = v35
				registerMapCleanup(v35) -- equivalent call inferred; original call site unknown
				beginOpeningSequence(v35)
			else
				local v35 = assert(
					assert(Players.LocalPlayer, "AllanBossRoom: Players.LocalPlayer was not found"):FindFirstChildOfClass("PlayerGui"),
					"AllanBossRoom: PlayerGui was not found"
				)
				v26 = TopBanner.mount(v35, {
					icon = Config.topBanner.icon
				})
				data.janitor:Add(function()
					if v26 then
						v26.destroy()
						v26 = nil
					end
				end)
			end
		end

		sequence = AdminAbuseUtils.Sequence.new()
		sequence.push(0, "client", function()
			playPhaseMusic(1) -- equivalent call inferred; original call site unknown
		end, true)
		sequence.push(v3, "both", function()
			if v9 == 2 then
				return
			end

			v9 = 2

			if isServer then
				attackController.cleanup()
				attackController = buildAttackController(2)

				if v33 and not v34 then
					attackController.start(data.elapsedSeconds)
				end
			else
				playPhaseMusic(2) -- equivalent call inferred; original call site unknown
			end
		end, true)
		sequence.push(v4, "both", function()
			if v9 == 3 then
				return
			end

			v9 = 3

			if isServer then
				attackController.cleanup()
				attackController = buildAttackController(3)

				if v33 and not v34 then
					attackController.start(data.elapsedSeconds)
				end
			else
				playPhaseMusic(3) -- equivalent call inferred; original call site unknown
			end
		end, true)
		sequence.push(v2, "server", beginFight, true)
		sequence.push(v5, "server", stopAttacksForEnding, true)
		sequence.push(v5, "server", stopWinOrbs, true)
		sequence.push(v6, "server", stopServerLoops, true)
		sequence.push(v6, "both", startEndingCutscene, true)
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
			stopServerLoops()
		end)
		data.janitor:Add(function()
			TesterNametag.stop()
		end)
		data.janitor:Add(function()
			KeycapVisibilityClient.stop()
		end)
		data.janitor:Add(function()
			if v25 then
				v25.stop()
				v25 = nil
			end
		end)
		data.janitor:Add(function()
			if v27 then
				v27.stop()
				v27 = nil
			end

			if v28 then
				v28.stop()
				v28 = nil
			end
		end)
		data.janitor:Add(function()
			if v29 then
				v29.stop()
				v29 = nil
			end

			if v30 then
				v30.stop()
				v30 = nil
			end
		end)
		data.janitor:Add(function()
			LandingDebris.cleanup()
		end)
		data.janitor:Add(function()
			attackController.cleanup()
		end)
		data.janitor:Add(function()
			stopWinOrbs() -- equivalent call inferred; original call site unknown
		end)
		data.janitor:Add(function()
			if v21 then
				v21.stop()
				v21 = nil
			end
		end)
		data.janitor:Add(function()
			stopBridgeRepair() -- equivalent call inferred; original call site unknown
		end)
		data.janitor:Add(function()
			if resolved then
				resolved.stop()
				resolved = nil
			end
		end)
		data.janitor:Add(function()
			BridgeRings.cleanup()
		end)
		return {
			onStart = onStart,
			onStop = function(p)
				if isServer then
					stopServer(p)
				else
					stopClient(p)
				end
			end,
			onUpdate = function()
				sequence.Run(data.elapsedSeconds)

				if isServer then
					attackController.update(data.elapsedSeconds)
					return
				end

				if v27 then
					v27.update()
				end

				if v28 then
					v28.update()
				end

				if v26 then
					local v35 = elapsedSeconds or v2
					local v36 = (data.elapsedSeconds - v35) / (v5 - v35)
					v26.update(v36, v35 <= data.elapsedSeconds and data.elapsedSeconds < v6)
				end
			end,
			onServerEvent = function(list)
				attackController.handleServerEvent(list)

				if type(list) ~= "table" then
					return
				end

				if list[1] == "ForceSetup" then
					setup()
				elseif list[1] == "FightStarted" and typeof(list[2]) == "number" then
					elapsedSeconds = list[2]
				elseif list[1] == "Taunt" and (list[3] == "Laugh" or list[3] == "Roar") then
					local v35

					if list[2] == "Allan" then
						v35 = v28
					else
						v35 = v27
					end

					if v35 then
						v35.playTaunt(list[3])
					end
				elseif list[1] == "Jump" and typeof(list[3]) == "Vector3" and typeof(list[4]) == "Vector3" then
					local v35

					if list[2] == "Allan" then
						v35 = v30
					else
						v35 = v29
					end

					if v35 then
						local v36 = list[4]
						local v37

						if typeof(list[7]) == "Color3" then
							v37 = list[7]
						else
							v37 = nil
						end

						v35.playJump(list[3], v36, list[5], list[6], function()
							LandingDebris.burst(v36, v37, Config.landingDebris)
						end)
					end
				elseif list[1] == "WinOrbSpawn" and typeof(list[2]) == "string" and typeof(list[3]) == "Vector3" then
					if v21 then
						v21.handleSpawn(list[2], list[3])
					end
				elseif list[1] == "WinOrbDespawn" and typeof(list[2]) == "string" then
					if v21 then
						v21.handleDespawn(list[2])
					end
				elseif list[1] == "BridgeRingSpawn" and typeof(list[2]) == "string" and typeof(list[3]) == "number" and typeof(list[4]) == "Vector3" and typeof(list[5]) == "number" then
					BridgeRings.handleSpawn(list[2], list[3], list[4], list[5])
				elseif list[1] == "BridgeRingProgress" and typeof(list[2]) == "string" and typeof(list[3]) == "number" then
					BridgeRings.handleProgress(list[2], list[3])
				elseif list[1] == "BridgeRingDespawn" and typeof(list[2]) == "string" then
					BridgeRings.handleDespawn(list[2])
				end
			end,
			onClientEvent = function(player, list)
				if type(list) ~= "table" then
					return
				end

				if list[1] == "AttackHit" and list[2] == "MeteorRain" then
					damagePlayer(player, Config.meteorRainAttackConfigs[v9].damage) -- equivalent call inferred; original call site unknown
				elseif list[1] == "IntroCutsceneFinished" then
					beginFight()
				elseif list[1] == "WinOrbCollect" and typeof(list[2]) == "string" and v20 then
					v20.handleCollect(player, list[2])
				end
			end,
			onPlayerAdded = function(p)
				if isServer and flag then
					data.FireServerEventToPlayer(p, { "ForceSetup" })

					if elapsedSeconds then
						data.FireServerEventToPlayer(p, { "FightStarted", elapsedSeconds })
					end

					if v23 then
						v23.resync()
					end
				end
			end
		}
	end
})
return nil