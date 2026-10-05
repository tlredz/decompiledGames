local reverse = require(script.Parent.Parent.reverse)
local find = require(script.Parent.Parent.find)
local deprecationWarning = require(script.Parent.Parent.Parent.utils.deprecationWarning)

local function findWhereLast(p, callback, from)
	assert(from == nil, "[Freeze] findWhereLast's `from` argument is not supported.")
	deprecationWarning("List." .. script.Name, "List.reverse and then List.find")
	return find(reverse(p), callback)
end

return findWhereLast