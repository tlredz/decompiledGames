local RunService = game:GetService("RunService")
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local time2 = RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false and time or os.clock
local HeartbeatLoopFor = {}

function HeartbeatLoopFor.HeartbeatLoopFor(p: number, callback, callback2)
	local heartbeatConnection = nil
	local v = time2()
	local v2 = false
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		local v3 = time2() - v

		if v3 < p then
			callback(v3, dt, v3 / p)
		elseif v2 == true or callback2 == nil then
			if heartbeatConnection ~= nil then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end
		else
			v2 = true
			callback2()

			if heartbeatConnection ~= nil then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end
		end
	end)
	return heartbeatConnection
end

function HeartbeatLoopFor.AwaitHeartbeatLoopFor(p: number, callback, callback2)
	local heartbeatConnection = nil
	local v = time2()
	local bindableEvent = Instance.new("BindableEvent")
	local v2 = false
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		local v3 = time2() - v

		if v3 < p then
			callback(v3, dt, v3 / p)
		elseif v2 == true or callback2 == nil then
			if bindableEvent ~= nil then
				bindableEvent:Fire()
			end

			if heartbeatConnection ~= nil then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end
		else
			v2 = true
			callback2()

			if bindableEvent ~= nil then
				bindableEvent:Fire()
			end

			if heartbeatConnection ~= nil then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end
		end
	end)
	bindableEvent.Event:Wait()
	bindableEvent:Destroy()
end

return HeartbeatLoopFor