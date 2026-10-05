local Color = require(script.Parent.Parent:WaitForChild("Color"))

local function distance(p, p2, p3: string?)
	local v = p3 == nil and "lab" or p3
	local v2 = Color.new(p)
	local v3 = Color.new(p2)
	local v4 = v2:get(v)
	local v5 = v3:get(v)
	local total = 0

	for k in v4 do
		local v6 = (v4[k] or 0) - (v5[k] or 0)
		total += v6 * v6
	end

	return (math.sqrt(total))
end

return distance