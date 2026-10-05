local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://123058181752340",
	Description = "A pink fox face dusted with flowers, its petal paint worn thin at the cheeks from being worn far past the festival.",
	Rarity = 4,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	IsMask = true,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 105,
		["Health Regen Speed"] = 0.08
	}
}