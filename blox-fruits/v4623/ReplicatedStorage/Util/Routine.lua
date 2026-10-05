local RunService = game:GetService("RunService")
local stepped = RunService.Stepped
return function(p, callback, value)
	local lastTime = tick()
	local lastTime2 = tick()
	local v = value or 0.01

	while tick() - lastTime < p do
		local v2 = { callback((tick() - lastTime) / (p == 1e999 and 1 or p), tick() - lastTime2) }
		lastTime2 = tick()

		if select("#", unpack(v2)) > 0 then
			return unpack(v2)
		end

		if v <= 0 then
			stepped:wait()
		else
			task.wait(v)
		end
	end

	return callback(1, tick() - lastTime2)
end