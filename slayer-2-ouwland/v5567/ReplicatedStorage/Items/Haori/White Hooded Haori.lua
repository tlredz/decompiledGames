local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://116759728319062",
	Description = "A white hooded cloak shading to pale blue along its ragged hem, made to hide a tired face without hiding a drawn blade.",
	Rarity = 4,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 2
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat",
	Stats = {
		["Max Health"] = 130,
		["Max Stamina"] = 40,
		["Movement Speed Factor"] = 0.06
	}
}