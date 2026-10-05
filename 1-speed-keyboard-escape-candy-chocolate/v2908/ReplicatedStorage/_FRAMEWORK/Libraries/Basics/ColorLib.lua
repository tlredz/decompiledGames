local ColorLib = {
	red = Color3.fromRGB(255, 0, 0),
	green = Color3.fromRGB(0, 255, 0),
	blue = Color3.fromRGB(0, 0, 255),
	yellow = Color3.fromRGB(255, 255, 0),
	cyan = Color3.fromRGB(0, 255, 255),
	magenta = Color3.fromRGB(255, 0, 255),
	white = Color3.fromRGB(255, 255, 255),
	black = Color3.fromRGB(0, 0, 0)
}

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function wrapHue(p: number)
	return (p % 1 + 1) % 1
end

function ColorLib.adjustHsv(color: Color3, value: number?, value2: number?, value3: number?)
	local HSV, v, v2 = color:ToHSV()
	return Color3.fromHSV(
		wrapHue(HSV + (value or 0)),
		math.clamp(v + (value2 or 0), 0, 1),
		(math.clamp(v2 + (value3 or 0), 0, 1))
	)
end

function ColorLib.adjustHsvDegrees(color: Color3, value: number?, p: number?, p2: number?)
	return ColorLib.adjustHsv(color, (value or 0) / 360, p, p2)
end

function ColorLib.setHsv(color: Color3, p: number?, value: number?, value2: number?)
	local HSV, v, v2 = color:ToHSV()

	if p ~= nil then
		HSV = p
	end

	local hue = wrapHue(HSV)

	if value == nil then
		value = v
	end

	local v4 = math.clamp(value, 0, 1)

	if value2 == nil then
		value2 = v2
	end

	return Color3.fromHSV(hue, v4, (math.clamp(value2, 0, 1)))
end

function ColorLib.lighten(color: Color3, p: number)
	return ColorLib.adjustHsv(color, 0, 0, (math.abs(p)))
end

function ColorLib.darken(color: Color3, p: number)
	return ColorLib.adjustHsv(color, 0, 0, -math.abs(p))
end

function ColorLib.saturate(color: Color3, p: number)
	return ColorLib.adjustHsv(color, 0, math.abs(p), 0)
end

function ColorLib.desaturate(color: Color3, p: number)
	return ColorLib.adjustHsv(color, 0, -math.abs(p), 0)
end

function ColorLib.adjust(color: Color3, value: number?, value2: number?, value3: number?)
	local HSV, v, v2 = color:ToHSV()
	local color2 = Color3.fromHSV(HSV, math.clamp(v * (value2 or 1), 0, 1), (math.clamp(v2 * (value or 1), 0, 1)))
	local v3 = value3 or 1
	return Color3.new(
		math.clamp((color2.R - 0.5) * v3 + 0.5, 0, 1),
		math.clamp((color2.G - 0.5) * v3 + 0.5, 0, 1),
		(math.clamp((color2.B - 0.5) * v3 + 0.5, 0, 1))
	)
end

return ColorLib