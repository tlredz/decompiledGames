local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	Icon = "rbxassetid://79966440986518",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Obi Barrage",
			Key = "Z",
			CoolDown = 14,
			Stamina = 20,
			Max_Hold = 4,
			SkillStats = {
				additional_damage_scale = 0.56,
				strict_stun = true,
				cancel_bypass = true
			},
			icon = "rbxassetid://85466805635682"
		},
		{
			Name = "Obi Pursuit",
			Key = "X",
			CoolDown = 12,
			Stamina = 18,
			Max_Hold = 2,
			SkillStats = {
				strict_stun = true
			},
			icon = "rbxassetid://123033381592998"
		},
		{
			Name = "Obi Grab",
			Key = "C",
			CoolDown = 14,
			Stamina = 22,
			Max_Hold = 1,
			SkillStats = {
				strict_stun = true
			},
			icon = "rbxassetid://102016544842844"
		},
		{
			Name = "Obi Field",
			Key = "V",
			CoolDown = 16,
			Stamina = 24,
			Max_Hold = 7,
			SkillStats = {
				cancel_bypass = true,
				stun_bypass_skill = true
			},
			icon = "rbxassetid://107971300277116"
		},
		{
			Name = "Obi Charge",
			Key = "B",
			CoolDown = 50,
			Stamina = 35,
			Boss = "Datai",
			Max_Hold = 5,
			SkillStats = {
				strict_stun = true,
				cancel_bypass = true
			},
			icon = "rbxassetid://96191763762223"
		}
	}
}