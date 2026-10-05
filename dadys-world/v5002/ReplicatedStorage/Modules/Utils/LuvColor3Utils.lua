local LuvUtils = require(script.Parent.LuvUtils)
local LuvColor3Utils = {}

local function lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

function LuvColor3Utils.lerp(color: Color3, color2: Color3, value: number)
	assert(typeof(color) == "Color3", "Bad color0")
	assert(typeof(color2) == "Color3", "Bad color1")
	assert(type(value) == "number", "Bad t")

	if value == 0 then
		return color
	elseif value == 1 then
		return color2
	end

	local v, v2, v3 = unpack(LuvColor3Utils.fromColor3(color))
	local v4, v5, v6 = unpack(LuvColor3Utils.fromColor3(color2))
	local v7 = { v + (((v4 - v) % 360 + 540) % 360 - 180) * value, v2 + (v5 - v2) * value, v3 + (v6 - v3) * value }
	return LuvColor3Utils.toColor3(v7)
end

function LuvColor3Utils.desaturate(color: Color3, p: number)
	local v, v2, v3 = unpack(LuvColor3Utils.fromColor3(color))
	return LuvColor3Utils.toColor3({ v, v2 * math.clamp(1 - p, 0, 1), v3 })
end

function LuvColor3Utils.darken(color: Color3, p: number)
	local v, v2, v3 = unpack(LuvColor3Utils.fromColor3(color))
	return LuvColor3Utils.toColor3({ v, v2, v3 * math.clamp(1 - p, 0, 1) })
end

function LuvColor3Utils.lighten(color: Color3, value: number)
	local v, v2, v3 = unpack(LuvColor3Utils.fromColor3(color))
	local v4 = { v, v2, v3 + (100 - v3) * math.clamp(value, 0, 1) }
	return LuvColor3Utils.toColor3(v4)
end

function LuvColor3Utils.fromColor3(color: Color3)
	assert(typeof(color) == "Color3", "Bad color3")
	return LuvUtils.rgb_to_hsluv({ color.R, color.G, color.B })
end

function LuvColor3Utils.toColor3(p)
	assert(type(p) == "table", "Bad hsluv")
	local v, v2, v3 = unpack(LuvUtils.hsluv_to_rgb(p))
	return Color3.new(math.clamp(v, 0, 1), math.clamp(v2, 0, 1), (math.clamp(v3, 0, 1)))
end

return LuvColor3Utils