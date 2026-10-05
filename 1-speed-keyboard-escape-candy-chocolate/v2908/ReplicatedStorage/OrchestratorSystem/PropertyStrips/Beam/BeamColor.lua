local parent = script.Parent.Parent.Parent
local PropertyStripBuilder = require(parent.PropertyStripBuilder)

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function linearToSrgb(p: number)
	if p <= 0.0031308 then
		return p * 12.92
	end

	return p ^ 0.4166666666666667 * 1.055 - 0.055
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function srgbToLinear(p: number)
	if p <= 0.04045 then
		return p / 12.92
	end

	return ((p + 0.055) / 1.055) ^ 2.4
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function cbrt(p: number)
	if p < 0 then
		return -(-p) ^ 0.3333333333333333
	end

	return p ^ 0.3333333333333333
end

local function color3ToOKLab(color: Color3)
	local v = srgbToLinear(color.R)
	local v2 = srgbToLinear(color.G)
	local v3 = srgbToLinear(color.B)
	local v4 = v * 0.4122214708 + v2 * 0.5363325363 + v3 * 0.0514459929
	local v5 = v * 0.2119034982 + v2 * 0.6806995451 + v3 * 0.1073969566
	local v6 = v * 0.0883024619 + v2 * 0.2817188376 + v3 * 0.6299787005
	local v7 = cbrt(v4)
	local v8 = cbrt(v5)
	local v9 = cbrt(v6)
	return
		v7 * 0.2104542553 + v8 * 0.793617785 - v9 * 0.0040720468,
		v7 * 1.9779984951 - v8 * 2.428592205 + v9 * 0.4505937099,
		v7 * 0.0259040371 + v8 * 0.7827717662 - v9 * 0.808675766
end

local function oklabToColor3(p: number, p2: number, p3: number)
	local v = p + p2 * 0.3963377774 + p3 * 0.2158037573
	local v2 = p - p2 * 0.1055613458 - p3 * 0.0638541728
	local v3 = p - p2 * 0.0894841775 - p3 * 1.291485548
	local v4 = v ^ 3
	local v5 = v2 ^ 3
	local v6 = v3 ^ 3
	local v7 = v4 * 4.0767416621 - v5 * 3.3077115913 + v6 * 0.2309699292
	local v8 = v4 * -1.2684380046 + v5 * 2.6097574011 - v6 * 0.3413193965
	local v9 = v4 * -0.0041960863 - v5 * 0.7034186147 + v6 * 1.707614701
	local v10 = linearToSrgb(v7)
	local v11 = math.clamp(v10, 0, 1)
	local v12 = linearToSrgb(v8)
	local v13 = math.clamp(v12, 0, 1)
	local v14 = linearToSrgb(v9)
	return Color3.new(v11, v13, (math.clamp(v14, 0, 1)))
end

local function lerpColor3Nice(color: Color3, color2: Color3, value: number)
	local v = math.clamp(value, 0, 1)
	local v2, v3, v4 = color3ToOKLab(color)
	local v5, v6, v7 = color3ToOKLab(color2)
	return oklabToColor3(v2 + (v5 - v2) * v, v3 + (v6 - v3) * v, v4 + (v7 - v4) * v)
end

return PropertyStripBuilder.Create({
	Type = "BeamColor",
	DisplayName = "Color",
	CanAutoCapture = true,
	Supports = function(beam)
		return beam:IsA("Beam")
	end,
	ValidateValue = function(color: Color3)
		if typeof(color) == "Color3" then
			return true, nil
		end

		return false, "BeamColor keyframes must contain a Color3 Value."
	end,
	Capture = function(p)
		return p.Color.Keypoints[1].Value
	end,
	Interpolate = function(color: Color3, color2: Color3, p: number)
		return lerpColor3Nice(color, color2, p)
	end,
	Apply = function(p, color: Color3, _)
		p.Color = ColorSequence.new(color)
	end
})