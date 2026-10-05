local utils = script.Parent.Parent.utils
local updateIn = require(utils.updateIn)
local maybeFreeze = require(utils.maybeFreeze)
return function(p, p2, callback, p3)
	return maybeFreeze(updateIn(p, p2, callback, p3))
end