local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://114241207237492",
	Description = "Deep red damask piped in pale pink, formal work that never quite settles into being road clothes.",
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