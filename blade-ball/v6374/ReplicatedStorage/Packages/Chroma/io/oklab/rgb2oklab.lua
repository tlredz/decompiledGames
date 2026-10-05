local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack

local function cbrt(p: number)
	return p ^ 0.3333333333333333
end

local pow = math.pow
local sign = math.sign
local rgb2lrgb

local function rgb2oklab(...)
	local v, v2, v3 = table.unpack(unpack(table.pack(...), "rgb"), 1, 3)
	local v4, v5, v6 = table.unpack({ rgb2lrgb(v / 255), rgb2lrgb(v2 / 255), rgb2lrgb(v3 / 255) }, 1, 3)
	local v7 = (0.4122214708 * v4 + 0.5363325363 * v5 + 0.0514459929 * v6) ^ 0.3333333333333333
	local v8 = (0.2119034982 * v4 + 0.6806995451 * v5 + 0.1073969566 * v6) ^ 0.3333333333333333
	local v9 = (0.0883024619 * v4 + 0.2817188376 * v5 + 0.6299787005 * v6) ^ 0.3333333333333333
	return {
		v7 * 0.2104542553 + v8 * 0.793617785 - v9 * 0.0040720468,
		v7 * 1.9779984951 - v8 * 2.428592205 + v9 * 0.4505937099,
		v7 * 0.0259040371 + v8 * 0.7827717662 - v9 * 0.808675766
	}
end

rgb2lrgb = function(p)
	local v = math.abs(p)

	if v < 0.04045 then
		return p / 12.92
	end

	local v2 = sign(p)
	return (v2 == 0 and 1 or v2) * pow((v + 0.055) / 1.055, 2.4)
end

return rgb2oklab