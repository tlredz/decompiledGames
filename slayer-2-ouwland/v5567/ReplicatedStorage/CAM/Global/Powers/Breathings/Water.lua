local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	Icon = "rbxassetid://133532094066680",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Water Surface Slash",
			Key = "Z",
			CoolDown = 10,
			Stamina = 14,
			icon = "rbxassetid://127042872322277",
			SkillStats = {
				strict_stun = true
			},
			Max_Hold = 3
		},
		{
			Name = "Whirl Pool",
			SkillStats = {
				additional_damage_scale = 0.5,
				strict_stun = true
			},
			Key = "X",
			CoolDown = 13,
			Stamina = 18,
			icon = "rbxassetid://79681742341174",
			Max_Hold = 2
		},
		{
			Name = "Water Wheel",
			Key = "C",
			CoolDown = 16,
			Stamina = 24,
			icon = "rbxassetid://74516050794419",
			Max_Hold = 3.5
		},
		{
			Name = "Constant Flux",
			Key = "V",
			CoolDown = 18,
			Stamina = 26,
			icon = "rbxassetid://80630323102004",
			Max_Hold = 2.9,
			SkillStats = {
				strict_stun = true,
				iframe = true,
				Ranked = {
					iframe = false,
					cancel_bypass = true
				}
			}
		},
		{
			Name = "Dead Calm",
			Key = "B",
			CoolDown = 50,
			Stamina = 35,
			icon = "rbxassetid://140303524288158",
			Boss = "Giyen",
			Max_Hold = 8.3,
			SkillStats = {
				additional_damage_scale = 0.5,
				cancel_bypass = true,
				strict_stun = true
			}
		}
	}
}