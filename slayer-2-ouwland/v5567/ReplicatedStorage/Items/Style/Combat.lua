local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://17802518394",
	Description = "Bare fists, kept as the starting stance. Most demons cast their Blood Art through it when no weapon is drawn.",
	Rarity = 1,
	EquipType = Menum.ItemEquipType.Toolbar,
	NoDelete = true,
	DemonArt = "All,exceptBlood Manipulation",
	Mastery = "Fist",
	HasCombat = true,
	ActiveToolStats = {
		["Additional Damage"] = 1
	},
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		}
	}
}