-- failed to load script (decompiled with syntax error):
-- JKmutAeMldoAIGdiTpdLELHWH:177: Expected identifier when parsing expression, got ';'

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local parentModule = require(script.Parent.Parent)
local AdminAbuseUtils = require(script.Parent.Parent.AdminAbuseUtils)
local Config = require(script.Config)
local AdminAbuseDoorConfig = require(ReplicatedStorage.Shared.AdminAbuseDoorConfig)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local Promise = require(ReplicatedStorage.Utilities.Promise)
local SpacialQuery = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.SpacialQuery)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = AdminAbuseDoorConfig.TransitionBlackIn + AdminAbuseDoorConfig.TransitionBlackHold + AdminAbuseDoorConfig.TransitionApproachSeconds + AdminAbuseDoorConfig.LobbyDoorOpenExtraDelaySec

-- equivalent calls inferred from this helper; original call sites unknown
local function getLobbyDoor()
	local LobbyDoorServer = require(ServerScriptService.Server.LobbyDoorServer)
	return LobbyDoorServer
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getAdminAbuseTransition()
	local adminAbuseTransition = Players.LocalPlayer.PlayerScripts.Client.AdminAbuseTransition
	local module = require(adminAbuseTransition)
	return module
end

local function moveLobbyPortal(flag: boolean)
	local portal = Workspace:FindFirstChild("Portal")
	local adminAbuse = Workspace:FindFirstChild("AdminAbuse")
	local portalAATPSpot

	if flag and adminAbuse then
		portalAATPSpot = adminAbuse:FindFirstChild("PortalAATPSpot")
	else
		portalAATPSpot = Workspace:FindFirstChild("PortalDefaultSpot")
	end

	if portal and portal:IsA("Model") and portalAATPSpot and portalAATPSpot:IsA("BasePart") then
		portal:PivotTo(portalAATPSpot.CFrame)
	end
end

local function applyNpcCollision(instance)
	pcall(function()
		PhysicsService:RegisterCollisionGroup(Config.npcDanceCollisionGroup)
	end)
	pcall(function()
		PhysicsService:CollisionGroupSetCollidable(Config.npcDanceCollisionGroup, "PlayersNoCollide", false)
	end)
	local scriptables = instance:FindFirstChild("Scriptables")
	local nPCs

	if scriptables then
		nPCs = scriptables:FindFirstChild("NPCs")
	end

	if nPCs then
		for _, folder in nPCs:GetChildren() do
			for _, part in folder:GetDescendants() do
				if part:IsA("BasePart") then
					part.CollisionGroup = Config.npcDanceCollisionGroup
				end
			end
		end
	end
end

local function returnPlayersInMapToSpawn(mapClone)
	local boundingBox, v2 = mapClone:GetBoundingBox()

	for _, v3 in Players:GetPlayers() do
		local character = v3.Character

		if not (character and SpacialQuery.isPointInVolume(character:GetPivot().Position, boundingBox, v2)) then
			continue
		end

		local v4 = v3
		pcall(function()
			v4:LoadCharacterAsync()
		end)
	end
end

local function waitForLiveMap()
	local v2 = os.clock() + Config.mapWaitTimeoutSeconds

	while os.clock() < v2 do
		local map = AdminAbuseUtils.Map.getMap(Config.liveMapName)

		if map then
			return map
		else
			task.wait(0.1)
		end
	end

	return nil
end

