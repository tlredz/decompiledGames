game:GetService("Players")
game:GetService("ReplicatedStorage")
local visuals = script.Visuals

local function getCommentValue(p: number, p2: number)
	return p * p2
end

return {
	{
		Name = "Normal",
		Color = Color3.fromRGB(255, 255, 255),
		Transfer = 0,
		Value = 10
	},
	{
		Name = "Super",
		Color = Color3.fromRGB(136, 255, 134),
		Effects = visuals.Super,
		Transfer = 0,
		Value = 28.000000000000004
	},
	{
		Name = "Mega",
		Color = Color3.fromRGB(255, 250, 106),
		Effects = visuals.Mega,
		Transfer = 0,
		Value = 260
	},
	{
		Name = "Unique",
		Color = Color3.fromRGB(176, 124, 255),
		Effects = visuals.Unique,
		Transfer = 0,
		Value = 1500
	},
	{
		Name = "Mythic",
		Color = Color3.fromRGB(103, 255, 237),
		Effects = visuals.Mythic,
		Transfer = 0,
		Value = 6000
	}
}