local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://126732058787934",
	Description = "Fujiko's navy robe scattered with gold clouds over black trousers, kept with the same care as the parasol that goes with it.",
	Rarity = 6,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Costume,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	ResistCoat = true,
	Stats = {
		["Max Health"] = 115,
		["Health Regen Speed"] = 0.1,
		["Max Stamina"] = 90,
		["Movement Speed Factor"] = 0.1,
		["Stamina Regen Speed"] = 0.12
	}
}