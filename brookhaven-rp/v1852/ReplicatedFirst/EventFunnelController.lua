local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Stats = game:GetService("Stats")
local ClientPerformanceTrackingController = require(ReplicatedFirst.ClientPerformanceTrackingController)
local EventFunnelController = {
	lastLoadingEventTime = nil
}
local v = nil
local v2 = {}

local function dispatch(remoteName: string, ...)
	if v == nil then
		table.insert(v2, {
			remoteName = remoteName,
			args = { ... }
		})
	else
		v(remoteName, ...)
	end
end

function EventFunnelController.setSender(callback)
	v = callback
	local v3 = v2
	v2 = {}

	for _, v4 in v3 do
		callback(v4.remoteName, table.unpack(v4.args))
	end
end

function EventFunnelController.informGeneralEvent(p: string, p2)
	dispatch("InformGeneralEventFunnel", p, p2)
end

function EventFunnelController.informLoadingEvent(p: string)
	local timeSpent = EventFunnelController.lastLoadingEventTime == nil and 0 or os.clock() - EventFunnelController.lastLoadingEventTime
	EventFunnelController.lastLoadingEventTime = os.clock()
	local v4 = {
		ping = Players.LocalPlayer:GetNetworkPing(),
		totalMemory = Stats:GetTotalMemoryUsageMb(),
		oneSecondAverageFPS = ClientPerformanceTrackingController.GetOneSecondAverageFPS(),
		timeStamp = workspace:GetServerTimeNow(),
		timeSpent = timeSpent
	}
	task.spawn(function()
		dispatch("InformLoadingEventFunnel", p, v4)
	end)
end

return EventFunnelController