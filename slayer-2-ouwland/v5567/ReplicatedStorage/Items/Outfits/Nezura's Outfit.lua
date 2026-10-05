local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://84678831045338",
	Description = "Nezura's pink kimono under a dark haori, its hemp leaf pattern worn soft. She has not taken it off since the night she changed.",
	Rarity = 5,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Costume,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	ResistCoat = true,
	Stats = {
		["Max Health"] = 240,
		["Health Regen Speed"] = 0.11,
		["Max Stamina"] = 80
	}
}