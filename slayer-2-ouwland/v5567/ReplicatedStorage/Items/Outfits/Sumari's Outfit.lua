local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://94914728818015",
	Description = "Sumari's outfit keeps its round, playful trim, a cruel costume for a game no child survives.",
	Rarity = 5,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Costume,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	ResistCoat = true,
	Stats = {
		["Max Health"] = 75,
		["Health Regen Speed"] = 0.08,
		["Max Stamina"] = 80,
		["Movement Speed Factor"] = 0.08,
		["Stamina Regen Speed"] = 0.09
	}
}