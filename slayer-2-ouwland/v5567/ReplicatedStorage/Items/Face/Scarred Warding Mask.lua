local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://106970710456678",
	Description = "Sabito's warding mask, gouged along the cheek. He wore it to the end and never once took it off for anybody.",
	Rarity = 5,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Accessory,
	IsMask = true,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	Stats = {
		["Max Health"] = 60,
		["Max Stamina"] = 30,
		["Additional Damage"] = 2
	}
}