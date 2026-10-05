local labconstants = require(script.Parent:WaitForChild("lab-constants"))
local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local pow = math.pow
local rgb2xyz

local function rgb2lab(...)
	local v = table.pack(...)
	local v2, v3, v4 = table.unpack(unpack(v, "rgb"), 1, 3)
	local v5, v6, v7 = rgb2xyz(v2, v3, v4)
	local v8 = 116 * v6 - 16
	return { v8 < 0 and 0 or v8, 500 * (v5 - v6), 200 * (v6 - v7) }
end

local function rgb_xyz(p: number)
	local v = p / 255

	if v <= 0.04045 then
		return v / 12.92
	end

	return (pow((v + 0.055) / 1.055, 2.4))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function xyz_lab(p: number)
	if labconstants.t3 < p then
		return (pow(p, 0.3333333333333333))
	end

	return p / labconstants.t2 + labconstants.t0
end

rgb2xyz = function(p: number, p2: number, p3: number)
	local v = p / 255
	local v2

	if v <= 0.04045 then
		v2 = v / 12.92
	else
		v2 = pow((v + 0.055) / 1.055, 2.4)
	end

	local v3 = p2 / 255
	local v4

	if v3 <= 0.04045 then
		v4 = v3 / 12.92
	else
		v4 = pow((v3 + 0.055) / 1.055, 2.4)
	end

	local v5 = p3 / 255
	local v6

	if v5 <= 0.04045 then
		v6 = v5 / 12.92
	else
		v6 = pow((v5 + 0.055) / 1.055, 2.4)
	end

	local v8 = xyz_lab((v2 * 0.4124564 + v4 * 0.3575761 + v6 * 0.1804375) / labconstants.Xn) -- equivalent call inferred; original call site unknown
	local selected = xyz_lab((v2 * 0.2126729 + v4 * 0.7151522 + v6 * 0.072175) / labconstants.Yn) -- equivalent call inferred; original call site unknown
	local v11 = (v2 * 0.0193339 + v4 * 0.119192 + v6 * 0.9503041) / labconstants.Zn

	if labconstants.t3 < v11 then
		return v8, selected, (pow(v11, 0.3333333333333333))
	end

	return v8, selected, v11 / labconstants.t2 + labconstants.t0
end

return rgb2lab