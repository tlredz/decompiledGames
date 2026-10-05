local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://70575102715062",
	Description = "Black cloth marked with gold strokes and hung with tassels, drawn up when a night fight turns toward flame.",
	Rarity = 4,
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 2
	}
}