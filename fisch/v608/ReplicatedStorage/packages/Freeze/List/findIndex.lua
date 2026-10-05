local findPair = require(script.Parent.Parent.utils.findPair)

local function findIndex(p, callback)
	local pair, _ = findPair(p, callback)
	return pair
end

return findIndex