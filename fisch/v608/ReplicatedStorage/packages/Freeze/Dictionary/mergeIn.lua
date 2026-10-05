local mergeIn = require(script.Parent.Parent.utils.mergeIn)
local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function mergeIn2(p, p2, ...)
	return maybeFreeze(mergeIn(p, p2, ...))
end

return mergeIn2