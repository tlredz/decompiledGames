local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://115665536257208",
	Description = "Mistfall's supply crate for Shiori's Estate stores, carried in hand until the delivery is signed off.",
	Rarity = 1,
	ShowRemainder = true,
	EquipType = Menum.ItemEquipType.Toolbar,
	UseIdle = true
}