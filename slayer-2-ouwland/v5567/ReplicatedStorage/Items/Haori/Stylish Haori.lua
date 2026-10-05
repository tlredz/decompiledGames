local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://95468884009960",
	Description = "Pink and trimmed in feathers, cut open to show the shirt. It matches the boa, the lenses and the grin, because of course it does.",
	Rarity = 5,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	DisableClothing = {
		EquippedShirt = false
	},
	Stats = {
		["Max Health"] = 60,
		["Max Stamina"] = 40,
		["Stamina Regen Speed"] = 0.09,
		["Movement Speed Factor"] = 0.08
	}
}