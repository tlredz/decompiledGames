local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://",
	Description = "",
	Rarity = 1,
	EquipType = Menum.ItemEquipType.Toolbar,
	Skills = {
		{
			Name = "Template",
			Key = "W",
			CoolDown = 1,
			icon = "rbxassetid://"
		}
	},
	Stats = {
		Strength = 5,
		["Max Health"] = 10
	},
	ToolbarStats = {},
	ActiveToolStats = {
		["Additional Damage"] = 1
	}
}