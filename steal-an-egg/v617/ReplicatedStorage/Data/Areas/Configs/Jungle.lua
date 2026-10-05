require(script.Parent.Parent.Types)
local v = {
	Color = Color3.fromRGB(150, 220, 60),
	DisplayName = "Jungle",
	DropTable = {
		{ "Chimpanzee", 26.006779 },
		{ "Toucan", 20.005214 },
		{ "Crocodile", 17.004432 },
		{ "Gorilla", 13.003389 },
		{ "Orangutini Ananassini", 11.002868 },
		{ "Spider", 7.852047 },
		{ "Tiger", 5.001304 },
		{ "Warden", 0.123968 }
	},
	Emoji = "😬",
	GuardId = "Jungle",
	Icon = "rbxassetid://114796463507768",
	IndexBatGearId = "Jungle Bat",
	Rarity = 0,
	_id = "Jungle"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage.Data.Rarity).Rarities.Epic
return table.freeze(v)