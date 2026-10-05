local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://72162221168694",
	Description = "Small black wings holding a drop of magenta crystal, the sort of night work nobody leaves out on display.",
	Rarity = 4,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 7000
	},
	Stats = {
		["Max Health"] = 105,
		["Health Regen Speed"] = 0.08,
		["Max Stamina"] = 35
	}
}