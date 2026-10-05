local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://96682532582437",
	Description = "Sharp alchemist's cordial that keeps tired limbs recovering longer after the swallow.",
	Rarity = 2,
	EquipType = Menum.ItemEquipType.Toolbar,
	ShowRemainder = true,
	ToolScript = "Health Potion",
	NoSell = true
}