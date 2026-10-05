local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://86141612085249",
	Description = "Field bottle for quick mending. Drink it to close a fresh wound before the next exchange.",
	Rarity = 1,
	EquipType = Menum.ItemEquipType.Toolbar,
	ShowRemainder = true
}