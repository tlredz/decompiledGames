local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://106899720140800",
	Description = "Dream silk folds from Enru's coat, brushed smooth like a lullaby before the teeth show.",
	Rarity = 5,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	DisableClothing = {
		Shirt = true,
		EquippedShirt = true
	},
	ClothingTag = "Shirt",
	Stats = {
		["Max Health"] = 105,
		["Max Stamina"] = 90,
		["Stamina Regen Speed"] = 0.09,
		["Additional Damage Factor"] = 0.04
	}
}