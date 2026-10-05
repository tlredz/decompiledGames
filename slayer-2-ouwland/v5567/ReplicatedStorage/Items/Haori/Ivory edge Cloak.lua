local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://75905130168753",
	Description = "A short ivory cloak clasped at the throat, the kind a night trader keeps folded until the path is empty.",
	Rarity = 3,
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		Wen = 3600
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat"
}