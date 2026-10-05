local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://79124533601031",
	Description = "Blue stones seated in pale silver mounts, bright enough to catch what little moonlight gets under a hood.",
	Rarity = 4,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 6800
	},
	Stats = {
		["Max Health"] = 105,
		["Max Stamina"] = 35,
		["Movement Speed Factor"] = 0.05
	}
}