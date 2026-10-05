local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://82075408729722",
	Description = "Worn brass discs hung with long pale feathers that turn at the smallest movement of air.",
	Rarity = 4,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 7500
	},
	Stats = {
		["Max Health"] = 30,
		["Stamina Regen Speed"] = 0.07,
		["Movement Speed Factor"] = 0.06
	}
}