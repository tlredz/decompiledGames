local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://89900508304070",
	Description = "A paper lantern that burns warm orange behind a painted blossom branch, light enough to walk a road after dusk.",
	Rarity = 1,
	EquipType = Menum.ItemEquipType.Accessory,
	Stats = {
		Illumination = 0.2
	},
	ViewmodelSettings = {
		CFrameOffset = CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
	},
	Price = {
		Wen = 2400
	}
}