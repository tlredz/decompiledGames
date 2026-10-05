local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://113766600791759",
	Description = "White lacquer following a panther's jawline, made for fighters who take the hit and keep closing anyway.",
	Rarity = 4,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	IsMask = true,
	Price = {
		Wen = 14400
	},
	Stats = {
		["Max Health"] = 105,
		["Max Stamina"] = 35
	}
}