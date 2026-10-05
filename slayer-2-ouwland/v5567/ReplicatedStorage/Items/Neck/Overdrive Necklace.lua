local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://130323544498861",
	Description = "A violet star on a short cord, made for fighters who burn through their own calm far too quickly.",
	Rarity = 3,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 4500
	},
	Stats = {
		["Max Health"] = 15,
		["Max Stamina"] = 10,
		["Additional Damage Factor"] = 0.02
	}
}