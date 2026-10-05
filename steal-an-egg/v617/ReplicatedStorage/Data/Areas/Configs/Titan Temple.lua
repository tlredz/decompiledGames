require(script.Parent.Parent.Types)
local v = {
	Color = Color3.fromRGB(90, 255, 210),
	DisplayName = "Titan Temple",
	DropTable = {
		{ "Kaiju Spider", 37.51 },
		{ "Crab", 26.27 },
		{ "Blade Head", 16.83 },
		{ "Mantis", 13.96 },
		{ "Rhino", 4.36 },
		{ "Shark", 0.74 },
		{ "King Kong", 0.31 },
		{ "Godzilla", 0.02 }
	},
	Emoji = "🦖",
	GuardId = "Titan Temple",
	Icon = "rbxassetid://112788249655110",
	IndexBatGearId = "Titan Axe",
	Lighting = nil,
	Rarity = 0,
	_id = "Titan Temple"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage.Data.Rarity).Rarities.Titan
return table.freeze(v)