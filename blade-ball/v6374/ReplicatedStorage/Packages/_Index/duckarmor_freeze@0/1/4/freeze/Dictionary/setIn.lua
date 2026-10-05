local setIn = require(script.Parent.Parent.utils.setIn)
local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function setIn2(p, p2, p3)
	return maybeFreeze(setIn(p, p2, p3))
end

return setIn2