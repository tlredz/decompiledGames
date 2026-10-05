local LiveOpsUtil = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local NewUserDataController = require(ReplicatedStorage.Modules.Client.Util.NewUserDataController)
local RemoteConfig = require(ReplicatedStorage.Modules.Shared.RemoteConfig)
require(ReplicatedStorage.Packages.Remotes)
local v = {}
local v2 = {}
LiveOpsUtil.liveOpsEventStartTimes = {}

function LiveOpsUtil.StartAndStopLiveOpsEventAccordingToRemoteConfig(p)
	local remoteConfigForLiveOpsEvent = LiveOpsUtil.GetRemoteConfigForLiveOpsEvent(p)
	local remoteConfigTimeWindowForLiveOpsEvent = LiveOpsUtil.GetRemoteConfigTimeWindowForLiveOpsEvent(p)

	if remoteConfigForLiveOpsEvent.InstallDateThreshold and not RunService:IsServer() then
		local newUserData, _, v3 = NewUserDataController.GetNewUserData()

		if newUserData and v3 then
			if not LiveOpsUtil.IsTimestampWithinInstallDateThreshold(
				v3,
				remoteConfigForLiveOpsEvent.InstallDateThreshold
			) then
				return
			end
		else
			warn("Failed to get install date for LiveOps event, not starting event: " .. p.LiveOpsEventName)
			return
		end
	end

	LiveOpsUtil.StartEventWhenWindowBegins(p, remoteConfigTimeWindowForLiveOpsEvent)
	LiveOpsUtil.StopEventWhenWindowEnds(p, remoteConfigTimeWindowForLiveOpsEvent)
end

function LiveOpsUtil.StartAndStopLiveOpsEventAccordingToWindow(p, p2)
	LiveOpsUtil.StartEventWhenWindowBegins(p, p2)
	LiveOpsUtil.StopEventWhenWindowEnds(p, p2)
end

function LiveOpsUtil.IsTimestampWithinInstallDateThreshold(p: number, p2)
	if p2.ThresholdType == "Before" then
		return p < p2.ThresholdUnixTimestamp
	end

	if p2.ThresholdType == "After" then
		return p2.ThresholdUnixTimestamp <= p
	end

	error("Invalid threshold type for install date threshold: " .. p2.ThresholdType)
	return false
end

function LiveOpsUtil.GetLiveOpsEventNameFromModuleScript(p)
	local v3 = p.Name:lower():gsub("controller$", ""):gsub("service$", ""):gsub("util$", "")
	return p.Name:sub(1, v3:len())
end

function LiveOpsUtil.GetRemoteConfigForLiveOpsEvent(p)
	return RemoteConfig.getLiveOpsPath("LiveOps/" .. p.LiveOpsEventName):catch(function(...)
		return {}
	end):expect()
end

function LiveOpsUtil.GetRemoteConfigTimeWindowForLiveOpsEvent(p)
	return LiveOpsUtil.GetRemoteConfigForLiveOpsEvent(p).EventWindow or {
		StartUnixTime = 0
	}
end

function LiveOpsUtil.IsCurrentTimeInsideWindow(p)
	local unixTimestamp = DateTime.now().UnixTimestamp
	return p.StartUnixTime <= unixTimestamp and (not p.EndUnixTime or unixTimestamp < p.EndUnixTime)
end

function LiveOpsUtil.GetTimeUntilWindowStart(p)
	return (math.clamp(p.StartUnixTime - DateTime.now().UnixTimestamp, 0, 1e999))
end

function LiveOpsUtil.GetTimeUntilWindowEnd(p)
	if p.EndUnixTime then
		return p.EndUnixTime - DateTime.now().UnixTimestamp
	end

	return 1e999
end

function LiveOpsUtil.IsEventStarted(p: string)
	return LiveOpsUtil.liveOpsEventStartTimes[p] ~= nil
end

function LiveOpsUtil.StartLiveOpsEvent(p)
	LiveOpsUtil.CancelScheduledLiveOpsEventStarts(p)
	LiveOpsUtil.liveOpsEventStartTimes[p.LiveOpsEventName] = os.clock()
	task.spawn(p.OnEventEnable)
end

function LiveOpsUtil.StopLiveOpsEvent(p)
	LiveOpsUtil.CancelScheduledLiveOpsEventStops(p)

	if p.OnEventDisable then
		LiveOpsUtil.liveOpsEventStartTimes[p.LiveOpsEventName] = nil
		task.spawn(p.OnEventDisable)
	end
end

function LiveOpsUtil.CancelScheduledLiveOpsEventStarts(p)
	if v[p.LiveOpsEventName] then
		task.cancel(v[p.LiveOpsEventName])
		v[p.LiveOpsEventName] = nil
	end
end

function LiveOpsUtil.CancelScheduledLiveOpsEventStops(p)
	if v2[p.LiveOpsEventName] then
		task.cancel(v2[p.LiveOpsEventName])
		v2[p.LiveOpsEventName] = nil
	end
end

function LiveOpsUtil.StartLiveOpsEventIfInsideWindow(p, p2)
	if not LiveOpsUtil.IsCurrentTimeInsideWindow(p2) then
		return false
	end

	LiveOpsUtil.StartLiveOpsEvent(p)
	return true
end

function LiveOpsUtil.StopEventWhenWindowEnds(p, p2)
	if p2.EndUnixTime and p.OnEventDisable then
		v2[p.LiveOpsEventName] = task.delay(LiveOpsUtil.GetTimeUntilWindowEnd(p2), function()
			v2[p.LiveOpsEventName] = nil
			LiveOpsUtil.StopLiveOpsEvent(p)
		end)
	end
end

function LiveOpsUtil.StartEventWhenWindowBegins(p, p2)
	if LiveOpsUtil.IsCurrentTimeInsideWindow(p2) then
		LiveOpsUtil.StartLiveOpsEvent(p)
		return
	end

	if v[p.LiveOpsEventName] then
		task.cancel(v[p.LiveOpsEventName])
		v[p.LiveOpsEventName] = nil
	end

	v[p.LiveOpsEventName] = task.delay(LiveOpsUtil.GetTimeUntilWindowStart(p2), function()
		v[p.LiveOpsEventName] = nil
		LiveOpsUtil.StartLiveOpsEvent(p)
	end)
end

return LiveOpsUtil