local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://101604477296435",
	Description = "Blue cloth with a salt stiff edge, the sort kept near docks when the fog comes in hard.",
	Rarity = 3,
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		Wen = 9600
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat"
}