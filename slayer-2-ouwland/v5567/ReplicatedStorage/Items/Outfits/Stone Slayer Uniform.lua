local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://93728198021149",
	Description = "Gyorei's Corps uniform is broad and solemn, prayer worn cloth for the heaviest work.",
	Rarity = 5,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Costume,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	ResistCoat = true,
	Stats = {
		["Max Health"] = 105,
		["Max Stamina"] = 55,
		["Additional Damage"] = 1,
		["Additional Damage Factor"] = 0.0125
	}
}