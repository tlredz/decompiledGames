require(script.Parent.Parent.Types)
local v = {
	Color = Color3.fromRGB(255, 105, 55),
	DisplayName = "Volcano",
	DropTable = {
		{ "Ash Gecko", 26.848869 },
		{ "Lava frog", 22.040116 },
		{ "Flaming Bull", 18.032822 },
		{ "Lava Iguana", 15.027352 },
		{ "Chillin Chilli", 17.030999 },
		{ "Cerberus", 0.61984 },
		{ "Ascended Vermilion Phoenix", 0.222224 },
		{ "Dragon", 0.177779 }
	},
	Emoji = "😰",
	GuardId = "Volcano",
	Icon = "rbxassetid://114058528069937",
	IndexBatGearId = "Volcano Bat",
	Rarity = 0,
	_id = "Volcano"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage.Data.Rarity).Rarities.Mythic
return table.freeze(v)