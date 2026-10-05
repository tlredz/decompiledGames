local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://106829333452090",
	Description = "A sealed winter lantern whose flame never spends itself, keeping Iceveil's freeze from taking hold.",
	Rarity = 6,
	EquipType = Menum.ItemEquipType.Accessory,
	Unique = true,
	NoSell = true,
	NoDelete = true,
	ExclusiveGroup = "ColdLantern",
	Stats = {
		["Max Health"] = 70,
		["Max Stamina"] = 35,
		Illumination = 0.5,
		["Cold Immunity"] = true
	}
}