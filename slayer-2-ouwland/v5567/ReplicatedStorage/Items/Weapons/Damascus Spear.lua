local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://98917181402179",
	Description = "Violet climbs the spearhead, steadying a storm rush charge and the pierce that catches a foe clean.",
	Rarity = 6,
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	NoSell = true,
	EquipRequirements = {
		Race = { "Human", "Slayer", "Hybrid" }
	},
	HasCombat = true,
	CombatPreset = "Spear",
	Mastery = "Spear",
	SkillCategory = "Spear",
	ActiveToolStats = {
		["Additional Damage"] = 4,
		["Additional Damage Factor"] = 0.081,
		["Block Points"] = 5.25,
		["Block Regen"] = 0.95
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