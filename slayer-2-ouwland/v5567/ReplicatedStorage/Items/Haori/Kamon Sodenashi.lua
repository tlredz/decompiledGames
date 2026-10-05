local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://139005920876202",
	Description = "Sleeveless cloth marked with family crests, careful work for someone who still remembers where they came from.",
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