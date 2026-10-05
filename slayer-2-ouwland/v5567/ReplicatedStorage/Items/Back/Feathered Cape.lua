local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://115831693608421",
	Description = "Elara's deep blue cape, thick with white fur at the collar, cut for the wind that comes off Mistfall Harbor.",
	Rarity = 5,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 63000
	},
	Stats = {
		["Max Health"] = 55,
		["Stamina Regen Speed"] = 0.09,
		["Movement Speed Factor"] = 0.08
	}
}