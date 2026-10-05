local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://96682532582437",
	Description = "Briny draught for deep dives. Drink it and your breath lasts longer beneath the water.",
	Rarity = 2,
	EquipType = Menum.ItemEquipType.Toolbar,
	ShowRemainder = true,
	ToolScript = "Health Potion",
	Price = {
		Wen = 600,
		["Demon Horns"] = 6
	}
}