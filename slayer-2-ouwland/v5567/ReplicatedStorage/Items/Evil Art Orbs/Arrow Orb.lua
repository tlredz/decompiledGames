local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://88183573980404",
	Description = "Veined glass for an unbound demon core. Squeeze it to start Arrow core training, where force learns hidden direction.",
	EquipType = Menum.ItemEquipType.Toolbar,
	ToolScript = "Evil Art Orb",
	NoSell = true
}