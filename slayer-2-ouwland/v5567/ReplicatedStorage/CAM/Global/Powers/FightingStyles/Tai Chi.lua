return {
	Icon = "rbxassetid://137390019164630",
	Requirements = {
		Race = { "Slayer", "Hybrid", "Human" }
	},
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Flowing Palm",
			SkillStats = {
				strict_stun = true
			},
			CoolDown = 12,
			icon = "rbxassetid://126292494205963",
			Max_Hold = 5,
			Stamina = 18
		},
		{
			Name = "Twin Harmony",
			SkillStats = {
				additional_damage_scale = 0.625,
				iframe = true
			},
			CoolDown = 14,
			icon = "rbxassetid://130399582674069",
			Max_Hold = 1.25,
			Stamina = 22,
			Boss = "TaiChiTrainee"
		}
	}
}