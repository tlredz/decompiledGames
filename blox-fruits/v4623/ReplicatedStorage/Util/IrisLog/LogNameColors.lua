local palette = {
	{
		Key = "White",
		Color = Color3.fromRGB(232, 236, 244)
	},
	{
		Key = "Silver",
		Color = Color3.fromRGB(184, 192, 205)
	},
	{
		Key = "Red",
		Color = Color3.fromRGB(248, 113, 113)
	},
	{
		Key = "Coral",
		Color = Color3.fromRGB(251, 146, 60)
	},
	{
		Key = "Gold",
		Color = Color3.fromRGB(250, 204, 21)
	},
	{
		Key = "Lime",
		Color = Color3.fromRGB(163, 230, 53)
	},
	{
		Key = "Green",
		Color = Color3.fromRGB(74, 222, 128)
	},
	{
		Key = "Mint",
		Color = Color3.fromRGB(94, 234, 212)
	},
	{
		Key = "Cyan",
		Color = Color3.fromRGB(86, 196, 240)
	},
	{
		Key = "Sky",
		Color = Color3.fromRGB(125, 211, 252)
	},
	{
		Key = "Blue",
		Color = Color3.fromRGB(147, 197, 253)
	},
	{
		Key = "Indigo",
		Color = Color3.fromRGB(165, 180, 252)
	},
	{
		Key = "Purple",
		Color = Color3.fromRGB(196, 181, 253)
	},
	{
		Key = "Pink",
		Color = Color3.fromRGB(249, 168, 212)
	},
	{
		Key = "Rose",
		Color = Color3.fromRGB(251, 113, 133)
	},
	{
		Key = "Amber",
		Color = Color3.fromRGB(251, 191, 36)
	}
}
local colors = {}
local v2 = {}
local LogNameColors = {}

for _, v3 in palette do
	colors[v3.Key] = v3.Color
	v2[v3.Key] = true
end

function LogNameColors.isValidKey(value)
	return typeof(value) == "string" and v2[value] == true
end

function LogNameColors.colorForKey(value)
	if typeof(value) == "string" then
		return colors[value]
	end

	return nil
end

function LogNameColors.richTextColor(color: Color3)
	return (`rgb({math.floor(color.R * 255 + 0.5)},{math.floor(color.G * 255 + 0.5)},{math.floor(color.B * 255 + 0.5)})`)
end

LogNameColors.Palette = palette
LogNameColors.ColorsByKey = colors
return LogNameColors