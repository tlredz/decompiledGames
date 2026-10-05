local removeIn = require(script.Parent.Parent.utils.removeIn)
local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function removeIn2(p, p2)
	return maybeFreeze(removeIn(p, p2))
end

return removeIn2