local set = require(script.Parent.Parent.utils.set)
local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function remove(p, ...)
	local clone = table.clone(p)

	for _, v in { ... } do
		clone = set(clone, v, nil)
	end

	return maybeFreeze(clone)
end

return remove