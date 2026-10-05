local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://94699229333277",
	Description = "A silver snake coiling down the cord, polished bright where it rubs the collarbone.",
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