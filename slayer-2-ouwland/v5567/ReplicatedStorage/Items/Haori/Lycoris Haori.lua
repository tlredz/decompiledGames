local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://79388833909164",
	Description = "Grave flower red blooms across this haori, funeral bright and favored by fighters who expect the worst.",
	Rarity = 5,
	Class = "Tank",
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
		["Max Health"] = 85,
		["Max Stamina"] = 40,
		["Damage Reduction Factor"] = 0.035
	}
}