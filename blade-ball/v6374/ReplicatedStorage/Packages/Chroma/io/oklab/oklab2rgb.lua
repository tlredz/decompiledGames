local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local pow = math.pow
local sign = math.sign
local lrgb2rgb

local function oklab2rgb(...)
	local v = unpack(table.pack(...), "lab")
	local v2, v3, v4 = table.unpack(v, 1, 3)
	local v6 = pow(v2 + 0.3963377774 * v3 + 0.2158037573 * v4, 3)
	local v8 = pow(v2 - 0.1055613458 * v3 - 0.0638541728 * v4, 3)
	local v10 = pow(v2 - 0.0894841775 * v3 - 1.291485548 * v4, 3)
	return {
		255 * lrgb2rgb(v6 * 4.0767416621 - v8 * 3.3077115913 + v10 * 0.2309699292),
		255 * lrgb2rgb(v6 * -1.2684380046 + v8 * 2.6097574011 - v10 * 0.3413193965),
		255 * lrgb2rgb(v6 * -0.004196086299999999 - v8 * 0.7034186147 + v10 * 1.707614701),
		not (#v > 3) and 1 or v[4]
	}
end

lrgb2rgb = function(p)
	local v = math.abs(p)

	if v > 0.0031308 then
		local v2 = sign(p)
		return (v2 == 0 and 1 or v2) * (pow(v, 0.4166666666666667) * 1.055 - 0.055)
	else
		return p * 12.92
	end
end

return oklab2rgb