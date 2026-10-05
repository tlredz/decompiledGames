local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://83853782985871",
	Description = "Deep blue shoulder cloth scattered with pale moons, its weave keeping the hush of frozen shrines.",
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