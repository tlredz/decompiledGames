local updateIn = require(script.Parent.Parent.utils.updateIn)
local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function updateIn2(p, p2, callback, p3)
	return maybeFreeze(updateIn(p, p2, callback, p3))
end

return updateIn2