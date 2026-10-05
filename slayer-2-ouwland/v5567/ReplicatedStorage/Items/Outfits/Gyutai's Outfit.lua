local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://114532020510299",
	Description = "Gyutai's patched clothing smells of iron rain, the fabric slit where blood sickles learned their path.",
	Rarity = 5,
	Class = "Tank",
	EquipType = Menum.ItemEquipType.Costume,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	ResistCoat = true,
	Stats = {
		["Max Health"] = 160,
		["Health Regen Speed"] = 0.08,
		["Max Stamina"] = 80,
		["Damage Reduction Factor"] = 0.045
	}
}