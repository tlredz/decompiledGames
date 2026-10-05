local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://134089215496967",
	Description = "Datai's hairpins, gold sticks spread with small pink fans, still set the way she wore them.",
	Rarity = 5,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	Stats = {
		["Max Health"] = 240,
		["Health Regen Speed"] = 0.11,
		["Max Stamina"] = 80
	}
}