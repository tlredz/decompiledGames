local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://106800176396196",
	Description = "Smoked bear meat from Lucy's pantry. Eating it restores health and quickens recovery for a short while.",
	Rarity = 1,
	Category = "Potions",
	ShowRemainder = true,
	EquipType = Menum.ItemEquipType.Toolbar
}