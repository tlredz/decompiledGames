local slice = require(script.Parent.slice)

local function butLast(p)
	return slice(p, 1, -1)
end

return butLast