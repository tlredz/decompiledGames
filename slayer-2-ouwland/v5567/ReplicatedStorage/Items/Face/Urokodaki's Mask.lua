local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://120866652452144",
	Description = "The tengu face Urokodaki carves by hand, one for every child he sends up that mountain hoping to see them come back.",
	Rarity = 3,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	IsMask = true,
	Price = {
		Product = 3609184225
	},
	ViewmodelSettings = {
		CameraOffset = -0.45,
		CFrameOffset = CFrame.Angles(0, 2.356194490192345, 0)
	},
	Stats = {
		["Max Health"] = 60,
		["Max Stamina"] = 20,
		["Movement Speed Factor"] = 0.03
	}
}