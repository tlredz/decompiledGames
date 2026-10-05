local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://87083850323676",
	Description = "A watchman's lensed patch with the strap rubbed smooth, kept for long vigils where a narrow view is enough.",
	Rarity = 3,
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6
	}
}