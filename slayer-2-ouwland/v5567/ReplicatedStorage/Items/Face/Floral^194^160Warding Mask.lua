local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://126811082799013",
	Description = "A warding fox painted over with blue flowers, the old scars underneath still readable if you tilt it to the light.",
	Rarity = 3,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Accessory,
	IsMask = true,
	Price = {
		["Silk Thread"] = 6
	},
	Stats = {
		["Max Health"] = 25,
		["Max Stamina"] = 10,
		["Additional Damage"] = 1
	}
}