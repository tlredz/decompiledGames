local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://128669195113403",
	Description = "A narrow red sash tied as a vow, favored by fighters who would rather listen to a room than look at it.",
	Rarity = 2,
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 4
	}
}