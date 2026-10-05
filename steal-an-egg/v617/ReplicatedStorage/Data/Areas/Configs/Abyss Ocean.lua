require(script.Parent.Parent.Types)
local v = {
	Color = Color3.fromRGB(40, 185, 245),
	DisplayName = "Abyss Ocean",
	DropTable = {
		{ "Parrotfish", 34.755713 },
		{ "Swordfish", 24.665345 },
		{ "Finned Thresher", 19.059585 },
		{ "Orca", 14.574977 },
		{ "Whale Shark", 3.412663 },
		{ "Alabaster Whale", 2.616375 },
		{ "Kraken", 0.826453 },
		{ "El Maja", 0.08889 }
	},
	Emoji = "😱",
	GuardId = "Abyss Ocean",
	Icon = "rbxassetid://114973940272302",
	IndexBatGearId = "Abyss Ocean Bat",
	Rarity = 0,
	_id = "Abyss Ocean"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage.Data.Rarity).Rarities.Cosmic
return table.freeze(v)