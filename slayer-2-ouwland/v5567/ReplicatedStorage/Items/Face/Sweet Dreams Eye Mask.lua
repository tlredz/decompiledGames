local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://111771166029243",
	Description = "Soft blue fabric scented faintly of sleep herbs, carried by travelers who rest in the gaps between alarms.",
	Rarity = 3,
	EquipType = Menum.ItemEquipType.Accessory,
	IsMask = true,
	Price = {
		["Silk Thread"] = 6
	}
}