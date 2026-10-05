local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://87030113893288",
	Description = "A gilt lozenge trailing red and white feathers, still smelling faintly of the roadside smoke it travelled through.",
	Rarity = 1,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 1500
	},
	Stats = {
		["Max Health"] = 25,
		["Stamina Regen Speed"] = 0.03,
		["Movement Speed Factor"] = 0.02
	}
}