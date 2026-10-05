local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://72069600318258",
	Description = "Curved silver cradling a pale blue bead, keeping a thread of moving air pressed close to the ear.",
	Rarity = 1,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 2
	},
	Stats = {
		["Max Health"] = 25,
		["Stamina Regen Speed"] = 0.03,
		["Movement Speed Factor"] = 0.02
	}
}