local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Types"):WaitForChild("EventType"))
local EventInfoService = {
	Initialized = false
}
local v = {}
local v2 = {}
local callbacks = {}
local callbacks2 = {}
local callbacks3 = {}

function EventInfoService:GetMainEvent()
	for _, v3 in v do
		if v3.Priority == "Main" then
			return v3
		end
	end

	return nil
end

function EventInfoService.GetActiveEvents(_)
	return v2
end

function EventInfoService:IsEventActive(p)
	return v2[p.Title] ~= nil
end

function EventInfoService.IsEventTypeActive(_, p: string)
	for _, v3 in v do
		if v3.Name == p and EventInfoService:IsEventActive(v3) then
			return true
		end
	end

	return false
end

function EventInfoService:GetLeaderboardStatus(p)
	local serverTimeNow = math.floor((workspace:GetServerTimeNow()))
	local v3 = nil
	local pauseStartTime = p.EventStartInfo.Leaderboards.Points.PauseStartTime
	local pauseEndTime = p.EventStartInfo.Leaderboards.Points.PauseEndTime
	local endTime = p.EventStartInfo.Leaderboards.Points.EndTime
	local v4 = nil

	if serverTimeNow < pauseStartTime then
		v3 = pauseStartTime - serverTimeNow
		v4 = "pausingSoon"
	elseif pauseStartTime <= serverTimeNow and serverTimeNow < pauseEndTime then
		v3 = pauseEndTime - serverTimeNow
		v4 = "paused"
	elseif pauseEndTime <= serverTimeNow and serverTimeNow <= endTime then
		v3 = endTime - serverTimeNow
		v4 = "endingSoon"
	elseif endTime <= serverTimeNow then
		v4 = "ended"
		v3 = 0
	end

	return v4, v3
end

function EventInfoService.IsLeaderboardActive(_, p)
	if not (p.EventStartInfo and p.EventStartInfo.Leaderboards) then
		return false
	end

	local leaderboardStatus, _ = EventInfoService:GetLeaderboardStatus(p)
	return leaderboardStatus == "pausingSoon" or leaderboardStatus == "endingSoon"
end

function EventInfoService.GetTimeElapsedSinceEventStart(_, p)
	return (math.max(DateTime.now().UnixTimestamp - p.EventStartTime, 0))
end

function EventInfoService.GetTimeElapsedSinceEventEnd(_, p)
	return (math.max(DateTime.now().UnixTimestamp - p.EventEndTime, 0))
end

function EventInfoService.GetTimeUntilEventStart(_, p)
	local unixTimestamp = DateTime.now().UnixTimestamp
	local eventStartTime = p.EventStartTime
	return (math.clamp(eventStartTime - unixTimestamp, 0, eventStartTime))
end

function EventInfoService.GetTimeUntilEventEnd(_, p)
	local unixTimestamp = DateTime.now().UnixTimestamp
	local eventEndTime = p.EventEndTime
	return (math.clamp(eventEndTime - unixTimestamp, 0, eventEndTime))
end

function EventInfoService.GetEventStatus(_, p)
	local unixTimestamp = DateTime.now().UnixTimestamp

	if unixTimestamp < p.EventStartTime then
		return "NotStarted"
	end

	if unixTimestamp < p.EventEndTime then
		return "Active"
	end

	return "Ended"
end

function EventInfoService.RegisterEvent(_, p, p2)
	v[p] = p2
end

function EventInfoService.GetEvent(_, p: string)
	return v[p]
end

function EventInfoService.GetRegisteredEvents(_)
	return v
end

function EventInfoService._StartEvent(_, p)
	for _, callback in callbacks do
		task.spawn(callback, p)
	end

	if p.Priority == "Main" then
		for _, callback in callbacks2 do
			task.spawn(callback, p)
		end
	end

	v2[p.Title] = p
end

function EventInfoService._EndEvent(_, p)
	for _, callback in callbacks3 do
		task.spawn(callback, p)
	end

	v2[p.Title] = nil
end

function EventInfoService:WaitForInitializedAsync()
	while not EventInfoService.Initialized do
		task.wait()
	end

	return EventInfoService
end

function EventInfoService.OnMainEventStarted(_, callback)
	EventInfoService:WaitForInitializedAsync()
	local mainEvent = EventInfoService:GetMainEvent()

	if mainEvent then
		local v3 = mainEvent.EventEndInfo and mainEvent.EventEndInfo.RemoveUI == false

		if mainEvent.Status == "Started" or mainEvent.Status == "Ended" and v3 then
			task.spawn(callback, mainEvent)
		end
	end

	table.insert(callbacks2, callback)
end

function EventInfoService.OnEventStarted(_, callback)
	EventInfoService:WaitForInitializedAsync()

	for _, v3 in v do
		if v3.Status == "Started" then
			task.spawn(callback, v3)
		end
	end

	table.insert(callbacks, callback)
end

function EventInfoService.OnEventEnded(_, callback)
	EventInfoService:WaitForInitializedAsync()

	for _, v3 in v do
		if v3.Status == "Ended" then
			task.spawn(callback, v3)
		end
	end

	table.insert(callbacks3, callback)
end

return EventInfoService