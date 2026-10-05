local slice = require(script.Parent.slice)

local function takeLast(p, p2: number)
	return slice(p, -math.max(1, p2))
end

return takeLast