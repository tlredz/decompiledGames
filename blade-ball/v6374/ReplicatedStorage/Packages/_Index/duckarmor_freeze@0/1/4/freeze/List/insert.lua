local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function insert(list, value: number, ...)
	local count = #list

	if value < 1 then
		value = count + value
	end

	local v = math.clamp(value, 1, count + 1)
	local v2 = {}
	local v3 = 1

	for i = 1, count + 1 do
		if i == v then
			for i2 = 1, select("#", ...) do
				v2[v3] = select(i2, ...)
				v3 += 1
			end
		end

		v2[v3] = list[i]
		v3 += 1
	end

	return maybeFreeze(v2)
end

return insert