local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://105527607314810",
	Description = "A pale rose boa, absurdly soft and far too clean for any of the roads it is supposed to have crossed.",
	Rarity = 6,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 65000
	},
	Stats = {
		["Max Health"] = 75,
		["Max Stamina"] = 55,
		["Stamina Regen Speed"] = 0.12,
		["Movement Speed Factor"] = 0.11
	}
}