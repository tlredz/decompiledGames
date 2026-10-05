local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://137445540854266",
	Description = "Square red stones set flush in dark metal, favored by fighters who prefer their blood already named.",
	Rarity = 3,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 4500
	},
	Stats = {
		["Max Health"] = 15,
		["Max Stamina"] = 10,
		["Additional Damage Factor"] = 0.02
	}
}