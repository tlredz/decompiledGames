local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://92092082830355",
	Description = "Pale lavender scattered with night cherry, cut for harbor walks once the lamps along the water are lit.",
	Rarity = 3,
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		Wen = 8700
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat"
}