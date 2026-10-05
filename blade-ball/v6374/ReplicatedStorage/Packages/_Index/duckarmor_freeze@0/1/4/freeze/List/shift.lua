local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function shift(list, value: number?)
	local count = #list
	local v = math.min(count, value or 1)
	local v2 = table.create(count - v)

	for i = v + 1, count do
		v2[i - v] = list[i]
	end

	return maybeFreeze(v2)
end

return shift