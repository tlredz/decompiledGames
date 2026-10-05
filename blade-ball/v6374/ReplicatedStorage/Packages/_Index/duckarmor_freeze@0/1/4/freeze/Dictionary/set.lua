local set = require(script.Parent.Parent.utils.set)
local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function set2(p, p2, p3)
	if p2 == nil then
		return p
	end

	return maybeFreeze(set(p, p2, p3))
end

return set2