require(script.Parent.Parent.Types)
local v = {
	Color = Color3.fromRGB(60, 150, 255),
	DisplayName = "Lake",
	DropTable = {
		{ "Frog", 29.274167 },
		{ "Duckling", 23.217443 },
		{ "Catfish", 17.160719 },
		{ "Turtle", 12.113448 },
		{ "Trulimero Trulicina", 8.075632 },
		{ "Swan", 5.551997 },
		{ "Dream Axolotl", 4.037816 },
		{ "Basilisk", 0.568777 }
	},
	Emoji = "😐",
	GuardId = "Lake",
	Icon = "rbxassetid://121852407064086",
	IndexBatGearId = "Lake Bat",
	Rarity = 0,
	_id = "Lake"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage.Data.Rarity).Rarities.Uncommon
return table.freeze(v)