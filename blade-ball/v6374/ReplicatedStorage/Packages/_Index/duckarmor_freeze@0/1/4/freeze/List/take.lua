local slice = require(script.Parent.slice)

local function take(p, p2: number)
	return slice(p, 1, (math.max(1, p2)))
end

return take