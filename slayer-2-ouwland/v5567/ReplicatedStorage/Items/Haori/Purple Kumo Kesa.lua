local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://73781519050149",
	Description = "Purple cloud patterns gather over this kesa, soft at the collar from years of careful folding.",
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