local RunService = game:GetService("RunService")
return function(value, value2, value3, callback, p, value4)
	assert(typeof(value) == "number", "Argument 1 invalid, expected a number, got " .. tostring(value))
	assert(typeof(value2) == "number", "Argument 2 invalid, expected a number, got " .. tostring(value2))
	assert(
		typeof(value3) == "number" or typeof(value3) == "function",
		"Argument 3 invalid, expected a number or function, got " .. tostring(value3)
	)
	assert(typeof(callback) == "function", "Argument 4 invalid, expected a function, got " .. tostring(callback))
	assert(not p or typeof(p) == "boolean", "Argument 5 invalid, expected a boolean or nil, got " .. tostring(p))
	assert(
		not value4 or typeof(value4) == "number",
		"Argument 6 invalid, expected a number or nil, got " .. tostring(value4)
	)
	local v = typeof(value3) == "function"
	local v2 = value4 or 1

	while true do
		local v3 = v and value3() or value3

		if v3 > 0 and value2 < value or v3 < 0 and value < value2 then
			break
		end

		if callback(value) then
			return
		end

		local lastTime = tick()

		for _ = 1, v2 do
			RunService.Heartbeat:Wait()
		end

		value += v3 * (tick() - lastTime) * 60 / v2
	end

	if not p then
		callback(value2)
	end
end