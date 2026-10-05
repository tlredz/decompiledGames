local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://74936083347203",
	Description = "Two gilt faces on one strap, one serene and one furious, so the wearer can decide which the room gets.",
	Rarity = 5,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	IsMask = true,
	Price = {
		Wen = 20000
	},
	Stats = {
		["Max Health"] = 160,
		["Max Stamina"] = 55,
		["Movement Speed Factor"] = 0.07
	}
}