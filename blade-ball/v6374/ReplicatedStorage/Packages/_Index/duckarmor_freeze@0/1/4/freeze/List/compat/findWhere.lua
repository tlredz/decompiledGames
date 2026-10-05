local find = require(script.Parent.Parent.find)
local deprecationWarning = require(script.Parent.Parent.Parent.utils.deprecationWarning)

local function findWhere(p, callback, from)
	assert(from == nil, "[Freeze] findWhere's `from` argument is not supported.")
	deprecationWarning("List." .. script.Name, "List.find")
	return find(p, callback)
end

return findWhere