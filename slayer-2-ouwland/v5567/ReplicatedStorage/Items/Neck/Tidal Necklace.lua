local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://90241012009019",
	Description = "A pale shell strung on knotted twine, passed quietly through markets that open and vanish in a day.",
	Rarity = 1,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 1100
	},
	Stats = {
		["Additional Damage Factor"] = 0.015
	}
}