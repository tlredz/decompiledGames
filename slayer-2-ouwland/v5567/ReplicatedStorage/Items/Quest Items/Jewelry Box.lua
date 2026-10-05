local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://115665536257208",
	Description = "Ginzo's jewelry box from Hidden Mist. Keep it in hand, or the road sends you back for it.",
	Rarity = 1,
	ShowRemainder = true,
	EquipType = Menum.ItemEquipType.Toolbar,
	UseIdle = true,
	Unique = true,
	EquipOnGrant = true,
	DropOnUnequip = true,
	DropOnDeath = true
}