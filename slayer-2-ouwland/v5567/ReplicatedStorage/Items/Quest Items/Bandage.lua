local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://136531752537290",
	Description = "Field wrap for bad cuts. The healing comes only after the binding is finished.",
	Rarity = 1,
	Category = "Potions",
	EquipType = Menum.ItemEquipType.Toolbar,
	ShowRemainder = true,
	ToolScript = "Bandage"
}