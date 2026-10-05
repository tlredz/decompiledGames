require(script.Parent.Parent.Types)
local v = {
	Color = Color3.fromRGB(200, 130, 70),
	DisplayName = "Prehistoric",
	DropTable = {
		{ "Dodo", 39.066058 },
		{ "Pterodactyl", 26.044039 },
		{ "Ankylosaurus", 20.835231 },
		{ "Triceratops", 4.929402 },
		{ "Bronto", 6.995959 },
		{ "TyrannosaurusRex", 0.991743 },
		{ "Tralaledon", 0.826453 },
		{ "Mosasaurus", 0.311113 }
	},
	Emoji = "😨",
	GuardId = "Prehistoric",
	Icon = "rbxassetid://128413001319264",
	IndexBatGearId = "Prehistoric Bat",
	Rarity = 0,
	_id = "Prehistoric"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage.Data.Rarity).Rarities.Secret
return table.freeze(v)