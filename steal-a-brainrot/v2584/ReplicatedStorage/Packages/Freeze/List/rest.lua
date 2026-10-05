local slice = require(script.Parent.slice)

local function rest(p)
	return slice(p, 2)
end

return rest