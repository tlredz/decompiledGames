local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local Config = require(script.Config)
local Cutscenes = require(script.Cutscenes)
local BossProgressBar = require(script.BossProgressBar)
local UnderwaterLighting = require(script.UnderwaterLighting)
local WinRing = require(script.WinRing)
local Attacks = require(script.Attacks)
local SharkRain = require(script.Attacks.SharkRain)
local CrabTsunami = require(script.Attacks.CrabTsunami)
local SandCastle = require(script.Attacks.SandCastle)
local parentModule = require(script.Parent.Parent)
local AdminAbuseUtils = require(script.Parent.Parent.AdminAbuseUtils)
local InstanceUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.InstanceUtils)
local SpacialQuery = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.SpacialQuery)
local AdminAbuseDoorConfig = require(ReplicatedStorage.Shared.AdminAbuseDoorConfig)
local Promise = require(ReplicatedStorage.Utilities.Promise)
local v = (AdminAbuseDoorConfig.TransitionBlackIn or 0) + (AdminAbuseDoorConfig.TransitionBlackHold or 0) + (AdminAbuseDoorConfig.TransitionApproachSeconds or 0) + (AdminAbuseDoorConfig.LobbyDoorOpenExtraDelaySec or 0)
local idleBossAnimation = Config.idleBossAnimation
local v2 = math.max(0, Config.winRingFillSeconds * 0.75)
parentModule.register(script.Name, {
	displayName = "Summer Boss Event (August 15th)",
	slot = "main",
	defaultDurationSeconds = 720,
	needsDuration = false,
	load = function(data)
		local v3 = nil
		local v4 = nil
		local flag = false
		local adminAbuseTransition = nil
		local lobbyDoorServer = nil
		local module = nil
		local module2 = nil
		local module3 = nil
		local module4 = nil
		local v5 = {}
		local sequence = nil
		local v6 = nil
		local v7 = nil
		local parts = {}
		local flag2 = false
		local v8 = false
		local v9 = nil
		local v10 = false
		local v11 = nil
		local v12 = nil
		local v13 = nil
		Config.attackConfigIndex = 1

		if RunService:IsServer() then
			local server = ServerScriptService:FindFirstChild("Server")

			if server then
				lobbyDoorServer = server:FindFirstChild("LobbyDoorServer")
			else
				lobbyDoorServer = nil
			end

			assert(lobbyDoorServer and lobbyDoorServer:IsA("ModuleScript"), "Server.LobbyDoorServer was not found")
			local dataManager = ServerScriptService:FindFirstChild("DataManager")
			assert(dataManager and dataManager:IsA("ModuleScript"), "ServerScriptService.DataManager was not found")
			module = require(dataManager)
			local boostsManager = ServerScriptService:FindFirstChild("BoostsManager")
			assert(
				boostsManager and boostsManager:IsA("ModuleScript"),
				"ServerScriptService.BoostsManager was not found"
			)
			module2 = require(boostsManager)
			local bonusManager = ReplicatedStorage:FindFirstChild("BonusManager")
			assert(bonusManager and bonusManager:IsA("ModuleScript"), "ReplicatedStorage.BonusManager was not found")
			module3 = require(bonusManager)
			local config = ReplicatedStorage:FindFirstChild("Config")
			assert(config and config:IsA("ModuleScript"), "ReplicatedStorage.Config was not found")
			module4 = require(config)
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

			local summerBossAA_August15th_Live

			if map then
				summerBossAA_August15th_Live = map:WaitForChild("SummerBossAA_August15th_Live", 10)
			end

			if summerBossAA_August15th_Live and summerBossAA_August15th_Live:IsA("Model") then
				return summerBossAA_August15th_Live
			end

			return nil
		end

		local function returnPlayersInMapToSpawn(mapClone)
			local boundingBox, v14 = mapClone:GetBoundingBox()

			for _, v15 in Players:GetPlayers() do
				local character = v15.Character

				if not (character ~= nil and SpacialQuery.isPointInVolume(
					character:GetPivot().Position,
					boundingBox,
					v14
				)) then
					continue
				end

				local v16 = v15
				local success, result = pcall(function()
					v16:LoadCharacterAsync()
				end)

				if not success then
					warn((`[SummerBossEvent_August15th] Failed to return {v15.Name} to spawn: {tostring(result)}`))
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

		local function showCutsceneMaskedMessage(text: string)
			showMaskedMessage({
				text = text,
				senderName = "The Mask",
				senderUserId = 1,
				isOwner = false,
				icon = "rbxassetid://74389556285578",
				Duration = 5
			})
		end

		local function setup()
			if flag then
				return
			end

			flag = true
			local parent = waitForLiveMap()

			if not parent then
				warn("[SummerBossEvent_August15th] Timed out waiting for live map 'SummerBossAA_August15th_Live'")
				return
			end

			local v15 = nil

			if RunService:IsClient() then
				v15 = InstanceUtils.waitForPotentialInstance(parent, "Scriptables/BossSpawnPart")
				v6 = InstanceUtils.waitForPotentialInstance(parent, "Scriptables/WinArea")
			else
				v7 = InstanceUtils.waitForPotentialInstance(parent, "Scriptables/AttackArea")

				if not v7 then
					warn("[SummerBossEvent_August15th] setup: Scriptables/AttackArea not found under 'SummerBossAA_August15th_Live' (SharkRain and SandCastle's zone depend on this)")
				end

				local v16 = InstanceUtils.waitForPotentialInstance(parent, "Scriptables/TsunamiSpawns")

				if v16 then
					for _, part in v16:GetChildren() do
						if part:IsA("BasePart") then
							table.insert(parts, part)
						end
					end
				else
					warn("[SummerBossEvent_August15th] setup: Scriptables/TsunamiSpawns not found under 'SummerBossAA_August15th_Live' (CrabTsunami's zone depends on this)")
				end

				print((`[SummerBossEvent_August15th] setup: attackAreaPart found={v7 ~= nil}, tsunamiSpawnParts count={#parts}`))
			end

			local scriptables = parent:FindFirstChild("Scriptables")

			if scriptables then
				for _, folder in scriptables:QueryDescendants("BasePart") do
					folder.Transparency = 1

					if folder.Name == "FXPortal1" or folder.Name == "FXPortal2" then
						for _, emitter in folder:GetDescendants() do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					else
						folder:ClearAllChildren()
					end
				end
			end

			if RunService:IsClient() then
				local clone = ReplicatedStorage.AdminAbuse.SummerBossEvent_August15th.Assets.TheMasked:Clone()
				v11 = clone
				clone:PivotTo(v15.CFrame)
				clone.Parent = parent
				AdminAbuseUtils.Animations.loadAnimation(clone, idleBossAnimation):Play(0)

				if not (data.isCatchUp or Config.skipOpeningCutscene) then
					clone.Parent = nil
					Cutscenes.playOpening(parent, function()
						if clone == v11 and parent.Parent then
							clone.Parent = parent
						end
					end, showCutsceneMaskedMessage)
				end
			else
				data.FireServerEventToAll({ "ForceSetup" })
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getLobbyDoor()
			local v14 = assert(lobbyDoorServer, "LobbyDoorServer is unavailable on the server")
			local module5 = require(v14)
			return module5
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cancelOpeningPromise()
			if v4 then
				v4:cancel()
				v4 = nil
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
				if v3 == p then
					AdminAbuseUtils.Map.removeMap(p)
					v3 = nil
				end
			end)
		end

		local function beginOpeningSequence(p)
			local lobbyDoor = getLobbyDoor() -- equivalent call inferred; original call site unknown
			local v14 = p.mapLoaded:andThen(function()
				if v3 ~= p then
					return
				end

				setup()

				if not data.isCatchUp then
					return Promise.delay(v):andThen(function()
						if v3 == p then
							lobbyDoor.open(false)
						end
					end)
				end

				lobbyDoor.open(true)
			end):catch(function(p2)
				warn((`[SummerBossEvent_August15th] Opening sequence failed: {tostring(p2)}`))
			end)
			v4 = v14
			data.janitor:Add(function()
				v14:cancel()

				if v4 == v14 then
					v4 = nil
				end
			end)
		end

		local function onStart()
			sequence.Start(data.elapsedSeconds)

			if RunService:IsClient() then
				local v14 = assert(
					assert(Players.LocalPlayer, "Players.LocalPlayer was not found"):FindFirstChildOfClass("PlayerGui"),
					"PlayerGui was not found"
				)
				v12 = BossProgressBar.mount(v14)
				data.janitor:Add(function()
					if v12 then
						v12.destroy()
						v12 = nil
					end
				end)
				v13 = UnderwaterLighting.apply()
				data.janitor:Add(function()
					if v13 then
						v13.destroy()
						v13 = nil
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
						v9 = result
					else
						warn((`[SummerBossEvent_August15th] Failed to resolve ending cutscene duration: {result}`))
					end
				end))
				local v14 = AdminAbuseUtils.Map.addMap({
					templateName = "SummerBossAA_August15th",
					liveName = "SummerBossAA_August15th_Live",
					streamedKeycapsFolderName = "SummerBossEvent_August15th_Keycaps"
				})
				assert(v14, "SummerBossEvent_August15th map placement unexpectedly returned nil on the server")
				v3 = v14
				registerMapCleanup(v14) -- equivalent call inferred; original call site unknown
				beginOpeningSequence(v14)
			end
		end

		local function stopClient(p)
			local v14 = assert(adminAbuseTransition, "AdminAbuseTransition is unavailable on the client")
			local module5 = require(v14)
			module5.cancel()

			if p ~= "shutdown" then
				module5.play(nil, {
					skip = false,
					skipDoor = true
				})
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function removeMap(p)
			local v14 = AdminAbuseUtils.Map.removeMap(p)

			if v14 then
				local v15, v16 = v14:await()

				if not v15 then
					warn((`[SummerBossEvent_August15th] Failed to remove the event map: {tostring(v16)}`))
				end
			end

			if v3 == p then
				v3 = nil
			end
		end

		local function stopServer(p)
			cancelOpeningPromise() -- equivalent call inferred; original call site unknown
			;(getLobbyDoor()).close(false)
			moveLobbyPortal(false)
			local v14 = v3

			if not v14 then
				return
			end

			if p ~= "shutdown" then
				parentModule.remotes.Deactivated:fireAll(data.name, p)
				task.wait(AdminAbuseDoorConfig.TransitionBlackIn or 0)
				returnPlayersInMapToSpawn(v14.mapClone)
			end

			removeMap(v14) -- equivalent call inferred; original call site unknown
		end

		local v14 = {}
		local v15 = {}
		local v16 = {}
		local flag3 = false

		local function getWorldXZSize(instance)
			local cFrame = instance.CFrame
			local size = instance.Size
			local v17 = math.abs(cFrame.RightVector.X) * size.X + math.abs(cFrame.UpVector.X) * size.Y + math.abs(cFrame.LookVector.X) * size.Z
			local v18 = math.abs(cFrame.RightVector.Z) * size.X + math.abs(cFrame.UpVector.Z) * size.Y + math.abs(cFrame.LookVector.Z) * size.Z
			return (Vector3.new(v17, size.Y, v18))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getWinAreaPart()
			if v6 and v6.Parent then
				return v6
			end

			return nil
		end

		local function getAttackAreaPart()
			if v7 and v7.Parent then
				return v7
			end

			return nil
		end

		local function getTsunamiSpawnPart()
			if #parts == 0 then
				return nil
			end

			return parts[math.random(1, #parts)]
		end

		local attackConfigIndex = Config.attackConfigIndex
		local v17 = false

		local function createAttackController(p: number)
			local attackDelaySeconds = Config.attackDelaySecondsByPhase[p]
			assert(attackDelaySeconds ~= nil, (`Missing attack delay for SummerBossEvent_August15th phase {p}`))
			local v19 = SharkRain.new(p, function()
				data.FireClientEvent({ "AttackHit", "SharkRain" })
			end)
			local v20 = CrabTsunami.new(p, function()
				data.FireClientEvent({ "AttackHit", "CrabTsunami" })
			end)
			local v21 = SandCastle.new(p, function()
				data.FireClientEvent({ "AttackHit", "SandCastle" })
			end)
			return Attacks.new({
				attacks = { v19, v20, v21 },
				attackDelaySeconds = attackDelaySeconds,
				getZone = function(p2: string)
					if p2 == "CrabTsunami" then
						if #parts == 0 then
							return nil
						end

						return parts[math.random(1, #parts)]
					elseif v7 and v7.Parent then
						return v7
					else
						return nil
					end
				end,
				sendToClients = function(p2)
					data.FireServerEventToAll(p2)
				end
			})
		end

		local attackController = createAttackController(attackConfigIndex)

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

			if RunService:IsServer() or not winRingConfig or v14[p] or v15[p] then
				return
			end

			v15[p] = true
			data.janitor:Add(task.spawn(function()
				local v18 = waitForLiveMap()
				local v19

				if v18 then
					v19 = InstanceUtils.waitForPotentialInstance(v18, "Scriptables/WinArea")
				end

				if v19 then
					v6 = v19
					local v20 = WinRing.new({
						position = v19.Position,
						radius = winRingConfig.radius,
						winMultiplier = winRingConfig.winMultiplier,
						fillDurationSeconds = Config.winRingFillSeconds,
						depleteDurationSeconds = Config.winRingDepleteSeconds,
						onWin = function()
							data.FireClientEvent({ "AwardWin", p })
						end
					})
					v14[p] = v20
					v15[p] = nil
					local spawn = v20.Spawn
					local v21

					if flag4 == nil then
						v21 = not data.isCatchUp
					else
						v21 = flag4
					end

					spawn(v21)

					if flag3 then
						startWinRingMovement(v20, v19, p) -- equivalent call inferred; original call site unknown
					end
				else
					v15[p] = nil
					warn("[SummerBossEvent_August15th] Timed out waiting for WinArea")
				end
			end))
		end

		local function awardWin(player, p: number)
			local winRingConfig = Config.winRingConfigs[p]

			if not (winRingConfig and v16[p]) then
				return
			end

			local now = os.clock()
			local nows = v5[player]

			if not nows then
				nows = {}
				v5[player] = nows
			end

			local v18 = nows[p]

			if v18 and now - v18 < v2 then
				return
			end

			nows[p] = now
			local v19 = assert(module, "DataManager is unavailable on the server")
			local v20 = assert(module2, "BoostsManager is unavailable on the server")
			local v21 = assert(module3, "BonusManager is unavailable on the server")
			local DEPRECATED_BOSS_WIN_TIERS = assert(module4, "World config is unavailable on the server").DEPRECATED_BOSS_WIN_TIERS
			assert(#DEPRECATED_BOSS_WIN_TIERS > 0, "World config has no boss win tiers")
			local v22 = v19.LevelCache[player.UserId] or 1
			local wins = DEPRECATED_BOSS_WIN_TIERS[#DEPRECATED_BOSS_WIN_TIERS].wins

			for _, v24 in DEPRECATED_BOSS_WIN_TIERS do
				if not (v22 <= v24.maxLevel) then
					continue
				end

				wins = v24.wins
				break
			end

			local v24 = math.max(1, (math.ceil(wins / Config.winRingAwardDivisor)))
			local v25 = v20.HasWinsBoost(v20, player) and 2 or 1
			local winsMultiplier = v21.GetWinsMultiplier(v21, player)
			local v26 = v24 * v25 * winsMultiplier * winRingConfig.winMultiplier
			v19:IncrementStat(player, "Wins", v26, {
				source = "SummerBossEvent_August15th:WinRing"
			})
			local remotes = ReplicatedStorage:FindFirstChild("Remotes")
			local showWin = remotes and remotes:FindFirstChild("ShowWin")

			if showWin and showWin:IsA("RemoteEvent") then
				showWin:FireClient(player, v26)
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

			if not v14[1] then
				spawnWinRing(1)
			end

			local v18 = v14[1]
			local winAreaPart = getWinAreaPart() -- equivalent call inferred; original call site unknown

			if not (v18 and winAreaPart) then
				return
			end

			startWinRingMovement(v18, winAreaPart, 1) -- equivalent call inferred; original call site unknown
		end

		local function startAttacks()
			if RunService:IsServer() then
				v17 = true
				attackController.start(data.elapsedSeconds)
			end
		end

		local function setAttackConfig(p: number)
			if attackConfigIndex == p then
				return
			end

			attackController.cleanup()
			attackConfigIndex = p
			attackController = createAttackController(p)

			if RunService:IsServer() and v17 and not v10 then
				attackController.start(data.elapsedSeconds)
			end
		end

		local function stopAttacksForEnding()
			if RunService:IsServer() and not v10 then
				v10 = true
				attackController.stop()
			end
		end

		local function startEndingCutscene()
			if flag2 then
				return
			end

			flag2 = true

			if RunService:IsServer() then
				attackController.cleanup()
				local v18 = v9 or Config.endingCutsceneLeadSeconds
				local thread = task.delay(v18, function()
					if flag2 and not v8 then
						v8 = true
						local v19, v20 = parentModule.stopModuleLocally(data.name, "durationElapsed")

						if not v19 then
							warn((`[SummerBossEvent_August15th] Failed to stop locally after the ending cutscene: {v20 or "unknown error"}`))
						end
					end
				end)
				data.janitor:Add(thread)
			else
				AdminAbuseUtils.Musics.play(Config.beachAmbiance, {
					fadeDuration = Config.endingMusicCrossfadeSeconds
				})

				if v11 then
					v11.Parent = nil
				end

				for k, v18 in v14 do
					v18.destroy()
					v14[k] = nil
				end

				local map = AdminAbuseUtils.Map.getMap("SummerBossAA_August15th_Live")

				if map then
					Cutscenes.playEnding(map, nil, showCutsceneMaskedMessage)
				else
					warn("[SummerBossEvent_August15th] Could not play the ending cutscene because the live map was unavailable")
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
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
			sendAdminMessage(text, value, "The Mask", 1, "rbxassetid://74389556285578") -- equivalent call inferred; original call site unknown
		end

		local function sendCharacterMessage(text: string, value: number?, senderName: string, senderUserId: number)
			sendAdminMessage(text, value, senderName, senderUserId, nil) -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function playMusic(p: number)
			AdminAbuseUtils.Musics.play(p)
		end

		if RunService:IsClient() then
			local SFX = ReplicatedStorage.AdminAbuse.SummerBossEvent_August15th.SFX
			data.janitor:Add(task.spawn(function()
				local success, result = pcall(function()
					ContentProvider:PreloadAsync({
						SFX.PortalOpen,
						SFX.PortalClose,
						SFX.Swing1,
						SFX.SandCastleAppear
					})
				end)

				if not success then
					warn((`[SummerBossEvent_August15th] Failed to preload cutscene and Sand Castle SFX: {result}`))
				end
			end))
		end

		local sequenceOffset = Config.sequenceOffset
		sequence = AdminAbuseUtils.Sequence.new()
		sequence.push(0, "client", function()
			playMusic(Config.beachAmbiance) -- equivalent call inferred; original call site unknown
		end, true)
		sequence.push(sequenceOffset, "client", function()
			showMaskedMessage({
				text = "So i heard you liked the wins?",
				senderName = "The Mask",
				senderUserId = 1,
				isOwner = false,
				icon = "rbxassetid://74389556285578",
				Duration = 3
			})
		end)
		sequence.push(sequenceOffset + 4, "client", function()
			showMaskedMessage({
				text = "Even under this summer heat..",
				senderName = "The Mask",
				senderUserId = 1,
				isOwner = false,
				icon = "rbxassetid://74389556285578",
				Duration = 3
			})
		end)
		sequence.push(sequenceOffset + 8, "client", function()
			showMaskedMessage({
				text = "Those who possess speed never fail to find a way to cool off.",
				senderName = "The Mask",
				senderUserId = 1,
				isOwner = false,
				icon = "rbxassetid://74389556285578",
				Duration = 4
			})
		end)
		sequence.push(sequenceOffset + 13, "client", function()
			showMaskedMessage({
				text = "Let's make this swim a little more exciting.",
				senderName = "The Mask",
				senderUserId = 1,
				isOwner = false,
				icon = "rbxassetid://74389556285578",
				Duration = 4
			})
		end)
		sequence.push(sequenceOffset + 14, "client", function()
			spawnWinRing(1)
		end, true)
		sequence.push(sequenceOffset + 14, "server", function()
			v16[1] = true
		end, true)
		sequence.push(sequenceOffset + 18, "client", function()
			showMaskedMessage({
				text = "For those who missed it..",
				senderName = "The Mask",
				senderUserId = 1,
				isOwner = false,
				icon = "rbxassetid://74389556285578",
				Duration = 2
			})
		end)
		sequence.push(sequenceOffset + 21, "client", function()
			showMaskedMessage({
				text = "Stay inside the circle.",
				senderName = "The Mask",
				senderUserId = 1,
				isOwner = false,
				icon = "rbxassetid://74389556285578",
				Duration = 2.5
			})
		end)
		sequence.push(sequenceOffset + 25, "client", function()
			showMaskedMessage({
				text = "Everything else... is entirely your problem.",
				senderName = "The Mask",
				senderUserId = 1,
				isOwner = false,
				icon = "rbxassetid://74389556285578",
				Duration = 3.5
			})
		end)
		sequence.push(sequenceOffset + 30, "client", function()
			showMaskedMessage({
				text = "Let's begin.",
				senderName = "The Mask",
				senderUserId = 1,
				isOwner = false,
				icon = "rbxassetid://74389556285578",
				Duration = 2.5
			})
		end)
		sequence.push(sequenceOffset + 35, "client", function()
			flag3 = true

			if not RunService:IsServer() then
				if not v14[1] then
					spawnWinRing(1)
				end

				local v18 = v14[1]
				local winAreaPart = getWinAreaPart() -- equivalent call inferred; original call site unknown
				local v19 = v18 and winAreaPart and Config.winRingConfigs[1]

				if v19 then
					v18.startMovement(
						winAreaPart.Position,
						getWorldXZSize(winAreaPart),
						Config.sequenceOffset + 35,
						Config.winRingMovementSeed + 1 - 1,
						v19.movementSpeed
					)
				end
			end

			playMusic(Config.bossMusic) -- equivalent call inferred; original call site unknown
		end, true)
		sequence.push(sequenceOffset + 35, "server", startAttacks, true)
		local v18 = math.max(0, (data.durationSeconds or 900) - Config.endingCutsceneLeadSeconds)
		local v19 = math.max(0, v18 - Config.endingAttackCooldownSeconds)
		local v20 = sequenceOffset + 35
		local v21 = math.max(0, v19 - v20)
		local v22 = v20 + v21 * 0.33
		local v23 = v20 + v21 * 0.75
		local v24 = v22 + 5
		local v25 = v23 + 5
		sequence.push(v22, "client", function()
			showMaskedMessage({
				text = "You've had your warm-up. Now... let's get serious.",
				senderName = "The Mask",
				senderUserId = 1,
				isOwner = false,
				icon = "rbxassetid://74389556285578",
				Duration = 5
			})
		end)
		sequence.push(v24, "client", function()
			spawnWinRing(2, true)
		end, true)
		sequence.push(v24, "server", function()
			v16[2] = true
		end, true)
		sequence.push(v24, "both", function()
			if attackConfigIndex == 2 then
				return
			end

			attackController.cleanup()
			attackConfigIndex = 2
			attackController = createAttackController(2)

			if RunService:IsServer() and v17 and not v10 then
				attackController.start(data.elapsedSeconds)
			end
		end, true)
		sequence.push(v24 + 5, "client", function()
			showMaskedMessage({
				text = "Two circles now. Surely you can manage something so simple.",
				senderName = "The Mask",
				senderUserId = 1,
				isOwner = false,
				icon = "rbxassetid://74389556285578",
				Duration = 5
			})
		end)
		sequence.push(v23, "client", function()
			showMaskedMessage({
				text = "Still here? Wonderful. Now I'm sending everything at once.",
				senderName = "The Mask",
				senderUserId = 1,
				isOwner = false,
				icon = "rbxassetid://74389556285578",
				Duration = 5
			})
		end)
		sequence.push(v25, "client", function()
			spawnWinRing(3, true)
		end, true)
		sequence.push(v25, "server", function()
			v16[3] = true
		end, true)
		sequence.push(v25, "both", function()
			if attackConfigIndex == 3 then
				return
			end

			attackController.cleanup()
			attackConfigIndex = 3
			attackController = createAttackController(3)

			if RunService:IsServer() and v17 and not v10 then
				attackController.start(data.elapsedSeconds)
			end
		end, true)
		sequence.push(v19, "client", function()
			showMaskedMessage({
				text = "Enough. You've entertained me long enough.",
				senderName = "The Mask",
				senderUserId = 1,
				isOwner = false,
				icon = "rbxassetid://74389556285578",
				Duration = 5
			})
		end)
		sequence.push(v19, "server", stopAttacksForEnding, true)
		sequence.push(v18, "client", startEndingCutscene, true)
		sequence.push(v18, "server", startEndingCutscene, true)
		sequence.push(v18 + 3, "client", function()
			showMaskedMessage({
				text = "Well that was fun.",
				senderName = "The Mask",
				senderUserId = 1,
				isOwner = false,
				icon = "rbxassetid://74389556285578",
				Duration = 4
			})
		end)
		sequence.push(v18 + 8, "client", function()
			showMaskedMessage({
				text = "Oh YOU want to be the next, next week? Sure...",
				senderName = "The Mask",
				senderUserId = 1,
				isOwner = false,
				icon = "rbxassetid://74389556285578",
				Duration = 5
			})
		end)
		data.janitor:Add(function()
			AdminAbuseUtils.cleanupAll()
		end)
		data.janitor:Add(function()
			Cutscenes.cleanup()
		end)
		data.janitor:Add(function()
			attackController.cleanup()
		end)
		data.janitor:Add(function()
			for k, v26 in v14 do
				v26.destroy()
				v14[k] = nil
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

				if v12 then
					local v26 = math.max(v18 - v20, 0.001)
					local v27 = (data.elapsedSeconds - v20) / v26
					v12.update(v27, v20 <= data.elapsedSeconds and data.elapsedSeconds < v18)
				end

				for _, v26 in v14 do
					v26.update(data.elapsedSeconds, p)
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
				elseif list[1] == "AttackHit" and list[2] == "SharkRain" then
					damagePlayer(player, Config.sharkRainAttackConfigs[attackConfigIndex].damage) -- equivalent call inferred; original call site unknown
				elseif list[1] == "AttackHit" and list[2] == "CrabTsunami" then
					damagePlayer(player, Config.crabTsunamiAttackConfigs[attackConfigIndex].damage) -- equivalent call inferred; original call site unknown
				elseif list[1] == "AttackHit" and list[2] == "SandCastle" then
					damagePlayer(player, Config.sandCastleAttackConfigs[attackConfigIndex].damage) -- equivalent call inferred; original call site unknown
				end
			end,
			onPlayerAdded = function(p)
				if RunService:IsServer() and flag then
					data.FireServerEventToPlayer(p, { "ForceSetup" })
				end
			end
		}
	end
})
return nil