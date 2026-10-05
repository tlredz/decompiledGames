local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://138623870963111",
	Description = "Saneri's open jacket is wind scoured at the edges, made for a Hashira who cuts straight through the gale.",
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
		["Max Stamina"] = 55,
		["Stamina Regen Speed"] = 0.1,
		["Movement Speed Factor"] = 0.09
	}
}