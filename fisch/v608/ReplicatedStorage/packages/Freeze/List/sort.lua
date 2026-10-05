local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function sort(p, callback)
	local clone = table.clone(p)
	table.sort(clone, callback)
	return maybeFreeze(clone)
end

return sort