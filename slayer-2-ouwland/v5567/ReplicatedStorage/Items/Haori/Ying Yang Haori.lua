local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://129568537283192",
	Description = "Black and white halves meet in a careful seam, a coat for those who distrust simple answers.",
	Rarity = 3,
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		Wen = 900
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat"
}