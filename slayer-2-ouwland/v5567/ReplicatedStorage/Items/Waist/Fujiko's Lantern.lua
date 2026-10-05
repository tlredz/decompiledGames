local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://104833904710624",
	Description = "Fujiko's lantern, navy lacquer under gold clouds, keeping a duelist's light steady through rain and shaken ground.",
	Rarity = 5,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	Stats = {
		["Max Health"] = 40,
		["Max Stamina"] = 20,
		["Additional Damage Factor"] = 0.035,
		Illumination = 0.65
	}
}