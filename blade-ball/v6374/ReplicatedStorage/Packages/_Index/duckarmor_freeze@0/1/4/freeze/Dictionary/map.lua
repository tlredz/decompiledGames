local map = require(script.Parent.Parent.utils.map)
local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function map2(p, callback)
	return maybeFreeze(map(p, callback))
end

return map2