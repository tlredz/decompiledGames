local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://138496782986316",
	Description = "Slow, clean medicine that quickens the body's mending for a longer stretch after the drink.",
	Rarity = 2,
	EquipType = Menum.ItemEquipType.Toolbar,
	ShowRemainder = true,
	ToolScript = "Health Potion",
	NoSell = true
}