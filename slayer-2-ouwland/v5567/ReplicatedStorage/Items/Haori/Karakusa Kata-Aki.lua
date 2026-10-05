local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://98326209494101",
	Description = "Shoulder cut karakusa cloth, lighter than the cloak and meant to be folded into a travel pack.",
	Rarity = 3,
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		Wen = 7800
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat"
}