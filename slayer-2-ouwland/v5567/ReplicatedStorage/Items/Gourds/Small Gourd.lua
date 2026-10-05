local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://83657784342637",
	Description = "Small clay gourd for early breathing drills. A full blow spends it and adds to Slayer training.",
	EquipType = Menum.ItemEquipType.Toolbar,
	Rarity = 1,
	ShowRemainder = true,
	Price = {
		Wen = 800
	}
}