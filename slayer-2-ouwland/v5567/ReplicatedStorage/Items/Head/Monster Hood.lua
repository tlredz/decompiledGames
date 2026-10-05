local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	DisableClothing = {
		Hair = true
	},
	Icon = "rbxassetid://129798069104629",
	Description = "A snarling red beast's head with its fangs bared, pulled on by fighters who plant themselves and let the blows come.",
	Rarity = 4,
	Class = "Sentinel",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 40,
		["Max Stamina"] = 20,
		["Block Points"] = 1,
		["Block Regen"] = 0.1
	}
}