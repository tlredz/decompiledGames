local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://113708168185554",
	Description = "Knotted cord and two dull rings, the quiet charm a cautious trader keeps under the collar.",
	Rarity = 1,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 4500
	},
	Stats = {
		["Max Health"] = 25,
		["Max Stamina"] = 10,
		["Movement Speed Factor"] = 0.02
	}
}