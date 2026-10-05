local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://111957355628530",
	Description = "A dark red cape from the Lost set, its hem flaring bright as caught firelight whenever the wearer turns.",
	Rarity = 6,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 85,
		["Max Stamina"] = 65,
		["Stamina Regen Speed"] = 0.09,
		["Additional Damage Factor"] = 0.03
	}
}