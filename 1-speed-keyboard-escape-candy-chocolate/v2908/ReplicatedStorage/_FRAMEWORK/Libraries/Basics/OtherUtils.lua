local Common = require(script.Parent.Common)
local OtherUtils = {}

function OtherUtils.getValueFromNumberRange(range: NumberRange, _)
	return Common.GetRandom():NextNumber(range.Min, range.Max)
end

function OtherUtils.getAllEnumKeys(object)
	local names = {}

	for _, v in object:GetEnumItems() do
		table.insert(names, v.Name)
	end

	return names
end

function OtherUtils.retryOperation(callback, options)
	local lastTime = os.clock()

	local function trySubscribing()
		return pcall(callback)
	end

	local success = false
	local v = options or {}
	local count = 0

	while not success do
		local result
		success, result = pcall(callback)

		if success then
			return true, result
		end

		if v.maxRetry and v.maxRetry <= count then
			return false, result
		end

		count += 1

		if v.onRetry then
			v.onRetry(result, count)
		end

		if v.timeOut and os.clock() - lastTime > v.timeOut then
			return false, "retryOperation timed out"
		end

		if v.shouldContinue then
			local success2, result2 = pcall(v.shouldContinue)

			if not success2 then
				return false, (`shouldContinue threw an error: {result2}`)
			end

			if not result2 then
				return false, "shouldContinue returned false"
			end
		end

		local v2 = (not v.exponentialBackoff and 1 or count) * (v.tryInterval or 1)
		task.wait((math.min(v2, v.maxInterval or 1e999)))
	end

	return error("Should never happen?")
end

return OtherUtils