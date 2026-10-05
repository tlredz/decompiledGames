local createVector = vector.create
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local parentModule = require(script.Parent.Parent)
local AdminAbuseUtils = require(script.Parent.Parent.AdminAbuseUtils)
local BadgeInfoCache = require(ReplicatedStorage._FRAMEWORK.Libraries.BadgeInfoCache)
local Config = require(script.Config)
local HuntReward = require(script.HuntReward)
local MusicManager = require(ReplicatedStorage._FRAMEWORK.Features.MusicManager)
local MapLighting = require(script.MapLighting)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local SkyTransition = require(script.SkyTransition)
require(script.Types)
local Years = require(script.Years)
local DefaultYearMap = require(script.Years.DefaultYearMap)
local YearTransition = require(script.YearTransition)
local YearCounter = require(script.YearCounter)
local ParticipantEffects = require(script.ParticipantEffects)
local t = require(ReplicatedStorage.Packages.t)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local literal = t.literal("requestMapLighting")
local v = {
	PortalOpen = true,
	PortalLoop = true,
	PortalClose = true
}
local _20YearsEvent = {
	firstYear = Config.firstYear,
	lastYear = Config.lastYear,
	elapsedSecondsForYear = function(p: number)
		return (p - Config.firstYear) * Config.secondsPerYear
	end,
	yearAtElapsedSeconds = function(p: number)
		local v2 = math.floor(p / Config.secondsPerYear)

		if v2 <= Config.lastYear - Config.firstYear then
			return Config.firstYear + v2
		end

		return nil
	end
}

local function checkEnvironmentReady()
	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local child

	if adminAbuse then
		child = adminAbuse:FindFirstChild(Config.assetFolderName)
	end

	local assets

	if child then
		assets = child:FindFirstChild("Assets")
	end

	local pVInstance

	if assets then
		pVInstance = assets:FindFirstChild(Config.entryPortalName)
	end

	local years

	if child then
		years = child:FindFirstChild("Years")
	end

	if not (years and years:IsA("Folder")) then
		years = nil
	end

	local adminAbuseMaps = ServerStorage:FindFirstChild("AdminAbuseMaps")
	local folder

	if adminAbuseMaps then
		folder = adminAbuseMaps:FindFirstChild(Config.assetFolderName)
	end

	local adminAbuse2 = Workspace:FindFirstChild("AdminAbuse")
	local bossRoomRootPosition

	if adminAbuse2 then
		bossRoomRootPosition = adminAbuse2:FindFirstChild("BossRoomRootPosition")
	end

	local map

	if adminAbuse2 then
		map = adminAbuse2:FindFirstChild("Map")
	end

	if pVInstance and pVInstance:IsA("PVInstance") and folder and folder:IsA("Folder") and bossRoomRootPosition and bossRoomRootPosition:IsA("BasePart") and map then
		return true, {
			entryPortal = pVInstance,
			yearMaps = folder,
			portalAnchor = bossRoomRootPosition,
			mapParent = map,
			yearAssets = years
		}, nil
	end

	return false, nil, "20th Anniversary event requires its portal asset and workspace anchors"
end

local function checkClientEnvironmentReady(serverMessage, fireClientEvent)
	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local child

	if adminAbuse then
		child = adminAbuse:FindFirstChild(Config.assetFolderName)
	end

	local years

	if child then
		years = child:FindFirstChild("Years")
	end

	if not (years and years:IsA("Folder")) then
		years = nil
	end

	local adminAbuse2 = Workspace:FindFirstChild("AdminAbuse")
	local map

	if adminAbuse2 then
		map = adminAbuse2:FindFirstChild("Map")
	end

	if map then
		return true, {
			mapParent = map,
			yearAssets = years,
			serverMessage = serverMessage,
			fireServer = fireClientEvent
		}, nil
	end

	return false, nil, "20th Anniversary event client hooks require Workspace.AdminAbuse.Map"
end

