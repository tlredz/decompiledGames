local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://97910616756702",
	Description = "A green cross on worn silk, hung plain so the wounded know who to reach for first.",
	Rarity = 1,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 2
	},
	Stats = {
		["Max Health"] = 25,
		["Health Regen Speed"] = 0.03,
		["Max Stamina"] = 10
	}
}