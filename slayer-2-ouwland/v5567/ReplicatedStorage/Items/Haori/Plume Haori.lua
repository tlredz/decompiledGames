local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://107287778926558",
	Description = "Plume marks sweep across the back, cut for runners who want the cloth to vanish behind them.",
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