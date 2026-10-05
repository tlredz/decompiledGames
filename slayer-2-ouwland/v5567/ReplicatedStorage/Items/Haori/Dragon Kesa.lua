local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://82208176245327",
	Description = "Coarse brown cloth draped and belted at one shoulder, its dragon mark worn nearly smooth. Iceveil pikemen favor it on the road.",
	Rarity = 1,
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		Wen = 500
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat"
}