local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://106313151314036",
	Description = "Plain gold bars that hang like ornament and read like ornament, right up until the lamp catches the seam.",
	Rarity = 3,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 4500
	},
	Stats = {
		["Max Health"] = 15,
		["Stamina Regen Speed"] = 0.05,
		["Movement Speed Factor"] = 0.04
	}
}