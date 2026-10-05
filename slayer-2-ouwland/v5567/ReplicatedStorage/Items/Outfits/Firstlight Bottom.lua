local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Qualities = {
		DisablesShoes = true
	},
	Icon = "rbxassetid://111059913134949",
	Description = "A pleated white wrap edged in gold, part of the Firstlight set and made to hold a stance rather than to hurry anywhere.",
	Rarity = 6,
	Series = "Firstlight",
	SeriesCapstone = true,
	Class = "Tank",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	DisableClothing = {
		Pants = true,
		EquippedPants = true,
		Shoes = true,
		EquippedShoes = true
	},
	ClothingTag = "Pants",
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