local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://104439531894777",
	Description = "Tengai's festival bright uniform is patched for thunderous movement, with seams that look built for noise.",
	Rarity = 5,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Costume,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	ResistCoat = true,
	Stats = {
		["Max Health"] = 75,
		["Max Stamina"] = 55,
		["Stamina Regen Speed"] = 0.1,
		["Movement Speed Factor"] = 0.09
	}
}