local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://91811116317452",
	Description = "Pale smoke curls across black cloth, with a dark fur ruff at one shoulder and a white sash belted over it. Iceveil pikemen wear it on the high roads.",
	Rarity = 5,
	Class = "Tank",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat",
	Stats = {
		["Max Health"] = 105,
		["Max Stamina"] = 50,
		["Damage Reduction Factor"] = 0.035
	}
}