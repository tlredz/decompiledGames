local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://122392038656812",
	Description = "Cloth from the Lost set, faded like it spent too long in Final Selection fog and came back without its owner.",
	Rarity = 6,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Costume,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	ResistCoat = true,
	Stats = {
		["Max Health"] = 145,
		["Health Regen Speed"] = 0.08,
		["Max Stamina"] = 70,
		["Stamina Regen Speed"] = 0.05,
		["Additional Damage Factor"] = 0.065
	}
}