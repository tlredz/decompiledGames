local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://137660010726182",
	Description = "Hoyuzo's twin blades are ugly with use. Blood Manipulation rides them as execution runs and tearing vortexes.",
	Rarity = 4,
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Metal Scraps"] = 10,
		["Refinement Ore"] = 2
	},
	DemonArt = "Blood Manipulation",
	EquipRequirements = {
		Race = { "Demon", "Hybrid" }
	},
	HasCombat = true,
	CombatPreset = "Sickles",
	Mastery = "Sickles",
	SkillCategory = "Sickles",
	ActiveToolStats = {
		["Additional Damage"] = 1,
		["Additional Damage Factor"] = 0.021,
		["Block Points"] = 1.35
	},
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Execution Scyther",
			SkillStats = {
				additional_damage_scale = 0.4
			},
			CoolDown = 18,
			icon = "rbxassetid://74114109530745",
			Max_Hold = 5,
			Stamina = 28
		},
		{
			Name = "Scyther Vortex",
			SkillStats = {
				additional_damage_scale = 0.28
			},
			CoolDown = 15,
			icon = "rbxassetid://85996996726779",
			Max_Hold = 5,
			Boss = "Hoyuzo",
			Stamina = 24
		}
	}
}