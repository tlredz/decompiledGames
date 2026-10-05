local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://101229077117493",
	Description = "Red lacquer, gold horns, bared teeth. It asks for forward pressure and ugly trades at arm's length.",
	Rarity = 5,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Accessory,
	IsMask = true,
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