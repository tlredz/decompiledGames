require(script.Parent.Parent.Types)
local v = {
	Color = Color3.fromRGB(255, 138, 190),
	DisplayName = "Cherry Blossom",
	DropTable = {
		{ "Crane", 37.51 },
		{ "Salamander", 26.27 },
		{ "Red Panda", 16.83 },
		{ "Snowy Owl", 13.96 },
		{ "Koi", 4.36 },
		{ "Stag", 0.74 },
		{ "Oni Tiger", 0.31 },
		{ "Kitsune", 0.02 }
	},
	Emoji = "🌸",
	GuardId = "Cherry Blossom",
	Icon = "rbxassetid://128921736835133",
	IndexBatGearId = "Katana",
	Lighting = "CherryBlossom",
	Rarity = 0,
	_id = "Cherry Blossom"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage.Data.Rarity).Rarities.Divine
return table.freeze(v)