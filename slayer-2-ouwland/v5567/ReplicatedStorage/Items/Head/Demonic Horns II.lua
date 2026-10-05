local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://104615010950432",
	Description = "A heavier gray pair that curls back like a ram's, thick enough at the base to take a hit without snapping.",
	Rarity = 5,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	Stats = {
		["Max Health"] = 85,
		["Max Stamina"] = 45,
		["Additional Damage"] = 2
	}
}