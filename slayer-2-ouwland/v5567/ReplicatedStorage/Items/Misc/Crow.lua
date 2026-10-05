local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://105924821858207",
	Description = "Calls a Kasugai crow to perch nearby and bring Corps hunt orders. A click sends it back into the sky.",
	Rarity = 5,
	EquipType = Menum.ItemEquipType.Toolbar,
	NoToolIdle = true,
	Unique = true,
	NoDelete = true,
	Requirements = {
		Race = { "Slayer", "Hybrid" }
	}
}