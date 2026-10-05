local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://106818829898556",
	Description = "Nightfall cloth crossed at the chest in quiet layers. Not looted and not bought, only built and then built further.",
	Rarity = 6,
	Series = "Nightfall",
	SeriesCapstone = true,
	Class = "Duelist",
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
		["Max Health"] = 135,
		["Max Stamina"] = 95,
		["Additional Damage"] = 2,
		["Additional Damage Factor"] = 0.03
	}
}