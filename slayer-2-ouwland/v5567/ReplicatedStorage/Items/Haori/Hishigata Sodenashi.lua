local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://83181060373301",
	Description = "Old hishi diamonds banded across a sleeveless green coat, cut for guards who would rather take a blow on the forearm than give ground.",
	Rarity = 4,
	Class = "Sentinel",
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
		["Max Health"] = 45,
		["Max Stamina"] = 25,
		["Block Points"] = 2,
		["Block Regen"] = 0.1
	}
}