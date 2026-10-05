local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://117130902329461",
	Description = "White cloth for a shrine helper who forgot to leave, quiet at the sleeves and colder than it should be.",
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