local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://135919049184463",
	Description = "A road spear with enough reach to keep demons honest, built for storming rushes and clean pierces.",
	Rarity = 4,
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Metal Scraps"] = 10,
		["Refinement Ore"] = 2
	},
	EquipRequirements = {
		Race = { "Human", "Slayer", "Hybrid" }
	},
	HasCombat = true,
	CombatPreset = "Spear",
	Mastery = "Spear",
	SkillCategory = "Spear",
	ActiveToolStats = {
		["Additional Damage"] = 1,
		["Additional Damage Factor"] = 0.022,
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
			Name = "Storm Rush",
			SkillStats = {
				additional_damage_scale = 0.78,
				cancel_bypass = true
			},
			CoolDown = 18,
			icon = "rbxassetid://71270513349797",
			Max_Hold = 6,
			Stamina = 28
		},
		{
			Name = "Storm Piercer",
			SkillStats = {
				strict_stun = true,
				cancel_bypass = true
			},
			CoolDown = 14,
			icon = "rbxassetid://73641228099685",
			Max_Hold = 2,
			Stamina = 22
		}
	}
}