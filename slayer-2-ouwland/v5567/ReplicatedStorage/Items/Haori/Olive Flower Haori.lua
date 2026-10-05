local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://122369170430177",
	Description = "Olive cloth scattered with small blossoms, plain enough for market days and sturdy enough for patrol.",
	Rarity = 1,
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		Wen = 3900
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat"
}