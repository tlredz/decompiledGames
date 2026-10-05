require(script.Parent.Parent.Types)
local v = {
	Color = Color3.fromRGB(110, 205, 105),
	DisplayName = "Forest",
	DropTable = {
		{ "Chicken", 34 },
		{ "Dog", 24 },
		{ "DesertLark", 17 },
		{ "Burrowing Owl", 10 },
		{ "Raccoon", 7 },
		{ "Mire Fox", 4.5 },
		{ "Bear", 2.5 },
		{ "Brr Brr Patapim", 1 }
	},
	Emoji = "🙂",
	GuardId = "Forest",
	Icon = "rbxassetid://110449023764288",
	IndexBatGearId = "Forest Bat",
	Rarity = 0,
	_id = "Forest"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage.Data.Rarity).Rarities.Common
return table.freeze(v)