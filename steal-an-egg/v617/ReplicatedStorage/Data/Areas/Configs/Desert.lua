require(script.Parent.Parent.Types)
local v = {
	Color = Color3.fromRGB(240, 200, 110),
	DisplayName = "Desert",
	DropTable = {
		{ "Jerboa", 26.585432 },
		{ "FennecFox", 20.450332 },
		{ "Camel", 15.337749 },
		{ "Tob Tobi Tob Tob", 12.270199 },
		{ "Rattlesnake", 9.20265 },
		{ "Sand Spider", 8.180133 },
		{ "DeathstalkerScorpion", 6.646358 },
		{ "Irihorus", 1.327147 }
	},
	Emoji = "😮",
	GuardId = "Desert",
	Icon = "rbxassetid://84222502657359",
	IndexBatGearId = "Desert Bat",
	Rarity = 0,
	_id = "Desert"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage.Data.Rarity).Rarities.Rare
return table.freeze(v)