-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function transform(p: number)
	if p < 0.04045 then
		return p / 12.92
	end

	return ((p + 0.055) / 1.055) ^ 2.4
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function inverse(p: number)
	if p < 0.0031308 then
		return p * 12.92
	end

	return p ^ 0.4166666666666667 * 1.055 - 0.055
end

local SRGB = {}

function SRGB.fromLinear(color: Color3)
	return Color3.new(inverse(color.R), inverse(color.G), (inverse(color.B)))
end

function SRGB.toLinear(color: Color3)
	return Color3.new(transform(color.R), transform(color.G), (transform(color.B)))
end

return SRGB