local sRGB = require(script.Parent.sRGB)
local Oklab = {
	fromLinear = function(color: Color3)
		local v = color.R * 0.4122214708 + color.G * 0.5363325363 + color.B * 0.0514459929
		local v2 = color.R * 0.2119034982 + color.G * 0.6806995451 + color.B * 0.1073969566
		local v3 = color.R * 0.0883024619 + color.G * 0.2817188376 + color.B * 0.6299787005
		local v4 = v ^ 0.3333333333333333
		local v5 = v2 ^ 0.3333333333333333
		local v6 = v3 ^ 0.3333333333333333
		return (Vector3.new(
			v4 * 0.2104542553 + v5 * 0.793617785 - v6 * 0.0040720468,
			v4 * 1.9779984951 - v5 * 2.428592205 + v6 * 0.4505937099,
			v4 * 0.0259040371 + v5 * 0.7827717662 - v6 * 0.808675766
		))
	end
}

function Oklab.fromSRGB(color: Color3)
	return Oklab.fromLinear(sRGB.toLinear(color))
end

function Oklab.toLinear(vector: Vector3, flag: boolean?)
	local v = vector.X + vector.Y * 0.3963377774 + vector.Z * 0.2158037573
	local v2 = vector.X - vector.Y * 0.1055613458 - vector.Z * 0.0638541728
	local v3 = vector.X - vector.Y * 0.0894841775 - vector.Z * 1.291485548
	local v4 = v ^ 3
	local v5 = v2 ^ 3
	local v6 = v3 ^ 3
	local v7 = v4 * 4.0767416621 - v5 * 3.3077115913 + v6 * 0.2309699292
	local v8 = v4 * -1.2684380046 + v5 * 2.6097574011 - v6 * 0.3413193965
	local v9 = v4 * -0.0041960863 - v5 * 0.7034186147 + v6 * 1.707614701

	if not flag then
		v7 = math.clamp(v7, 0, 1)
		v8 = math.clamp(v8, 0, 1)
		v9 = math.clamp(v9, 0, 1)
	end

	return Color3.new(v7, v8, v9)
end

function Oklab.toSRGB(vector: Vector3, flag: boolean?)
	return sRGB.fromLinear(Oklab.toLinear(vector, flag))
end

return Oklab