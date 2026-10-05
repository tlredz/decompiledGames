local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://139479573758081",
	Description = "Hoyuzo's scarf, travel stained and carefully mended. Enough road marauders wear copies now that it reads as a warning.",
	Rarity = 4,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 30000
	},
	Stats = {
		["Max Health"] = 40,
		["Stamina Regen Speed"] = 0.085,
		["Movement Speed Factor"] = 0.07
	}
}