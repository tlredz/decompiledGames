local ColorEncoder = require(game.ReplicatedStorage.Util.ColorEncoder)
local WrapColor3Constructor = require(game.ReplicatedStorage.Util.WrapColor3Constructor)

local function transformOnlyHue(color: Color3, color2: Color3)
	local v = math.max(1, color.R, color.G, color.B)
	local v2 = math.floor(color.R / v * 255) % 256
	local v3 = math.floor(color.G / v * 255) % 256
	local v4 = math.floor(color.B / v * 255) % 256
	local color3 = Color3.fromRGB(v2, v3, v4)
	local v5 = math.max(1, color2.R, color2.G, color2.B)
	local v6 = math.floor(color2.R / v5 * 255) % 256
	local v7 = math.floor(color2.G / v5 * 255) % 256
	local v8 = math.floor(color2.B / v5 * 255) % 256
	local color4 = Color3.fromRGB(v6, v7, v8)
	local _, v9, v10 = color3:ToHSV()
	local v11 = v10 * v
	local HSV = color4:ToHSV()
	return Color3.fromHSV(HSV, v9, v11)
end

local function WrapColor3ConstructorForTintColor(color: Color3, p, p2: string)
	local wrapColor3Constructor = WrapColor3Constructor(color, p, p2)
	return ColorEncoder.encodeColorData(transformOnlyHue(color, wrapColor3Constructor))
end

return WrapColor3ConstructorForTintColor