local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://122926928622240",
	Description = "Black wings folded around a magenta stone, the badge the Tai Chi students wear and never leave out in daylight.",
	Rarity = 4,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 15000
	},
	Stats = {
		["Max Health"] = 105,
		["Health Regen Speed"] = 0.08,
		["Max Stamina"] = 35
	}
}