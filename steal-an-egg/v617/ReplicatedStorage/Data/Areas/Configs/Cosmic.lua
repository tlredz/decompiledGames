require(script.Parent.Parent.Types)
local v = {
	Color = Color3.fromRGB(195, 140, 255),
	DisplayName = "Cosmic",
	DropTable = {
		{ "Centapede", 39.869773 },
		{ "Galaxy Gecko", 34.387407 },
		{ "Cyclops Gorilla", 19.618806 },
		{ "La Vacca Saturno Saturnita", 4.550072 },
		{ "Alien Skeleton Boss", 0.495856 },
		{ "Cave Dragon", 0.743784 },
		{ "Eternal Lunar Dragon", 0.311104 },
		{ "Unicorn", 0.0231993 }
	},
	Emoji = "👹",
	GuardId = "Cosmic",
	Icon = "rbxassetid://130113964572741",
	IndexBatGearId = "Cosmic Bat",
	Rarity = 0,
	_id = "Cosmic"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage.Data.Rarity).Rarities.Eternal
return table.freeze(v)