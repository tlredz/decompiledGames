local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://75504117550784",
	Description = "A pale butterfly at the throat, the mark Insect students wear before they have earned anything heavier.",
	Rarity = 4,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 40,
		["Max Stamina"] = 20,
		["Additional Damage Factor"] = 0.035
	}
}