local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://106586202931711",
	EquipType = Menum.ItemEquipType.Toolbar,
	HasCombat = true,
	Unobtainable = true,
	CombatPreset = "Sound Katanas",
	Breathing = "All",
	Mastery = "Sword",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		}
	}
}