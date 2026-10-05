local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Qualities = {
		DisablesShoes = true
	},
	Icon = "rbxassetid://94418128521034",
	Description = "Enru's trousers are soft enough for sleep and cut loose enough to run when the dream breaks.",
	Rarity = 5,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	DisableClothing = {
		Pants = true,
		EquippedPants = true,
		Shoes = true,
		EquippedShoes = true
	},
	ClothingTag = "Pants",
	Stats = {
		["Max Health"] = 105,
		["Max Stamina"] = 90,
		["Stamina Regen Speed"] = 0.09,
		["Additional Damage Factor"] = 0.04
	}
}