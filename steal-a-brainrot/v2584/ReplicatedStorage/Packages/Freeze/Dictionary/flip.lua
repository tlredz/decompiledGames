local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function flip(items)
	local v = {}

	for k, item in items do
		v[item] = k
	end

	return maybeFreeze(v)
end

return flip