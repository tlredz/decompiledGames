local get = require(script.Parent.get)

local function last(p, p2)
	return get(p, -1, p2)
end

return last