local merge = require(script.Parent.Parent.utils.merge)
local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function merge2(...)
	return maybeFreeze(merge(...))
end

return merge2