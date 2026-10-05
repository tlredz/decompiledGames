local update = require(script.Parent.Parent.utils.update)
local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function update2(p, p2, callback, p3)
	return maybeFreeze(update(p, p2, callback, p3))
end

return update2