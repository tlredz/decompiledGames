local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://139977471719672",
	Description = "Reaper's coat hangs like a silent bell, cut to move before the sound of the scythe reaches the ear.",
	Rarity = 6,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Costume,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	ResistCoat = true,
	Stats = {
		["Max Health"] = 180,
		["Health Regen Speed"] = 0.1,
		["Max Stamina"] = 90,
		["Additional Damage"] = 1,
		["Additional Damage Factor"] = 0.015
	}
}