local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	DisableClothing = {
		Hair = true
	},
	Icon = "rbxassetid://132583238133709",
	Description = "The same sack, torn into a snarl and fitted with small red horns. Somehow this one costs more.",
	Rarity = 3,
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6
	}
}