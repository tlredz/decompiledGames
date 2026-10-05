local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local RunService = game:GetService("RunService")
local time2 = RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false and time or os.clock
return function(p, callback, callback2)
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
end