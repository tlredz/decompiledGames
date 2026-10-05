local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://84425514730751",
	Description = "Gilt studs on a dark cord, worth rather less than the first glance across a market stall suggests.",
	Rarity = 2,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 4
	},
	Stats = {
		["Max Health"] = 40,
		["Stamina Regen Speed"] = 0.03,
		["Movement Speed Factor"] = 0.025
	}
}