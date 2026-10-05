local reduce = require(script.Parent.Parent.utils.reduce)

local function reduce2(p, callback, p2)
	return reduce(p, callback, p2, false)
end

return reduce2