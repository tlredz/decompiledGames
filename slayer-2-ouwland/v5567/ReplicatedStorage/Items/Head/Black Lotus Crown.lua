local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://95657999477355",
	Description = "Domae's black crown, gilded at every edge and trailing pale ribbons. It came off his head still cold.",
	Rarity = 5,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	Stats = {
		["Max Health"] = 240,
		["Health Regen Speed"] = 0.11,
		["Max Stamina"] = 80
	}
}