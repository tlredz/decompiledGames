local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Menum)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	Icon = "rbxassetid://88342158665980",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Melodic Whisper",
			Key = "Z",
			CoolDown = 13,
			Stamina = 18,
			Max_Hold = 2,
			SkillStats = {
				cancel_bypass = true
			},
			icon = "rbxassetid://108910048519905"
		},
		{
			Name = "Ordained Flesh",
			SkillStats = {
				additional_damage_scale = 0.6,
				cancel_bypass = true
			},
			Key = "X",
			CoolDown = 16,
			Stamina = 24,
			Max_Hold = 1.67,
			icon = "rbxassetid://113785797893672"
		},
		{
			Name = "Piercing Flesh",
			Key = "C",
			CoolDown = 14,
			Stamina = 22,
			Max_Hold = 3,
			icon = "rbxassetid://83674471679744"
		},
		{
			Name = "Flesh Barrage",
			SkillStats = {
				additional_damage_scale = 0.35,
				cancel_bypass = true
			},
			Key = "V",
			CoolDown = 16,
			Stamina = 24,
			Max_Hold = 0.67,
			icon = "rbxassetid://135936400013915"
		},
		{
			Name = "Flesh Monster",
			SkillStats = {
				additional_damage_scale = 0.22,
				iframe = true
			},
			Key = "B",
			CoolDown = 50,
			Stamina = 35,
			Boss = "Enru",
			Max_Hold = 0.2,
			icon = "rbxassetid://123241521003523"
		}
	}
}