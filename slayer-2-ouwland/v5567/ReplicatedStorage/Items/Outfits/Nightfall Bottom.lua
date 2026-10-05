local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Qualities = {
		DisablesShoes = true
	},
	Icon = "rbxassetid://132291905214632",
	Description = "Dark trousers trimmed in pale fur and gold, woven from Nightfall cloth and plating rather than bought from anybody.",
	Rarity = 6,
	Series = "Nightfall",
	SeriesCapstone = true,
	Class = "Duelist",
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
		["Max Health"] = 135,
		["Max Stamina"] = 95,
		["Additional Damage"] = 2,
		["Additional Damage Factor"] = 0.03
	}
}