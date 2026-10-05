local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function zip(...)
	local v = select(1, ...)
	local result = {}
	local v2 = select("#", ...)

	if v2 <= 0 then
		return result
	end

	local count = #v

	for i = 2, v2 do
		local count2 = #select(i, ...)

		if count2 < count then
			count = count2
		end
	end

	for i = 1, count do
		result[i] = {}

		for i2 = 1, v2 do
			local v3 = select(i2, ...)
			result[i][i2] = v3[i]
		end
	end

	return maybeFreeze(result)
end

return zip