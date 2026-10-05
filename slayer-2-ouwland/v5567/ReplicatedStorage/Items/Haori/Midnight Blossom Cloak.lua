local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://128441086598033",
	Description = "Black cloth scattered with night blossoms, the lining cold from Iceveil storehouses and moonlit docks.",
	Rarity = 4,
	Class = "Phantom",
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
		["Max Health"] = 40,
		["Max Stamina"] = 25,
		["Stamina Regen Speed"] = 0.07,
		["Movement Speed Factor"] = 0.06
	}
}