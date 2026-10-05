local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://123209032567019",
	Description = "Akazo's red sleeveless vest, marked in blue and cut for a Shockwave demon who settles things with fists well before blades.",
	Rarity = 5,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	DisableClothing = {
		Shirt = true,
		EquippedShirt = true
	},
	ClothingTag = "Shirt",
	Stats = {
		["Max Health"] = 240,
		["Max Stamina"] = 80,
		["Movement Speed Factor"] = 0.09
	}
}