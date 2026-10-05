local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://87561683373461",
	Description = "Paired spheres, one dark and one pale, polished the way the tide finishes anything left on the shore.",
	Rarity = 1,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	ViewmodelSettings = {
		CameraOffset = 0.2
	},
	Price = {
		Wen = 4500
	},
	Stats = {
		["Max Health"] = 25,
		["Max Stamina"] = 10,
		["Movement Speed Factor"] = 0.02
	}
}