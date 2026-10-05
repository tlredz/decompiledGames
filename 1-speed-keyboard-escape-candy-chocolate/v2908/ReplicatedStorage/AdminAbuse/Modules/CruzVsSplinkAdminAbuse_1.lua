local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CruzVsSplinkAdminAbuseConfig = require(script.CruzVsSplinkAdminAbuseConfig)
local NPCDanceController = require(script.NPCDanceController)
local SharedSyncedEvent = require(ReplicatedStorage.AdminAbuse.SharedSyncedEvent)
local AAAudioPlayerVolume = require(ReplicatedStorage.AdminAbuse.AAAudioPlayerVolume)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local flag = false
local v = nil
local maid = Janitor.new()

local function findLoadedMap()
	local adminAbuse = Workspace:FindFirstChild("AdminAbuse")
	local map

	if adminAbuse then
		map = adminAbuse:FindFirstChild("Map")
	end

	local child

	if map then
		child = map:FindFirstChild(CruzVsSplinkAdminAbuseConfig.MAP_LIVE_NAME)
	end

	if child and child:GetAttribute(CruzVsSplinkAdminAbuseConfig.MAP_LOADED_ATTRIBUTE) == true then
		return child
	end

	return nil
end

local function waitForLoadedMap()
	local loadedMap = findLoadedMap()
	local count = 0

	while flag and loadedMap == nil and count < 600 do
		task.wait(0.1)
		count += 1
		loadedMap = findLoadedMap()
	end

	return loadedMap
end

local function applyAudioVolume(instance)
	local child = instance:FindFirstChild(CruzVsSplinkAdminAbuseConfig.AUDIO_FOLDER_NAME)

	if child == nil then
		return
	end

	for _, audioPlayer in child:GetChildren() do
		if audioPlayer:IsA("AudioPlayer") then
			AAAudioPlayerVolume.ApplyFrame(audioPlayer)
		end
	end
end

local function startMapControllers(p)
	NPCDanceController.start(p)
	maid:Add(NPCDanceController, "stop")
	maid:Add(RunService.Heartbeat:Connect(function()
		applyAudioVolume(p)
	end))
end

local CruzVsSplinkAdminAbuse = {}
CruzVsSplinkAdminAbuse.DisplayName = CruzVsSplinkAdminAbuseConfig.DisplayName
CruzVsSplinkAdminAbuse.NeedsDuration = CruzVsSplinkAdminAbuseConfig.NeedsDuration
CruzVsSplinkAdminAbuse.SkipDoorTransition = CruzVsSplinkAdminAbuseConfig.SkipDoorTransition
CruzVsSplinkAdminAbuse.IsAdminAbuse = CruzVsSplinkAdminAbuseConfig.IsAdminAbuse
CruzVsSplinkAdminAbuse.RequiresRespawnRefire = CruzVsSplinkAdminAbuseConfig.RequiresRespawnRefire
CruzVsSplinkAdminAbuse.HasPrioritySoundtrack = CruzVsSplinkAdminAbuseConfig.HasPrioritySoundtrack

function CruzVsSplinkAdminAbuse.Fire(_)
	if flag then
		return
	end

	flag = true
	v = SharedSyncedEvent.new(CruzVsSplinkAdminAbuseConfig.SSE_CHANNEL)
	maid:Add(function()
		if v then
			v:destroy()
			v = nil
		end
	end)
	v:onChange("phase", function(p)
		print("[CruzVsSplinkAdminAbuse]", "Phase:", p)
	end)
	local thread = task.spawn(function()
		local v2 = waitForLoadedMap()

		if v2 then
			startMapControllers(v2)
		elseif flag then
			warn(
				"[CruzVsSplinkAdminAbuse]",
				"Map",
				CruzVsSplinkAdminAbuseConfig.MAP_LIVE_NAME,
				"not loaded after timeout"
			)
		end
	end)
	maid:Add(function()
		if coroutine.status(thread) == "suspended" then
			task.cancel(thread)
		end
	end)
end

function CruzVsSplinkAdminAbuse.Stop(_)
	flag = false
	maid:Cleanup()
end

return CruzVsSplinkAdminAbuse