local ColorEncoder = require(game.ReplicatedStorage.Util.ColorEncoder)
local AdjustObjectDescendantsColors = require(game.ReplicatedStorage.Util.AdjustObjectDescendantsColors)

local function getColorShiftHSV(color: Color3, color2: Color3)
	local HSV, v, v2 = color:ToHSV()
	local HSV2, v3, v4 = color2:ToHSV()
	return (HSV2 - HSV + 1) % 1, v3 / v, v4 / v2
end

local function applyColorShiftHSV(color: Color3, p: number, p2: number, p3: number)
	local v = math.max(1, color.R, color.G, color.B)
	local v2 = math.floor(color.R / v * 255) % 256
	local v3 = math.floor(color.G / v * 255) % 256
	local v4 = math.floor(color.B / v * 255) % 256
	local HSV, v5, v6 = Color3.fromRGB(v2, v3, v4):ToHSV()
	local v7 = (HSV + p) % 1
	local v8 = math.clamp(v5 * p2, 0, 1)
	local v9 = math.clamp(v6 * p3, 0, 1)
	return Color3.fromHSV(v7, v8, v9 * v)
end

local function getColorHSVDistance(color: Color3, color2: Color3)
	local v = math.max(1, color2.R, color2.G, color2.B)
	local v2 = math.floor(color2.R / v * 255) % 256
	local v3 = math.floor(color2.G / v * 255) % 256
	local v4 = math.floor(color2.B / v * 255) % 256
	local color3 = Color3.fromRGB(v2, v3, v4)
	local HSV, _, _ = color:ToHSV()
	local HSV2, _, _ = color3:ToHSV()
	local v5 = math.abs(HSV2 - HSV)
	return (math.min(v5, 1 - v5))
end

local function ColorShiftObjectDescendantsTable(p, data)
	debug.profilebegin("ColorShiftObjectDescendantsTable")
	local default_Color = assert(data.Default_Color1)
	local v2 = {
		Default_Color1 = default_Color,
		Default_Color2 = data.Default_Color2 or default_Color,
		Default_Color3 = data.Default_Color3 or default_Color
	}
	local shifted_Color1 = data.Shifted_Color1 or default_Color
	local v3 = {
		Shifted_Color1 = shifted_Color1,
		Shifted_Color2 = data.Shifted_Color2 or shifted_Color1,
		Shifted_Color3 = data.Shifted_Color3 or shifted_Color1
	}
	AdjustObjectDescendantsColors(p, function(_, _, p2)
		debug.profilebegin("AdjustObjectDescendantsColors")

		if ColorEncoder.isColorDataEncoded(p2) then
			return p2
		end

		local v4 = 99999999999
		local v5 = nil
		local v6 = nil

		for k, v7 in pairs(v2) do
			local colorHSVDistance = getColorHSVDistance(v7, p2)

			if not (colorHSVDistance < v4) then
				continue
			end

			v5 = k:sub(14, 14)
			v6 = v7
			v4 = colorHSVDistance
		end

		local v7 = v3["Shifted_Color" .. v5]
		local HSV, v8, v9 = v6:ToHSV()
		local HSV2, v10, v11 = v7:ToHSV()
		local v15 = applyColorShiftHSV(p2, (HSV2 - HSV + 1) % 1, v10 / v8, v11 / v9)
		local encodeColorData = ColorEncoder.encodeColorData(v15)
		debug.profileend()
		return encodeColorData
	end, true)
	debug.profileend()
end

return ColorShiftObjectDescendantsTable