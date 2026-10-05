local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://110825900245097",
	Description = "A horned lamp hung from a gnarled black branch, throwing a hungry orange glow where a carried flame would gutter out.",
	Rarity = 6,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 105,
		["Max Stamina"] = 55,
		["Additional Damage"] = 2,
		["Additional Damage Factor"] = 0.015,
		Illumination = 0.8
	}
}