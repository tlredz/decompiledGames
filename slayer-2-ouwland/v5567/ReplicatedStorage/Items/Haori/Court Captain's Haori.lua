local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://105275308230531",
	Description = "White and full sleeved, with a crest set in a diamond at the back. Only thirteen were ever cut to this pattern, one for each company's captain.",
	Rarity = 8,
	EquipType = Menum.ItemEquipType.Clothing,
	AccountWide = true,
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat"
}