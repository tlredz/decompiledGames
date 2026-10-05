local Tables = require(script.Parent.Parent.Libraries.Tables)
local Types = require(script.Parent.Types)
local Defaults = require(script.Parent.ConfigHandler.Defaults)
local v = {}
local MessageQueue = {}

local function InitializeMQ(p)
	if v[p] then
		return
	end

	v[p] = {
		ActiveConfig = Tables.DeepCopy(Defaults),
		NewestStartRequest = {
			RequestType = "Start",
			Time = os.clock(),
			Yields = false,
			Target = nil,
			Priority = Types.RequestPriority.ConvertPriorityToNumber("DefaultStart"),
			ProcessingState = "Processed"
		},
		NewestStopRequest = {
			RequestType = "Stop",
			Time = os.clock(),
			Yields = false,
			Priority = Types.RequestPriority.ConvertPriorityToNumber("DefaultStop"),
			ProcessingState = "Processed"
		},
		LastSuccessfulPath = {
			time = os.clock(),
			wps = {}
		},
		ActiveRequest = nil,
		Processing = false
	}
end

local function GetMQSingleton(p)
	if not v[p] then
		InitializeMQ(p)
	end

	return v[p]
end

function MessageQueue.SetLastSuccessfulPath(p, wps)
	if wps == nil then
		warn("Waypoints table was nil!")
	end

	v[p].LastSuccessfulPath = {
		time = os.clock(),
		wps = wps
	}
end

function MessageQueue.GetLastSuccessfulPath(p, _: number)
	local lastSuccessfulPath = v[p].LastSuccessfulPath

	if lastSuccessfulPath.time + 1 < os.clock() then
		return nil
	end

	return lastSuccessfulPath.wps
end

function MessageQueue.SetActiveRequest(p, activeRequest)
	activeRequest.ProcessingState = "Processing"

	if not v[p] then
		InitializeMQ(p)
	end

	v[p].ActiveRequest = activeRequest
end

function MessageQueue.PrintOutRequests(_)
	print(v)
end

function MessageQueue.GetNewRequest(p)
	if not v[p] then
		InitializeMQ(p)
	end

	local v2 = v[p]
	local v3 = v2.NewestStartRequest.ProcessingState == "Requested"
	local v4 = v2.NewestStopRequest.ProcessingState == "Requested"

	if not (v3 or v4) then
		return nil
	end

	if v3 and not v4 then
		return v2.NewestStartRequest
	end

	if v4 and not v3 then
		return v2.NewestStopRequest
	end

	local function GetPrioritizedRequest()
		local priority = v2.NewestStartRequest.Priority
		local priority2 = v2.NewestStopRequest.Priority

		if priority2 < priority then
			return v2.NewestStartRequest
		end

		if priority < priority2 then
			return v2.NewestStopRequest
		end

		return v2.NewestStartRequest
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function GetLatestRequest()
		local time = v2.NewestStartRequest.Time
		local time2 = v2.NewestStopRequest.Time

		if time2 < time then
			return v2.NewestStartRequest
		end

		if time < time2 then
			return v2.NewestStopRequest
		end

		return v2.NewestStartRequest
	end

	if v2.ActiveConfig.RequestPrioritization.PreferTimeOverPriority.Enabled then
		if not v2.ActiveConfig.RequestPrioritization.PreferTimeOverPriority.Enabled then
			error("this shouldn't be showing, if you can replicate contact @crit-dev")
			return nil
		end

		local latestRequest = GetLatestRequest() -- equivalent call inferred; original call site unknown

		if not v2.ActiveConfig.RequestPrioritization.PreferTimeOverPriority.ResetOlderRequests then
			return latestRequest
		end

		if latestRequest.RequestType == "Start" then
			v2.NewestStopRequest.ProcessingState = "Processed"
		end

		if latestRequest.RequestType == "Stop" then
			v2.NewestStartRequest.ProcessingState = "Processed"
		end

		return latestRequest
	else
		local priority = v2.NewestStartRequest.Priority
		local priority2 = v2.NewestStopRequest.Priority

		if priority2 < priority then
			return v2.NewestStartRequest
		end

		if priority < priority2 then
			return v2.NewestStopRequest
		end

		return v2.NewestStartRequest
	end
end

function MessageQueue.IsProcessingStartRequest(p)
	if not v[p] then
		InitializeMQ(p)
	end

	return v[p].NewestStartRequest.ProcessingState == "Processing"
end

function MessageQueue.IsProcessingEndRequest(p)
	if not v[p] then
		InitializeMQ(p)
	end

	return v[p].NewestStopRequest.ProcessingState == "Processing"
end

function MessageQueue.IsProcessing(p)
	return MessageQueue.IsProcessingStartRequest(p) or MessageQueue.IsProcessingEndRequest(p)
end

function MessageQueue.SendStartMessage(p, target, flag: boolean?, p3)
	if not v[p] then
		InitializeMQ(p)
	end

	local v2 = v[p]
	local convertPriorityToNumber = Types.RequestPriority.ConvertPriorityToNumber("DefaultStart")

	if p3 ~= nil then
		convertPriorityToNumber = Types.RequestPriority.GetPriorityNumber(p3)
	end

	if v2.NewestStartRequest.ProcessingState == "Requested" and convertPriorityToNumber < v2.NewestStartRequest.Priority then
		return
	end

	v2.NewestStartRequest = {
		Time = os.clock(),
		Target = target,
		Yields = flag or false,
		Priority = convertPriorityToNumber,
		ProcessingState = "Requested",
		RequestType = "Start",
		FinishedSignal = nil
	}
	local bindableEvent

	if flag then
		bindableEvent = Instance.new("BindableEvent")
		v2.NewestStartRequest.FinishedSignal = bindableEvent
	end

	return bindableEvent
end

function MessageQueue.SendStopMessage(p, flag: boolean?, p2)
	if not v[p] then
		InitializeMQ(p)
	end

	local v2 = v[p]
	local convertPriorityToNumber = Types.RequestPriority.ConvertPriorityToNumber("DefaultStop")

	if p2 ~= nil then
		convertPriorityToNumber = Types.RequestPriority.GetPriorityNumber(p2)
	end

	if v2.NewestStopRequest.ProcessingState == "Requested" and convertPriorityToNumber < v2.NewestStopRequest.Priority then
		return
	end

	v2.NewestStopRequest = {
		Time = os.clock(),
		Yields = flag or false,
		Priority = convertPriorityToNumber,
		ProcessingState = "Requested",
		RequestType = "Stop",
		FinishedSignal = nil
	}
	local bindableEvent

	if flag then
		bindableEvent = Instance.new("BindableEvent")
		v2.NewestStopRequest.FinishedSignal = bindableEvent
	end

	return bindableEvent
end

return MessageQueue