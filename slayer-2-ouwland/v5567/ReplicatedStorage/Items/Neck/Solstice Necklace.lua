local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://119865124664659",
	Description = "Gold worked into a small sun, kept for the longest nights, warm at the edge and dark at the core.",
	Rarity = 3,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 13500
	},
	Stats = {
		["Max Health"] = 60,
		["Max Stamina"] = 20,
		["Movement Speed Factor"] = 0.03
	}
}