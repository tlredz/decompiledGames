local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://124398156891686",
	Description = "Polished blue plate from back room trade, made for guards who expect the opening hit to land.",
	Rarity = 5,
	Class = "Tank",
	EquipType = Menum.ItemEquipType.Costume,
	Price = {
		Wen = 110000
	},
	Stats = {
		["Max Health"] = 150,
		["Health Regen Speed"] = 0.1,
		["Max Stamina"] = 70,
		["Damage Reduction"] = 1,
		["Damage Reduction Factor"] = 0.01
	}
}