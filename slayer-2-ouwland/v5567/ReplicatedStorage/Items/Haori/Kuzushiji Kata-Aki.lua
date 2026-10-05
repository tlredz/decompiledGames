local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://107523437921232",
	Description = "Cursive script runs over the shoulder cloth, part prayer and part field note in a scholar's hurried hand.",
	Rarity = 4,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 2
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat",
	Stats = {
		["Max Health"] = 45,
		["Max Stamina"] = 25,
		["Stamina Regen Speed"] = 0.07,
		["Additional Damage Factor"] = 0.035
	}
}