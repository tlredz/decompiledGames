local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	DisableClothing = {
		Hair = true
	},
	Icon = "rbxassetid://130134254359853",
	Description = "A tall black hat hung with a violet chain, matched to a coat meant for crossing a room unremembered.",
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