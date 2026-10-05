local color = Color3.new(1, 1, 1)
local color2 = Color3.new(0, 0, 0)

local function getContrastColor(data)
	local v = data.R * 255
	local v2 = data.G * 255
	local v3 = data.B * 255

	if v * 0.299 + v2 * 0.587 + v3 * 0.114 > 186 then
		return color2
	end

	return color
end

return {
	White = color,
	Black = color2,
	LightGray = Color3.fromRGB(224, 224, 224),
	MediumGray = Color3.fromRGB(113, 117, 121),
	DarkGray = Color3.fromRGB(95, 99, 104),
	DefaultTheme = Color3.fromRGB(103, 58, 183),
	GetContrastColor = getContrastColor
}