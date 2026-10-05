local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function pop(list, value: number?)
	local v = math.max(1, value or 1)
	local count = #list
	local v2 = table.create(count)

	for i = 1, count - v do
		v2[i] = list[i]
	end

	return maybeFreeze(v2)
end

return pop