local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function reverse(list)
	local count = #list
	local v = table.create(count)
	local v2 = count + 1

	for k, _ in list do
		v[k] = list[v2 - k]
	end

	return maybeFreeze(v)
end

return reverse