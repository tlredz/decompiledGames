local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://126365436041782",
	Description = "Vine scrollwork curls in gold across deep violet, its travel wear hidden in the looping pattern.",
	Rarity = 4,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		Wen = 16800
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat",
	Stats = {
		["Max Health"] = 40,
		["Max Stamina"] = 25,
		["Stamina Regen Speed"] = 0.07,
		["Movement Speed Factor"] = 0.06
	}
}