local function checkWorldPortalReady()
	local portal = Workspace:FindFirstChild("Portal")
	local adminAbuse = Workspace:FindFirstChild("AdminAbuse")
	local portalAATPSpot

	if adminAbuse then
		portalAATPSpot = adminAbuse:FindFirstChild("PortalAATPSpot")
	end

	local portalDefaultSpot = Workspace:FindFirstChild("PortalDefaultSpot")

	if portal and portal:IsA("Model") and portalAATPSpot and portalAATPSpot:IsA("BasePart") and portalDefaultSpot and portalDefaultSpot:IsA("BasePart") then
		return portal, portalAATPSpot, portalDefaultSpot
	end

	return nil, nil, nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function moveWorldPortal(p)
	local v2, v3, v4 = checkWorldPortalReady()

	if v2 and v3 and v4 then
		v2:PivotTo(v3.CFrame)
		p.janitor:Add(function()
			v2:PivotTo(v4.CFrame)
		end)
	end
end

local function getYearAt(p: number)
	local v2 = math.floor(p / Config.secondsPerYear)

	if v2 <= Config.lastYear - Config.firstYear then
		return Config.firstYear + v2
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlayerFromTouch(otherPart)
	local model = otherPart:FindFirstAncestorOfClass("Model")

	if model then
		return (Players:GetPlayerFromCharacter(model))
	end

	return nil
end

local function getRandomSpawnCFrame(instance, object)
	local v2 = instance.Size * 0.5
	local vector2 = Vector3.new(
		object:NextNumber(-v2.X, v2.X),
		v2.Y + Config.spawnHeightOffset,
		object:NextNumber(-v2.Z, v2.Z)
	)
	return instance.CFrame * CFrame.new(vector2)
end

local function teleportPlayerToSpawn(PlayerTeleport, player, p, random, value: number?)
	local v2 = getRandomSpawnCFrame(p, random) + Vector3.new(0, value or 0, 0)
	local character = player.Character

	if value and character then
		v2 = CFrame.new(v2.Position) * character:GetPivot().Rotation
	end

	return PlayerTeleport.toDestination(player, v2, {
		reason = PlayerTeleport.Reason.Event,
		grantCheckpoints = false
	})
end

