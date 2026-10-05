local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://122693557587113",
	Description = "One square red stone in a plain setting, the sort of charm found where old locks have rusted through.",
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