local function buildServerRuntime(data)
	local v2 = nil
	local v3 = nil
	local v4 = nil

	local function beginOpeningSequence(p)
		local lobbyDoor = getLobbyDoor() -- equivalent call inferred; original call site unknown
		local v5 = p.mapLoaded:andThen(function()
			if v2 == p then
				v3 = AdminAbuseUtils.SoundtrackRotation.start({
					parent = p.mapClone,
					tracks = Config.soundtracks
				})
			end
		end)
		local resolved

		if data.isCatchUp or not Config.useDoorOpeningCutscene then
			lobbyDoor.open(true)
			resolved = Promise.resolve()
		else
			resolved = Promise.delay((math.max(0, v - data.elapsedSeconds))):andThen(function()
				if v2 == p then
					lobbyDoor.open(false)
				end
			end)
		end

		return Promise.all({ v5, resolved }):catch(function(p2)
			logger:warn(string.format("Opening sequence failed: %s", (tostring(p2))))
		end)
	end

	return {
		onStart = function()
			moveLobbyPortal(true)
			local v5 = AdminAbuseUtils.Map.addMap({
				templateName = Config.mapTemplateName,
				liveName = Config.liveMapName,
				streamedKeycapsFolderName = Config.keycapLoadId,
				prepareSource = function(p)
					applyNpcCollision(p)
				end
			})
			v2 = v5
			local v6 = beginOpeningSequence(v5)
			v4 = v6
			data.janitor:Add(function()
				v6:cancel()

				if v4 == v6 then
					v4 = nil
				end

				if v3 then
					v3.stop()
					v3 = nil
				end

				moveLobbyPortal(false)

				if v2 == v5 then
					AdminAbuseUtils.Map.removeMap(v5)
					v2 = nil
				end
			end)
		end,
		onStop = function(p)
			;(getLobbyDoor()).close(false)
			local v5 = v2

			if v5 and p ~= "shutdown" then
				task.wait(AdminAbuseDoorConfig.TransitionBlackIn)
				returnPlayersInMapToSpawn(v5.mapClone)
			end
		end
	}
end

local function buildClientRuntime(p)
	local v2 = nil
	local AAAudioPlayerVolume = require(ReplicatedStorage.AdminAbuse.AAAudioPlayerVolume)
	return {
		onStart = function()
			local adminAbuseTransition = getAdminAbuseTransition() -- equivalent call inferred; original call site unknown
			adminAbuseTransition.cancel()
			adminAbuseTransition.play(nil, {
				skip = p.isCatchUp,
				skipDoor = not Config.useDoorOpeningCutscene
			})
			local v3 = false
			local thread = task.spawn(function()
				local map = waitForLiveMap()

				if not map then
					logger:warn(string.format("Timed out waiting for live map '%s'", Config.liveMapName))
					return
				end

				local v5 = os.clock() + Config.mapWaitTimeoutSeconds

				while os.clock() < v5 do
					local scriptables = map:FindFirstChild("Scriptables")
					local v6

					if scriptables then
						v6 = scriptables:FindFirstChild("NPCs")
					end

					if v6 then
						break
					else
						task.wait(0.1)
					end
				end

				local v6 = AdminAbuseUtils.NPCDance.start({
					map = map,
					animationIds = Config.npcDanceAnimationIds
				})

				if v3 or not map.Parent then
					v6.stop()
				else
					p.janitor:Add(v6.stop)
				end
			end)
			p.janitor:Add(function()
				v3 = true
				adminAbuseTransition.cancel()
				pcall(task.cancel, thread)
			end)
		end,
		onUpdate = function()
			local v3 = not v2 and AdminAbuseUtils.Map.getMap(Config.liveMapName)

			if v3 then
				local folder = v3:FindFirstChild(AdminAbuseUtils.SoundtrackRotation.DEFAULT_FOLDER_NAME)

				if folder and folder:IsA("Folder") then
					v2 = folder
				end
			end

			if v2 then
				for _, audioPlayer in v2:GetChildren() do
					if audioPlayer:IsA("AudioPlayer") then
						AAAudioPlayerVolume.ApplyFrame(audioPlayer)
					end
				end
			end
		end,
		onStop = function(p2)
			if p2 ~= "shutdown" then
				;(getAdminAbuseTransition()).play(nil, {
					skip = false,
					skipDoor = true
				})
			end
		end
	}
end

parentModule.register(script.Name, {
	displayName = "RIA Map Admin Abuse",
	slot = "main",
	needsDuration = false,
	load = function(p)
		if RunService:IsServer() then
			return (buildServerRuntime(p))
		end

		return (buildClientRuntime(p))
	end
})
return {}