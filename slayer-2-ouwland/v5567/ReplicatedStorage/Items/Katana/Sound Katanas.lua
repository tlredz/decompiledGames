local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://106586202931711",
	Description = "Tengai's paired Nichirin blades are chained for rhythm, each swing landing like a drumbeat through smoke.",
	Rarity = 5,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Metal Scraps"] = 10,
		["Refinement Ore"] = 6
	},
	HasCombat = true,
	CombatPreset = "Sound Katanas",
	Breathing = "All",
	Mastery = "Sword",
	ActiveToolStats = {
		["Additional Damage"] = 2,
		["Additional Damage Factor"] = 0.037,
		["Block Points"] = 1.95
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