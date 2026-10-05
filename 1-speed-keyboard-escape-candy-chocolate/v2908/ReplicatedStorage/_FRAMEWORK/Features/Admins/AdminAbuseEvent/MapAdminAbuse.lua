-- failed to load script (decompiled with syntax error):
-- JKmutZJNjAWKGjKGiwJAJwihz:184: Expected identifier when parsing expression, got ';'

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
require(script.Parent)
local AdminAbuseUtils = require(script.Parent.AdminAbuseUtils)
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

local function applyNpcCollision(data, instance)
	pcall(function()
		PhysicsService:RegisterCollisionGroup(data.npcDanceCollisionGroup)
	end)
	pcall(function()
		PhysicsService:CollisionGroupSetCollidable(data.npcDanceCollisionGroup, "PlayersNoCollide", false)
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
					part.CollisionGroup = data.npcDanceCollisionGroup
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

local function waitForLiveMap(data)
	local v2 = os.clock() + data.mapWaitTimeoutSeconds

	while os.clock() < v2 do
		local map = AdminAbuseUtils.Map.getMap(data.liveMapName)

		if map then
			return map
		else
			task.wait(0.1)
		end
	end

	return nil
end

local function waitForNpcsFolder(data, instance)
	local v2 = os.clock() + data.mapWaitTimeoutSeconds

	while os.clock() < v2 do
		local scriptables = instance:FindFirstChild("Scriptables")

		if scriptables and scriptables:FindFirstChild("NPCs") then
			break
		else
			task.wait(0.1)
		end
	end
end

local function buildServerRuntime(data, data2)
	local v2 = nil
	local v3 = nil

	local function beginOpeningSequence(p)
		local lobbyDoor = getLobbyDoor() -- equivalent call inferred; original call site unknown
		local v4 = p.mapLoaded:andThen(function()
			if v2 == p then
				v3 = AdminAbuseUtils.SoundtrackRotation.start({
					parent = p.mapClone,
					tracks = data.soundtracks
				})
			end
		end)
		local resolved

		if data2.isCatchUp or not data.useDoorOpeningCutscene then
			lobbyDoor.open(true)
			resolved = Promise.resolve()
		else
			resolved = Promise.delay((math.max(0, v - data2.elapsedSeconds))):andThen(function()
				if v2 == p then
					lobbyDoor.open(false)
				end
			end)
		end

		return Promise.all({ v4, resolved }):catch(function(p2)
			logger:warn(string.format("%s: opening sequence failed: %s", data2.name, (tostring(p2))))
		end)
	end

	return {
		onStart = function()
			moveLobbyPortal(true)
			local v4 = AdminAbuseUtils.Map.addMap({
				templateName = data.mapTemplateName,
				liveName = data.liveMapName,
				streamedKeycapsFolderName = data.keycapLoadId,
				prepareSource = function(p)
					applyNpcCollision(data, p)
				end
			})
			v2 = v4
			local v5 = beginOpeningSequence(v4)
			data2.janitor:Add(function()
				v5:cancel()

				if v3 then
					v3.stop()
					v3 = nil
				end

				moveLobbyPortal(false)

				if v2 == v4 then
					AdminAbuseUtils.Map.removeMap(v4)
					v2 = nil
				end
			end)
		end,
		onStop = function(p)
			;(getLobbyDoor()).close(false)
			local v4 = v2

			if v4 and p ~= "shutdown" then
				task.wait(AdminAbuseDoorConfig.TransitionBlackIn)
				returnPlayersInMapToSpawn(v4.mapClone)
			end
		end
	}
end

local function buildClientRuntime(data, data2)
	local AAAudioPlayerVolume = require(ReplicatedStorage.AdminAbuse.AAAudioPlayerVolume)
	local v2 = nil
	return {
		onStart = function()
			local adminAbuseTransition = getAdminAbuseTransition() -- equivalent call inferred; original call site unknown
			adminAbuseTransition.cancel()
			adminAbuseTransition.play(nil, {
				skip = data2.isCatchUp,
				skipDoor = not data.useDoorOpeningCutscene
			})
			local v3 = false
			local thread = task.spawn(function()
				local map = waitForLiveMap(data)

				if not map then
					logger:warn(string.format("%s: timed out waiting for live map '%s'", data2.name, data.liveMapName))
					return
				end

				waitForNpcsFolder(data, map)
				local v5 = AdminAbuseUtils.NPCDance.start({
					map = map,
					animationIds = data.npcDanceAnimationIds
				})

				if v3 or not map.Parent then
					v5.stop()
				else
					data2.janitor:Add(v5.stop)
				end
			end)
			data2.janitor:Add(function()
				v3 = true
				adminAbuseTransition.cancel()
				pcall(task.cancel, thread)
			end)
		end,
		onUpdate = function()
			local v3 = not v2 and AdminAbuseUtils.Map.getMap(data.liveMapName)

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
		onStop = function(p)
			if p ~= "shutdown" then
				;(getAdminAbuseTransition()).play(nil, {
					skip = false,
					skipDoor = true
				})
			end
		end
	}
end

return {
	create = function(p)
		return function(p2)
			if RunService:IsServer() then
				return (buildServerRuntime(p, p2))
			end

			return (buildClientRuntime(p, p2))
		end
	end
}