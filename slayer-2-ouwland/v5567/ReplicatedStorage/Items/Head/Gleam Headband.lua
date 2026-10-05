local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://79306449353822",
	Description = "Tengai's banded headpiece, set with cut stones and hung with a bead chain, worn low so nothing shifts mid rhythm.",
	Rarity = 4,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 130,
		["Max Stamina"] = 40,
		["Movement Speed Factor"] = 0.06
	}
}