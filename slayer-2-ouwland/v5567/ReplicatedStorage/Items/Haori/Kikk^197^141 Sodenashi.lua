local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://105753504446133",
	Description = "Kikko style hex panels cover this sleeveless coat, a guard's pattern softened by long use.",
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