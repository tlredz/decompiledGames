local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://83961973788156",
	Description = "A pair of jagged black horns, worn by fighters who would rather be feared than recognized.",
	Rarity = 4,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 40,
		["Max Stamina"] = 20,
		["Additional Damage"] = 1
	}
}