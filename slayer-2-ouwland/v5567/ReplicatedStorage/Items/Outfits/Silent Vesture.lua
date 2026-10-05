local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://97375287611073",
	Description = "Layered vesture with a muffled hem, the kind Mistfall duelists choose when footfalls matter.",
	Rarity = 4,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Costume,
	Price = {
		Wen = 18000
	},
	ResistCoat = true,
	Stats = {
		["Max Health"] = 45,
		["Max Stamina"] = 35,
		["Stamina Regen Speed"] = 0.085,
		["Movement Speed Factor"] = 0.075
	}
}