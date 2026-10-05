local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://77727343637223",
	Description = "Stone prayer beads modeled after Gyorei's own burden, heavy enough to make silence feel earned.",
	Rarity = 5,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	Stats = {
		["Max Health"] = 60,
		["Max Stamina"] = 30,
		["Additional Damage Factor"] = 0.05
	}
}