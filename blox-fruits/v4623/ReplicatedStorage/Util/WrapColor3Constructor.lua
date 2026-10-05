local ColorEncoder = require(game.ReplicatedStorage.Util.ColorEncoder)
local ColorSequenceUtil = require(game.ReplicatedStorage.Util.ColorSequenceUtil)
local GrayscaleToColor = require(game.ReplicatedStorage.Util.GrayscaleToColor)

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

local function WrapColor3Constructor(color: Color3, instance, childName: string)
	debug.profilebegin("WrapColor3Constructor")

	if instance == nil or instance.Parent == nil then
		debug.profileend()
		warn("WrapColor3Constructor: WARNING, MISSING PLAYER" .. [[

 
]] .. "Traceback:\n" .. debug.traceback())
		return color
	else
		local child = instance:FindFirstChild(childName)

		if child == nil then
			debug.profileend()
			return color
		end

		local v = 99999999999
		local v2 = nil
		local v3 = nil

		for k, v4 in pairs(child.Default:GetAttributes()) do
			if not k:match("Default_Color") then
				continue
			end

			local colorHSVDistance = getColorHSVDistance(v4, color)

			if not (colorHSVDistance < v) then
				continue
			end

			v3 = k:sub(14, 14)
			v2 = v4
			v = colorHSVDistance
		end

		if v2 == nil or v3 == nil then
			debug.profileend()
			return color
		end

		local attribute = child.Shifted:GetAttribute("Shifted_Color" .. v3)

		if typeof(attribute) == "ColorSequence" then
			local attribute2 = child.Shifted:GetAttribute("Shifted_Color" .. v3 .. "_StaticTime")
			attribute = ColorSequenceUtil.eval(
				attribute,
				typeof(attribute2) ~= "number" and 0.5 or math.clamp(attribute2, 0, 1)
			)
		end

		if attribute == nil then
			debug.profileend()
			return color
		end

		local HSV, v4, v5 = v2:ToHSV()
		local HSV2, v6, v7 = attribute:ToHSV()
		local color2 = applyColorShiftHSV(color, (HSV2 - HSV + 1) % 1, v6 / v4, v7 / v5)
		local grayscaleToColorStrength = child.Shifted:GetAttribute("GrayscaleToColorStrength")
		local grayscaleToColorSequence = child.Shifted:GetAttribute("GrayscaleToColorSequence")

		if grayscaleToColorStrength and typeof(grayscaleToColorSequence) == "ColorSequence" then
			color2 = GrayscaleToColor(color2, grayscaleToColorSequence, grayscaleToColorStrength)
		end

		local encodeColorData = ColorEncoder.encodeColorData(color2)
		debug.profileend()
		return encodeColorData
	end
end

return WrapColor3Constructor