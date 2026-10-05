local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://73551754503865",
	Description = "Cream cloth crossed at the chest under a gilded sun pauldron. No shop stocks the Firstlight set, it is forged and then forged further.",
	Rarity = 6,
	Series = "Firstlight",
	SeriesCapstone = true,
	Class = "Tank",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	DisableClothing = {
		Shirt = true,
		EquippedShirt = true
	},
	ClothingTag = "Shirt",
	Refinable = true,
	RefineStats = { "Max Health" },
	Stats = {
		["Max Health"] = 180,
		["Max Health Factor"] = 0.03,
		["Health Regen Speed"] = 0.115,
		["Max Stamina"] = 100,
		["Damage Reduction Factor"] = 0.05
	}
}