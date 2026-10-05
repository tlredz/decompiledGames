local assertDeepEqual = require(script.Parent.assertDeepEqual)

local function createSpy(callback)
	local v = {
		callCount = 0,
		values = {},
		valuesLength = 0
	}

	function v.value(...)
		v.callCount += 1
		v.values = { ... }
		v.valuesLength = select("#", ...)

		if callback == nil then
			return nil
		end

		return callback(...)
	end

	function v.assertCalledWith(_, ...)
		local v2 = select("#", ...)

		if v.valuesLength ~= v2 then
			error(("Expected %d arguments, but was called with %d arguments"):format(v.valuesLength, v2), 2)
		end

		for i = 1, v2 do
			local v3 = select(i, ...)
			assert(v.values[i] == v3, "value differs")
		end
	end

	function v.assertCalledWithDeepEqual(_, ...)
		local v2 = select("#", ...)

		if v.valuesLength ~= v2 then
			error(("Expected %d arguments, but was called with %d arguments"):format(v.valuesLength, v2), 2)
		end

		for i = 1, v2 do
			local v3 = select(i, ...)
			assertDeepEqual(v.values[i], v3)
		end
	end

	function v.captureValues(_, ...)
		local v2 = select("#", ...)
		assert(v.valuesLength == v2, "length of expected values differs from stored values")
		local result = {}

		for i = 1, v2 do
			result[select(i, ...)] = v.values[i]
		end

		return result
	end

	setmetatable(v, {
		__index = function(_, p)
			error(("%q is not a valid member of spy"):format(p))
		end
	})
	return v
end

return createSpy