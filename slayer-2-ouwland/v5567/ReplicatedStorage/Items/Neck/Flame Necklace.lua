local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://71125972409490",
	Description = "A pendant shaped as one rising flame, carrying its own small heat against the collarbone.",
	Rarity = 3,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6
	},
	Stats = {
		["Max Health"] = 15,
		["Max Stamina"] = 10,
		["Additional Damage Factor"] = 0.02
	}
}