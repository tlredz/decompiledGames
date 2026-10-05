local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://75422525134938",
	Description = "A twist of obi silk knotted at the throat, the same binding Datai's art pulls tight around anyone slower.",
	Rarity = 1,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 2
	},
	Stats = {
		["Additional Damage Factor"] = 0.015
	}
}