local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://97734903841174",
	Description = "A loose charcoal haori with a single row of white diamonds. It once belonged to a captain turned inventor, exiled over one invention, who never stopped tinkering.",
	Rarity = 8,
	EquipType = Menum.ItemEquipType.Clothing,
	AccountWide = true,
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat"
}