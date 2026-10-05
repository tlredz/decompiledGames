local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://135179579646015",
	Description = "Gold repair lines run over battle dark cloth, every crack honored instead of hidden.",
	Rarity = 6,
	Class = "Tank",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat",
	Stats = {
		["Max Health"] = 130,
		["Max Stamina"] = 65,
		["Damage Reduction"] = 1,
		["Damage Reduction Factor"] = 0.05
	}
}