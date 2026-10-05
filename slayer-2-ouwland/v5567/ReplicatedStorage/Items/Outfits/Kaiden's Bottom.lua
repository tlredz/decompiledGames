local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Qualities = {
		DisablesShoes = false
	},
	Icon = "rbxassetid://79751981106074",
	Description = "Kaiden's trousers are cut above the ankle for bamboo mud, scuffed by quick turns and clawed footwork.",
	Rarity = 4,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 2
	},
	DisableClothing = {
		Pants = true,
		EquippedPants = true,
		Shoes = true,
		EquippedShoes = true
	},
	ClothingTag = "Pants",
	Stats = {
		["Max Health"] = 55,
		["Max Stamina"] = 30,
		["Additional Damage"] = 1
	}
}