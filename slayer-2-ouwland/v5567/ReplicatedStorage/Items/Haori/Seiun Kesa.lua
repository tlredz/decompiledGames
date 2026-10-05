local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://71692292889765",
	Description = "Blue cloud cloth draped against the cold, with a pale lining that catches lanternlight.",
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