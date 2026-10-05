local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://125907216438342",
	Description = "Red and white wool with the bite of winter mint, too clean for the road until the first hard march.",
	Rarity = 1,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Product = 3708918842
	},
	Stats = {
		["Max Health"] = 25,
		["Stamina Regen Speed"] = 0.03,
		["Movement Speed Factor"] = 0.02
	}
}