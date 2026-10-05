local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://117008618483212",
	Description = "Pale noble cloth marked with a blossom crest and lined in gold. The house that wears it counts its petals in the thousands and never lets one fall out of place.",
	Rarity = 8,
	EquipType = Menum.ItemEquipType.Clothing,
	AccountWide = true,
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat"
}