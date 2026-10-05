local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://85651011289115",
	Description = "Dawn pale Firstlight silk, woven to order for Corps defenders who intend to still be standing at sunrise.",
	Rarity = 6,
	Series = "Firstlight",
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat",
	Stats = {
		["Max Health"] = 360,
		["Health Regen Speed"] = 0.16,
		["Max Stamina"] = 98
	}
}