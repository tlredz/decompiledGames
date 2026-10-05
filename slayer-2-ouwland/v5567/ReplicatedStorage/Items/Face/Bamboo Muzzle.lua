local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://119821932700197",
	Description = "The bamboo Nezura bites down on. It is not a gag so much as a promise she keeps every day she does not break it.",
	Rarity = 6,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 160,
		["Max Stamina"] = 80,
		["Additional Damage"] = 2,
		["Additional Damage Factor"] = 0.015
	}
}