local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://99162474415598",
	Description = "Gradient dyed shoulder cloth from the tower's harder floors, made for hands that never waste motion.",
	Rarity = 5,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat",
	Stats = {
		["Max Health"] = 105,
		["Max Stamina"] = 50,
		["Stamina Regen Speed"] = 0.09,
		["Additional Damage Factor"] = 0.04
	}
}