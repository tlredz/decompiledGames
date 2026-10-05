local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://119319996232487",
	Description = "Mist patterned yukata faded at the sleeves, as if the cloth spent too many mornings near cold water.",
	Rarity = 3,
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Silk Thread"] = 6
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat"
}