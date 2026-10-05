local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://72139016011078",
	Description = "Dark cloth that burns out into orange at the fringe, kept by fighters who have stood too near a battlefield blaze.",
	Rarity = 6,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 105,
		["Max Stamina"] = 55,
		["Stamina Regen Speed"] = 0.1,
		["Additional Damage Factor"] = 0.055
	}
}