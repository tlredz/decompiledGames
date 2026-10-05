local findPair = require(script.Parent.Parent.utils.findPair)

local function find(p, callback, p2)
	local _, v = findPair(p, callback)

	if v == nil then
		return p2
	end

	return v
end

return find