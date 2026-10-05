local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://128679669227577",
	Description = "A straw amigasa finished in scalloped white trim with tassels left hanging, close woven enough to turn daylight aside.",
	Rarity = 6,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 85,
		["Max Stamina"] = 45,
		["Stamina Regen Speed"] = 0.1,
		["Additional Damage Factor"] = 0.055,
		["Sun Immunity"] = true
	}
}