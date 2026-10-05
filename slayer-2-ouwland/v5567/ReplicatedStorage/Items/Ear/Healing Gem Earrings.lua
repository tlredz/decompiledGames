local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://86702644464201",
	Description = "Green stones cut into a plain cross, the mark a field healer hangs where the wounded can find it.",
	Rarity = 1,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 1500
	},
	Stats = {
		["Max Health"] = 25,
		["Health Regen Speed"] = 0.03,
		["Max Stamina"] = 10
	}
}