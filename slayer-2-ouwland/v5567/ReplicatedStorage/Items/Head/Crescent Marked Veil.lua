local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://97946575578952",
	Description = "A pale face veil marked with a single red sun, drawn on by fighters who prefer to be noticed late.",
	Rarity = 4,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 30,
		["Stamina Regen Speed"] = 0.07,
		["Movement Speed Factor"] = 0.06
	}
}