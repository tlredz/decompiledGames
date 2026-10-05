local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://124158363512738",
	Description = "A long beaked mask in night lacquer, copied from a foreign physician's design out of an age that blamed bad air for everything.",
	Rarity = 5,
	Class = "Sentinel",
	EquipType = Menum.ItemEquipType.Accessory,
	IsMask = true,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	Stats = {
		["Max Health"] = 70,
		["Max Stamina"] = 35,
		["Block Points"] = 1,
		["Block Regen"] = 0.1
	}
}