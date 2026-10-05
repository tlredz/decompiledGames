local slice = require(script.Parent.slice)

local function skip(p, p2: number)
	return slice(p, (math.max(1, p2 + 1)))
end

return skip