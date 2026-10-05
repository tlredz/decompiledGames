require(script.Parent.Parent.Types)
local v = {
	Color = Color3.fromRGB(170, 225, 255),
	DisplayName = "Snow",
	DropTable = {
		{ "Penguin", 29.444067 },
		{ "Walrus", 21.570745 },
		{ "Polar Bear", 18.335133 },
		{ "Sabertooth Tiger", 14.020984 },
		{ "Mammoth", 11.86391 },
		{ "Colossal Mammoth", 4.171033 },
		{ "Yeti", 0.371904 },
		{ "Ice Dragon", 0.222224 }
	},
	Emoji = "😟",
	GuardId = "Snow",
	Icon = "rbxassetid://94742267172174",
	IndexBatGearId = "Snow Bat",
	Rarity = 0,
	_id = "Snow"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage.Data.Rarity).Rarities.Legendary
return table.freeze(v)