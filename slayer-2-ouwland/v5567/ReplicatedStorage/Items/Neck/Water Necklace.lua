local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://71815290374790",
	Description = "A blue drop that never quite falls, threaded for hands that would rather keep their cuts flowing.",
	Rarity = 3,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6
	},
	Stats = {
		["Max Health"] = 15,
		["Max Stamina"] = 10,
		["Additional Damage Factor"] = 0.02
	}
}