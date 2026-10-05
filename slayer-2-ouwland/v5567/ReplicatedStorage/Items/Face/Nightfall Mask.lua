local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://127469797951834",
	Description = "Horned set metal wound over with bandages, taking in campfire light and giving back none of it.",
	Rarity = 6,
	Series = "Nightfall",
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Accessory,
	IsMask = true,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 160,
		["Max Stamina"] = 80,
		["Additional Damage"] = 2,
		["Additional Damage Factor"] = 0.017
	}
}