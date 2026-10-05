local number = require(script.Parent.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("number"))
local labconstants = require(script.Parent:WaitForChild("lab-constants"))
local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local pow = math.pow
local xyz_rgb
local lab_xyz

local function lab2rgb(...)
	local v = unpack(table.pack(...), "lab")
	local v2, v3, v4 = table.unpack(v, 1, 3)
	local v5 = (v2 + 16) / 116
	local v6

	if number.isNaN(v3) then
		v6 = v5
	else
		v6 = v5 + v3 / 500
	end

	local v7

	if number.isNaN(v4) then
		v7 = v5
	else
		v7 = v5 - v4 / 200
	end

	local v8 = labconstants.Yn * lab_xyz(v5)
	local v9 = labconstants.Xn * lab_xyz(v6)
	local v10 = labconstants.Zn * lab_xyz(v7)
	return {
		xyz_rgb(3.2404542 * v9 - 1.5371385 * v8 - 0.4985314 * v10),
		xyz_rgb(-0.969266 * v9 + 1.8760108 * v8 + 0.041556 * v10),
		xyz_rgb(0.0556434 * v9 - 0.2040259 * v8 + 1.0572252 * v10),
		not (#v > 3) and 1 or v[4]
	}
end

xyz_rgb = function(p: number)
	local v

	if p <= 0.00304 then
		v = p * 12.92
	else
		v = pow(p, 0.4166666666666667) * 1.055 - 0.055
	end

	return v * 255
end

lab_xyz = function(p: number)
	if labconstants.t1 < p then
		return p * p * p
	end

	return labconstants.t2 * (p - labconstants.t0)
end

return lab2rgb