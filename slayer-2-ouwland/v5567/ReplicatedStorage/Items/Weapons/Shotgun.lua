local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://102830977601236",
	Description = "Built from water stained plans copied off a lost Slayer's weapon, it fights close with buckshot bursts and punishing holds.",
	Rarity = 5,
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Metal Scraps"] = 10,
		["Refinement Ore"] = 6
	},
	EquipRequirements = {
		Race = { "Human", "Slayer", "Hybrid" }
	},
	HasCombat = true,
	CombatPreset = "Shotgun",
	Mastery = "Shotgun",
	SkillCategory = "Shotgun",
	ActiveToolStats = {
		["Additional Damage"] = 2,
		["Additional Damage Factor"] = 0.043,
		["Block Points"] = 2.7
	},
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Buck Shot",
			SkillStats = {
				strict_stun = true,
				cancel_bypass = true
			},
			CoolDown = 12,
			icon = "rbxassetid://76469151905907",
			Max_Hold = 0.8,
			Stamina = 20
		},
		{
			Name = "Point Blank",
			SkillStats = {
				cancel_bypass = true
			},
			CoolDown = 14,
			icon = "rbxassetid://110263482684308",
			Max_Hold = 2,
			Stamina = 22
		},
		{
			Name = "Shellshock Frenzy",
			SkillStats = {
				additional_damage_scale = 0.64,
				cancel_bypass = true
			},
			CoolDown = 16,
			icon = "rbxassetid://118247957127138",
			Max_Hold = 2.6,
			Stamina = 26
		}
	}
}