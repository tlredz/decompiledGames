local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://104503394947473",
	Description = "Large Estate gourd for practiced lungs. Blowing it out spends the vessel and advances Slayer breathing discipline.",
	EquipType = Menum.ItemEquipType.Toolbar,
	Rarity = 3,
	ToolScript = "Small Gourd",
	ShowRemainder = true,
	Price = {
		Wen = 8800
	}
}