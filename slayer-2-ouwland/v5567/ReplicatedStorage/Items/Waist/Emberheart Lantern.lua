local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://116834869730016",
	Description = "Its ember holds off Iceveil's freeze while it burns, then must be rekindled beside a campfire.",
	Rarity = 5,
	EquipType = Menum.ItemEquipType.Accessory,
	Unique = true,
	NoSell = true,
	ExclusiveGroup = "ColdLantern",
	Stats = {
		["Max Health"] = 40,
		["Max Stamina"] = 20,
		Illumination = 0.35
	}
}