local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://136395902333472",
	Description = "The gilt folk face every Iceveil road crew wears. Seeing two of them on one ridge is the whole warning you get.",
	Rarity = 5,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	IsMask = true,
	Price = {
		Wen = 20000
	},
	Stats = {
		["Max Health"] = 160,
		["Max Stamina"] = 55,
		["Movement Speed Factor"] = 0.07
	}
}