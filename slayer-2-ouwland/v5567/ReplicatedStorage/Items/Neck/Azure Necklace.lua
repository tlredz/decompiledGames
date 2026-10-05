local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://133634850782802",
	Description = "Blue stones set into a silver collar piece, polished smooth by long climbs and longer waits at locked doors.",
	Rarity = 4,
	Class = "Sentinel",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 45,
		["Max Stamina"] = 25,
		["Block Points"] = 1,
		["Block Regen"] = 0.1
	}
}