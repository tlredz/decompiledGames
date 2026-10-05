local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://85864392200843",
	Description = "Obari's haori, banded black and white down its whole length, kept close to a body that never moves in a straight line.",
	Rarity = 6,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat",
	Stats = {
		["Max Health"] = 150,
		["Max Stamina"] = 80,
		["Stamina Regen Speed"] = 0.1,
		["Additional Damage Factor"] = 0.07
	}
}