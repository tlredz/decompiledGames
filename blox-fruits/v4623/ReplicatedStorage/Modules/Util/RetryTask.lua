local function getMaxRequestTime(p: number, p2: number, p3: number)
	local total = 0

	for i = 1, p do
		total += p2 + p3 ^ i
	end

	return total
end

local function retryTask(callback, data)
	local optionalPauseConstant = data.optionalPauseConstant or 0
	local optionalPauseExponent = data.optionalPauseExponent or 0
	local optionalFunctionCallHandler = data.optionalFunctionCallHandler or pcall
	local maxAttempts = data.maxAttempts

	if data.optionalMaxTime then
		maxAttempts = math.floor(math.log(data.optionalMaxTime - optionalPauseConstant) / math.log(optionalPauseExponent))
	end

	assert(maxAttempts)
	local lastTime = tick()
	local count = 0
	local v = nil
	local v2 = nil

	while count < maxAttempts do
		count += 1
		v2 = { optionalFunctionCallHandler(callback) }
		v = table.remove(v2, 1)

		if v then
			break
		end

		local v3 = optionalPauseConstant + optionalPauseExponent ^ count

		if count < maxAttempts then
			task.wait(v3)
		end
	end

	if data.debug then
		local total = 0

		for i = 1, maxAttempts do
			total += optionalPauseConstant + optionalPauseExponent ^ i
		end

		warn((`Context: {data.debug}`))
		print(
			`MaxAttempts: {maxAttempts}`,
			`MaxRequestTime: {total}/{data.optionalMaxTime or total}`,
			`Elapsed: {tick() - lastTime}`,
			`Success: {v}`,
			"Result",
			v2
		)
		print("\n")
	end

	if v then
		return v, table.unpack(v2)
	end

	local v3

	if not v then
		v3 = v2[1] or nil
	end

	return v, v3
end

return retryTask