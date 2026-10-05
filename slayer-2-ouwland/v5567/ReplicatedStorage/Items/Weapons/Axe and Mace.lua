local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://126701174205506",
	Description = "A chained axe and mace for Stone Breathing, heavy enough that each step feels like a vow to stand firm.",
	Rarity = 5,
	Class = "Tank",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Metal Scraps"] = 4,
		["Refinement Ore"] = 2
	},
	HasCombat = true,
	CombatPreset = "Axe and Mace",
	Breathing = "Stone Breathing",
	Mastery = "Axe and Mace",
	Category = "AxeAndMace",
	RefineStats = { "Additional Damage", "Damage Reduction" },
	ActiveToolStats = {
		["Additional Damage"] = 2.31,
		["Additional Damage Factor"] = 0.045,
		["Block Points"] = 1.5,
		["Damage Reduction"] = 0.85
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