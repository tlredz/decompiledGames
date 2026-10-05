local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://129877027147215",
	Description = "Worn brass stamped with a single character, giving so thin a light that the snow only feels farther from dawn.",
	Rarity = 3,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6
	},
	Stats = {
		["Max Health"] = 15,
		["Stamina Regen Speed"] = 0.03,
		["Movement Speed Factor"] = 0.02,
		Illumination = 0.35
	}
}