parentModule.register(script.Name, {
	displayName = "20th Anniversary",
	slot = "main",
	needsDuration = false,
	defaultDurationSeconds = Config.totalDurationSeconds,
	load = function(data)
		if RunService:IsClient() then
			data.janitor:Add(ParticipantEffects.startClient())
			local v2 = SkyTransition.mount(Players.LocalPlayer.PlayerGui)
			data.janitor:Add(v2.destroy)
			local serverMessage = Signal.new()
			data.janitor:Add(function()
				serverMessage:Destroy()
			end)
			local v4, v5, v6 = checkClientEnvironmentReady(serverMessage, data.FireClientEvent)
			local v7 = nil
			local v8 = nil
			local v9 = 0
			local v10 = 0
			local v11 = nil
			local v12 = nil
			local v13 = false
			local v14 = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function syncMapLighting()
				local v15 = v12

				if v13 and v15 then
					v13 = false
					local lighting = v15:FindFirstChild("Lighting")
					YearTransition.applyMapLighting(function()
						local apply = MapLighting.apply
						local v16

						if lighting and lighting:IsA("Folder") then
							v16 = lighting
						end

						apply(v16)
					end)
				end
			end

			local function selectLightingYear(year: number?)
				if year ~= v11 then
					if v14 then
						v14()
						v14 = nil
					end

					v11 = year
					v13 = false

					if year and v4 then
						v14 = DefaultYearMap.watchMap(v5, year, function(instance)
							v12 = instance
							v13 = true

							local function onLightingChanged(instance2)
								local lighting = instance:FindFirstChild("Lighting")

								if instance2 == lighting or lighting and instance2:IsDescendantOf(lighting) then
									v13 = true
								end
							end

							local descendantAddedConnection = instance.DescendantAdded:Connect(onLightingChanged)
							local descendantRemovingConnection = instance.DescendantRemoving:Connect(onLightingChanged)
							return function()
								descendantAddedConnection:Disconnect()
								descendantRemovingConnection:Disconnect()
								v12 = nil
							end
						end)
						syncMapLighting() -- equivalent call inferred; original call site unknown
					elseif not year then
						YearTransition.cancelClientTransition()
						MapLighting.restore()
					end
				end
			end

			data.janitor:Add(function()
				if v14 then
					v14()
				end

				YearTransition.cleanupClient()
				MapLighting.cleanupClient()
			end)

			local function applyYearTransition(p, p2: number, p3: number, p4: number)
				local v15 = p == "launch" and 1 or p == "peak" and 2 or 3

				if v9 < p4 then
					v9 = p4
					v10 = 0
				end

				if p4 == v9 and v10 < v15 then
					if v10 == 0 and v15 > 1 then
						YearTransition.onClient(Players.LocalPlayer, "launch", p2, p3)
					end

					v10 = v15
					YearTransition.onClient(Players.LocalPlayer, p, p2, p3)
				end
			end

			local function syncTransitionAttribute()
				local anniversaryYearTransition = Players.LocalPlayer:GetAttribute("AnniversaryYearTransition")

				if type(anniversaryYearTransition) == "string" then
					local v15, v16, v17, v18 = string.match(anniversaryYearTransition, "^(%d+):(%a+):(%d+):(%d+)$")

					if v15 and (v16 == "launch" or v16 == "peak" or v16 == "finish") then
						applyYearTransition(v16, tonumber(v17), tonumber(v18), tonumber(v15))
					end
				end
			end

			data.janitor:Add(Players.LocalPlayer:GetAttributeChangedSignal("AnniversaryYearTransition"):Connect(syncTransitionAttribute))

			local function stopClientYear()
				if v8 then
					v8()
					v8 = nil
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function syncClientYear()
				local yearAtElapsedSeconds = _20YearsEvent.yearAtElapsedSeconds(data.elapsedSeconds)

				if yearAtElapsedSeconds ~= v7 then
					if v8 then
						v8()
						v8 = nil
					end

					v7 = yearAtElapsedSeconds
					local v15

					if yearAtElapsedSeconds then
						v15 = Years.getYearModule(yearAtElapsedSeconds)
					end

					if v15 and v15.loadClient then
						v8 = v15.loadClient(v5, yearAtElapsedSeconds)
					end
				end
			end

			if v4 then
				data.janitor:Add(stopClientYear)
			else
				logger:warn(v6)
			end

			return {
				onStart = function()
					AdminAbuseUtils.Musics.cleanup()
					task.spawn(function()
						pcall(ContentProvider.PreloadAsync, ContentProvider, {
							Config.portalOpenSoundId,
							Config.portalEnterSoundId,
							Config.portalLoopSoundId,
							Config.portalCloseSoundId
						})
					end)

					-- equivalent calls inferred from this helper; original call sites unknown
					local function assignPortalSoundGroup(sound)
						if sound:IsA("Sound") and v[sound.Name] then
							local aAMusicVolumeGroup = SoundService:FindFirstChild("AAMusicVolumeGroup")

							if aAMusicVolumeGroup and aAMusicVolumeGroup:IsA("SoundGroup") then
								sound.SoundGroup = aAMusicVolumeGroup
							end
						end
					end

					for _, descendant in Workspace:GetDescendants() do
						assignPortalSoundGroup(descendant) -- equivalent call inferred; original call site unknown
					end

					data.janitor:Add(Workspace.DescendantAdded:Connect(assignPortalSoundGroup))
					BadgeInfoCache.Prefetch(Config.huntBadgeId, true)
					local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
					NotificationSystem:ShowGeneralNotification(
						Config.notificationText,
						Config.notificationColor,
						Config.notificationDurationSeconds
					)
					MapLighting.startClient()
					YearTransition.startClient()

					if v4 then
						syncClientYear() -- equivalent call inferred; original call site unknown
					end

					syncTransitionAttribute()
					data.FireClientEvent("requestMapLighting")
				end,
				onUpdate = function(_: number)
					if v4 then
						syncClientYear() -- equivalent call inferred; original call site unknown
					end

					syncMapLighting() -- equivalent call inferred; original call site unknown
					YearTransition.updateClient(Players.LocalPlayer)
					local v15 = v11
					local v16 = not v15 and "" or Config.yearInstructions[v15]
					local instructions

					if v12 then
						instructions = v12:GetAttribute("Instructions")
					end

					local setStatus = YearCounter.setStatus
					local v17 = Config.secondsPerYear - data.elapsedSeconds % Config.secondsPerYear

					if type(instructions) == "string" then
						v16 = instructions
					end

					setStatus(v15, v17, v16)
				end,
				onServerEvent = function(data2)
					if type(data2) ~= "table" then
						data2 = nil
					end

					if data2 and data2.kind == "fade" then
						v2.play()
					elseif data2 and data2.kind == "yearTransition" then
						applyYearTransition(data2.phase, data2.fromYear, data2.toYear, data2.transitionId)
					elseif data2 and data2.kind == "mapLighting" then
						selectLightingYear(data2.year)
					elseif data2 and data2.kind == "respawn" then
						YearTransition.cancelClientTransition()
					elseif data2 and data2.kind == "portalEnter" then
						local sound = Instance.new("Sound")
						sound.Name = "PortalEnter"
						sound.SoundId = Config.portalEnterSoundId
						sound.Volume = 1.5
						sound:SetAttribute("IsEventSound", true)
						sound.Parent = SoundService
						sound.Ended:Once(function()
							sound:Destroy()
						end)
						sound:Play()
					elseif data2 then
						serverMessage:Fire(data2)
					end
				end,
				onStop = function(_)
					YearCounter.reset()
				end
			}
		else
			local PlayerTeleport = require(ServerScriptService.Utilities.PlayerTeleport)
			local random = Random.new()
			local v2 = {}
			local clientMessage = Signal.new()
			data.janitor:Add(function()
				clientMessage:Destroy()
			end)
			local v4 = {}
			local v5 = {}
			local v6 = {}
			local v7 = nil
			local spawn = nil
			local v8 = nil
			local cleanup = nil
			local stopTools = nil
			local v9 = {}
			local v10 = {}
			local v11 = nil
			local count = 0
			local flag = false
			local flag2 = true
			local v12 = {}

			-- equivalent calls inferred from this helper; original call sites unknown
			local function releaseParticipant(instance)
				local v13 = v6[instance]

				if v13 and v13.restoreSpeed then
					v13.restoreSpeed()
				end

				v6[instance] = nil
				instance:SetAttribute(Config.participantAttribute, nil)
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function playFade(p)
				data.FireServerEventToPlayer(p, {
					kind = "fade"
				})
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function setPlayerLightingYear(p, year: number?)
				v5[p] = year
				data.FireServerEventToPlayer(p, {
					kind = "mapLighting",
					year = year
				})
			end

			local function runYearTransition(instance, phase, fromYear: number, toYear: number, transitionId: number)
				YearTransition.onServer(instance, phase, fromYear, toYear)
				instance:SetAttribute("AnniversaryYearTransition", (`{transitionId}:{phase}:{fromYear}:{toYear}`))
				data.FireServerEventToPlayer(instance, {
					kind = "yearTransition",
					phase = phase,
					fromYear = fromYear,
					toYear = toYear,
					transitionId = transitionId
				})
			end

			local function teleportParticipantsToLobby()
				for k in v2 do
					if not (k.Parent == Players and PlayerTeleport.toLobby(k, PlayerTeleport.Reason.Event)) then
						continue
					end

					setPlayerLightingYear(k, nil) -- equivalent call inferred; original call site unknown
				end
			end

			local function preloadYear(p: number)
				local v13 = v10[p]

				if v13 then
					return v13, nil
				end

				local v14 = v7
				local loaded, v15 = DefaultYearMap.load({
					yearMaps = v14.yearMaps,
					mapParent = v14.mapParent,
					spawnPartName = Config.spawnPartName,
					yearAssets = v14.yearAssets
				}, p)

				if loaded then
					v10[p] = loaded
				end

				return loaded, v15
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function preloadFollowingYear(p: number)
				if p < Config.lastYear then
					local v13, v14 = preloadYear(p + 1)

					if not v13 then
						logger:warn(v14)
					end
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function retireYear(retiringEntry)
				if retiringEntry then
					retiringEntry.cleanup()
					local index = table.find(v9, retiringEntry)

					if index then
						table.remove(v9, index)
					end
				end
			end

			local function transitionParticipantsToSpawn(spawn2, year: number, fromYear: number, cleanup2)
				local retiringEntry = nil
				local v14 = cleanup2 ~= nil
				local v15 = v11

				if v15 then
					YearTransition.cleanupServer()
					retireYear(v15.retiringEntry) -- equivalent call inferred; original call site unknown
					v11 = nil
				end

				count += 1
				local id = count

				if cleanup2 then
					retiringEntry = {
						cleanup = cleanup2
					}
					table.insert(v9, retiringEntry)
				end

				if not v14 then
					task.delay(Config.transitionMidpointSeconds, function()
						if flag2 and spawn == spawn2 then
							preloadFollowingYear(year) -- equivalent call inferred; original call site unknown
						end
					end)
					return
				end

				local players = {}
				local streamReady = {}

				for k in v2 do
					local v19 = v6[k]

					if k.Parent ~= Players or (v4[k] or v19.dead) or v19.readyAt ~= nil then
						continue
					end

					if not (v19.humanoid and v19.humanoid.Health > 0) then
						continue
					end

					players[k] = true
					runYearTransition(k, "launch", fromYear, year, id)
					local v20 = k
					task.spawn(function()
						if pcall(function()
							v20:RequestStreamAroundAsync(spawn2.Position)
						end) and flag2 and id == count then
							streamReady[v20] = true
						end
					end)
				end

				v11 = {
					spawn = spawn2,
					year = year,
					fromYear = fromYear,
					id = id,
					startedAt = os.clock(),
					players = players,
					streamReady = streamReady,
					retiringEntry = retiringEntry
				}
			end

			local function relocateBlockedPlayer(p, cframe: CFrame)
				return PlayerTeleport.toDestination(p, cframe, {
					reason = PlayerTeleport.Reason.Event,
					grantCheckpoints = false
				})
			end

			local function advanceYearTransition()
				local v13 = v11

				if v13 then
					for k in v13.players do
						if v2[k] and k.Parent == Players then
							YearTransition.recoverBlockedLift(k, relocateBlockedPlayer)

							if v13.streamReady[k] and YearTransition.hasReachedPeak(k) or os.clock() - v13.startedAt >= Config.yearLiftTimeoutSeconds then
								runYearTransition(k, "peak", v13.fromYear, v13.year, v13.id)

								if teleportPlayerToSpawn(PlayerTeleport, k, v13.spawn, random, Config.yearLandingHeight) then
									setPlayerLightingYear(k, v13.year) -- equivalent call inferred; original call site unknown
								end

								v13.players[k] = nil
								local v14 = math.sqrt(2 * Config.yearLandingHeight / Workspace.Gravity)
								local v15 = k
								task.delay(v14, function()
									if flag2 and v13.id == count and v15.Parent == Players then
										runYearTransition(v15, "finish", v13.fromYear, v13.year, v13.id)
									end
								end)
							end
						else
							YearTransition.releasePlayer(k)
							v13.players[k] = nil
						end
					end

					if next(v13.players) == nil then
						retireYear(v13.retiringEntry) -- equivalent call inferred; original call site unknown
						preloadFollowingYear(v13.year) -- equivalent call inferred; original call site unknown
						v11 = nil
					end
				end
			end

			local function resolveYearHandle(data2, p: number)
				local yearModule = Years.getYearModule(p)

				if not yearModule then
					return nil, string.format("20th Anniversary event has no gameplay module registered for year %d", p)
				end

				local v13, v14 = preloadYear(p)

				if v13 then
					return yearModule.load({
						preloadedMap = {
							map = v13.map,
							spawn = v13.spawn,
							cleanup = function() end
						},
						yearMaps = data2.yearMaps,
						mapParent = data2.mapParent,
						spawnPartName = Config.spawnPartName,
						yearAssets = data2.yearAssets,
						clientMessage = clientMessage,
						fireToPlayer = data.FireServerEventToPlayer,
						isParticipant = function(p2)
							return v2[p2] == true
						end
					}, p)
				end

				return nil, v14
			end

			local function loadYear(year: number)
				local v13 = v7

				if not v13 then
					return false
				end

				if stopTools then
					stopTools()
					stopTools = nil
				end

				local yearHandle, v14 = resolveYearHandle(v13, year)

				if not yearHandle then
					logger:warn(v14)
					return false
				end

				local cleanup2 = cleanup
				local fromYear = v8 or year
				spawn = yearHandle.spawn
				v8 = year
				cleanup = yearHandle.cleanup
				stopTools = yearHandle.stopTools
				transitionParticipantsToSpawn(yearHandle.spawn, year, fromYear, cleanup2)
				return true
			end

			local function enterEvent(playerFromTouch)
				if spawn and not v2[playerFromTouch] then
					v2[playerFromTouch] = true
					playerFromTouch:SetAttribute(Config.participantAttribute, true)
					v6[playerFromTouch] = {
						character = playerFromTouch.Character,
						readyAt = nil,
						humanoid = nil,
						restoreSpeed = nil,
						dead = false
					}
					v4[playerFromTouch] = true
					playFade(playerFromTouch) -- equivalent call inferred; original call site unknown
					data.FireServerEventToPlayer(playerFromTouch, {
						kind = "portalEnter"
					})
					task.delay(Config.transitionMidpointSeconds, function()
						local v13 = spawn

						if flag2 and v2[playerFromTouch] and playerFromTouch.Parent == Players and v13 then
							if teleportPlayerToSpawn(PlayerTeleport, playerFromTouch, v13, random) then
								setPlayerLightingYear(playerFromTouch, v8) -- equivalent call inferred; original call site unknown
							else
								v2[playerFromTouch] = nil
								releaseParticipant(playerFromTouch) -- equivalent call inferred; original call site unknown
							end
						end

						v4[playerFromTouch] = nil
					end)
				end
			end

			local function updateParticipants()
				for k in v2 do
					local v13 = v6[k]
					local character = k.Character

					if character ~= v13.character then
						YearTransition.releasePlayer(k)

						if v11 then
							v11.players[k] = nil
						end

						k:SetAttribute("AnniversaryYearTransition", nil)
						data.FireServerEventToPlayer(k, {
							kind = "respawn"
						})

						if v13.restoreSpeed then
							v13.restoreSpeed()
							v13.restoreSpeed = nil
						end

						v13.character = character
						v13.humanoid = nil
						v13.readyAt = os.clock() + 0.5
						v13.dead = false
					end

					local humanoid

					if character then
						humanoid = character:FindFirstChildOfClass("Humanoid")
					end

					if humanoid and humanoid ~= v13.humanoid then
						if v13.restoreSpeed then
							v13.restoreSpeed()
						end

						v13.humanoid = humanoid
						v13.restoreSpeed = ParticipantEffects.lockSpeed(humanoid)
					end

					if humanoid and humanoid.Health <= 0 and not v13.dead then
						v13.dead = true
						YearTransition.releasePlayer(k)

						if v11 then
							v11.players[k] = nil
						end

						k:SetAttribute("AnniversaryYearTransition", nil)
						data.FireServerEventToPlayer(k, {
							kind = "respawn"
						})
					elseif v13.readyAt and os.clock() >= v13.readyAt and humanoid and humanoid.Health > 0 and character and character:FindFirstChild("HumanoidRootPart") and spawn then
						if teleportPlayerToSpawn(PlayerTeleport, k, spawn, random) then
							v13.readyAt = nil
							v4[k] = nil
							setPlayerLightingYear(k, v8) -- equivalent call inferred; original call site unknown
						else
							v13.readyAt = os.clock() + 0.5
						end
					end
				end
			end

			local function connectPortalTouches(part)
				-- equivalent calls inferred from this helper; original call sites unknown
				local function connectPart(part2)
					data.janitor:Add(part2.Touched:Connect(function(otherPart)
						local playerFromTouch = getPlayerFromTouch(otherPart) -- equivalent call inferred; original call site unknown

						if playerFromTouch then
							enterEvent(playerFromTouch)
						end
					end))
				end

				if part:IsA("BasePart") then
					connectPart(part) -- equivalent call inferred; original call site unknown
					return
				end

				for _, part2 in part:GetDescendants() do
					if not part2:IsA("BasePart") then
						continue
					end

					connectPart(part2) -- equivalent call inferred; original call site unknown
				end
			end

			local function rewardParticipants()
				for k in v2 do
					if v12[k] then
						continue
					end

					v12[k] = true
					HuntReward.grant(k)
				end
			end

			local function queueLocalStop(flag3: boolean)
				if not flag then
					flag = true

					if flag3 then
						rewardParticipants()
					end

					for k in v2 do
						if k.Parent ~= Players then
							continue
						end

						playFade(k) -- equivalent call inferred; original call site unknown
					end

					task.delay(Config.transitionMidpointSeconds, function()
						if flag2 then
							teleportParticipantsToLobby()
						end
					end)
					task.delay(Config.transitionTotalSeconds, function()
						if flag2 then
							parentModule.stopModuleLocally(data.name, flag3 and "durationElapsed" or "manual")
						end
					end)
				end
			end

			local v13 = nil
			local v14 = nil
			local portalAnchor = nil

			local function getPortalHost(instance, p)
				if instance:IsA("Model") and instance.PrimaryPart then
					return instance.PrimaryPart
				end

				if instance:IsA("BasePart") then
					return instance
				end

				return p
			end

			local function createPortalSound(parent, name: string, soundId: string, looped: boolean)
				local sound = Instance.new("Sound")
				sound.Name = name
				sound.SoundId = soundId
				sound.Looped = looped
				sound.Volume = 1.5
				sound.RollOffMode = Enum.RollOffMode.InverseTapered
				sound.RollOffMinDistance = 90
				sound.RollOffMaxDistance = 600
				sound:SetAttribute("IsEventSound", true)
				sound.Parent = parent
				return sound
			end

			local function playPortalClose(instance, primaryPart)
				if v13 then
					v13:Stop()
					v13 = nil
				end

				if instance:IsA("Model") and instance.PrimaryPart then
					primaryPart = instance.PrimaryPart
				elseif instance:IsA("BasePart") then
					primaryPart = instance
				end

				local part = Instance.new("Part")
				part.Name = "PortalCloseAnchor"
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
				part.Transparency = 1
				part.Size = createVector(1, 1, 1)
				part.CFrame = primaryPart.CFrame
				part.Parent = Workspace
				local portalCloseSoundId = Config.portalCloseSoundId
				local sound = Instance.new("Sound")
				sound.Name = "PortalClose"
				sound.SoundId = portalCloseSoundId
				sound.Looped = false
				sound.Volume = 1.5
				sound.RollOffMode = Enum.RollOffMode.InverseTapered
				sound.RollOffMinDistance = 90
				sound.RollOffMaxDistance = 600
				sound:SetAttribute("IsEventSound", true)
				sound.Parent = part
				sound:Play()
				Debris:AddItem(part, 12)
			end

			return {
				onStart = function()
					local v15, v16, v17 = checkEnvironmentReady()

					if v15 then
						MusicManager.play(Config.musicSoundId, Config.musicTrackName, Config.musicPriority)
						v7 = v16
						moveWorldPortal(data) -- equivalent call inferred; original call site unknown
						local clone = v16.entryPortal:Clone()
						clone.Name = Config.entryPortalName
						clone:PivotTo(v16.portalAnchor.CFrame)
						clone.Parent = Workspace
						data.janitor:Add(clone)
						v14 = clone
						portalAnchor = v16.portalAnchor
						local portalAnchor2 = v16.portalAnchor

						if clone:IsA("Model") and clone.PrimaryPart then
							portalAnchor2 = clone.PrimaryPart
						elseif clone:IsA("BasePart") then
							portalAnchor2 = clone
						end

						local portalOpenSoundId = Config.portalOpenSoundId
						local sound = Instance.new("Sound")
						sound.Name = "PortalOpen"
						sound.SoundId = portalOpenSoundId
						sound.Looped = false
						sound.Volume = 1.5
						sound.RollOffMode = Enum.RollOffMode.InverseTapered
						sound.RollOffMinDistance = 90
						sound.RollOffMaxDistance = 600
						sound:SetAttribute("IsEventSound", true)
						sound.Parent = portalAnchor2
						sound:Play()
						local portalLoopSoundId = Config.portalLoopSoundId
						local sound2 = Instance.new("Sound")
						sound2.Name = "PortalLoop"
						sound2.SoundId = portalLoopSoundId
						sound2.Looped = true
						sound2.Volume = 1.5
						sound2.RollOffMode = Enum.RollOffMode.InverseTapered
						sound2.RollOffMinDistance = 90
						sound2.RollOffMaxDistance = 600
						sound2:SetAttribute("IsEventSound", true)
						sound2.Parent = portalAnchor2
						v13 = sound2
						v13:Play()
						data.janitor:Add(Players.PlayerRemoving:Connect(function(player)
							releaseParticipant(player) -- equivalent call inferred; original call site unknown
							v2[player] = nil
							v4[player] = nil
							v5[player] = nil
							YearTransition.releasePlayer(player)
						end))
						connectPortalTouches(clone)
						local v19 = math.floor(data.elapsedSeconds / Config.secondsPerYear)

						if v19 <= Config.lastYear - Config.firstYear then
							if not loadYear(Config.firstYear + v19) then
								queueLocalStop(false)
							end
						else
							queueLocalStop(true)
						end
					else
						logger:warn(v17)
						queueLocalStop(false)
					end
				end,
				onUpdate = function(_: number)
					if flag then
						return
					end

					updateParticipants()
					local v15 = math.floor(data.elapsedSeconds / Config.secondsPerYear)

					if Config.lastYear - Config.firstYear < v15 then
						queueLocalStop(true)
						return
					end

					local year = Config.firstYear + v15

					if year ~= v8 and not loadYear(year) then
						queueLocalStop(false)
					end

					if not flag then
						advanceYearTransition()
					end

					local v17 = data.elapsedSeconds - v15 * Config.secondsPerYear

					if not flag and #v9 == 0 and Config.secondsPerYear * 0.5 <= v17 then
						for k, v18 in v10 do
							if not (k ~= v8 and k ~= year + 1) then
								continue
							end

							v18.cleanup()
							v10[k] = nil
						end
					end
				end,
				onClientEvent = function(p, p2)
					if literal(p2) then
						data.FireServerEventToPlayer(p, {
							kind = "mapLighting",
							year = v5[p]
						})
					elseif v2[p] then
						clientMessage:Fire(p, p2)
					end
				end,
				onStop = function(p)
					flag2 = false
					MusicManager.stop(Config.musicTrackName)
					local v15 = v14
					local v16 = portalAnchor

					if v15 and v16 and p == "durationElapsed" then
						playPortalClose(v15, v16)
					end

					if p == "durationElapsed" then
						rewardParticipants()
					end

					YearTransition.cleanupServer()
					teleportParticipantsToLobby()

					for k in v2 do
						releaseParticipant(k) -- equivalent call inferred; original call site unknown

						if k.Parent == Players then
							k:SetAttribute("AnniversaryYearTransition", nil)
						end
					end

					table.clear(v2)
					table.clear(v4)
					table.clear(v5)

					if cleanup then
						cleanup()
						cleanup = nil
					end

					stopTools = nil
					spawn = nil

					for _, v17 in v9 do
						v17.cleanup()
					end

					table.clear(v9)

					for _, v17 in v10 do
						v17.cleanup()
					end

					table.clear(v10)
				end
			}
		end
	end
})
return _20YearsEvent