local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://139486829968966",
	Description = "A shock of pink feathers worn with far more flourish than sense. Nobody stands behind one of these unnoticed.",
	Rarity = 3,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Product = 3708919218
	},
	Stats = {
		["Max Health"] = 15,
		["Stamina Regen Speed"] = 0.05,
		["Movement Speed Factor"] = 0.04
	}
}