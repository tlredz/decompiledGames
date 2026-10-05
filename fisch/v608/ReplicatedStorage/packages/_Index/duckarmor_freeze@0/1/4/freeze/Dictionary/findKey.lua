local findPair = require(script.Parent.Parent.utils.findPair)

local function findKey(p, callback, p2)
	local pair, _ = findPair(p, callback)

	if pair == nil then
		return p2
	end

	return pair
end

return findKey