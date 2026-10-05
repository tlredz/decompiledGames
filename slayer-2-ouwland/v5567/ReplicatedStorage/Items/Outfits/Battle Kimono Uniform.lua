local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://116119312634187",
	Description = "A navy sleeveless tunic buttoned high over a purple wrap and white sash, plain enough to fight in and neat enough to report in.",
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
		["Max Stamina"] = 80,
		["Movement Speed Factor"] = 0.09
	}
}