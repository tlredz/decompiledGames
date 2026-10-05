local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://73624583928445",
	Description = "Great gold horns off a lacquered brow, silted where the Lost one went down. Sighted through, wooden walls give up every seam and knot a carpenter hoped would hold.",
	Rarity = 6,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Accessory,
	IsMask = true,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 90,
		["Max Stamina"] = 50,
		["Stamina Regen Speed"] = 0.04,
		["Additional Damage Factor"] = 0.04
	}
}