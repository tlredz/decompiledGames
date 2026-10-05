local slice = require(script.Parent.Parent.utils.slice)
local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function slice2(p, p2: number?, p3: number?)
	return maybeFreeze(slice(p, p2, p3))
end

return slice2