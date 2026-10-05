local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://122054988202205",
	Description = "The Reaper's own blue flame, cold at the edge, traded among climbers who favor quick endings.",
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