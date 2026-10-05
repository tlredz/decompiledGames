local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://139229172107422",
	Description = "The Flame school's other cut, its fire worked short and tight at the hem, made for precise hands rather than the loudest in the room.",
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