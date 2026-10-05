local Color = require(script.Parent.Parent:WaitForChild("Color"))
local sqrt = math.sqrt
local pow = math.pow

local function lrgb(p, p2, p3: number)
	local v, v2, v3 = table.unpack(p._rgb, 1, 3)
	local v4, v5, v6 = table.unpack(p2._rgb, 1, 3)
	return Color.new(
		sqrt(pow(v, 2) * (1 - p3) + pow(v4, 2) * p3),
		sqrt(pow(v2, 2) * (1 - p3) + pow(v5, 2) * p3),
		sqrt(pow(v3, 2) * (1 - p3) + pow(v6, 2) * p3),
		"rgb"
	)
end

local parentModule = require(script.Parent)
parentModule.lrgb = lrgb
return lrgb