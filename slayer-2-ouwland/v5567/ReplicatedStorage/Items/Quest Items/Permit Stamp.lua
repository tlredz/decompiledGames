local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://113110668868367",
	Description = "Sofen's missing stamp from the docks. Keep it in hand, or the permit errand starts over.",
	Rarity = 1,
	ShowRemainder = true,
	EquipType = Menum.ItemEquipType.Toolbar,
	UseIdle = true,
	Unique = true,
	EquipOnGrant = true,
	DropOnUnequip = true,
	DropOnDeath = true
}