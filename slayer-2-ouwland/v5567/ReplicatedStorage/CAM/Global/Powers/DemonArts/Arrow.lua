local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	Icon = "rbxassetid://115502976733718",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Arrow Flight",
			Key = "Z",
			CoolDown = 10,
			Stamina = 14,
			Max_Hold = 5,
			icon = "rbxassetid://95421227725988"
		},
		{
			Name = "Arrow Eruption",
			Key = "X",
			CoolDown = 17,
			Stamina = 24,
			Max_Hold = 0.4,
			SkillStats = {
				cancel_bypass = true,
				stun_bypass_skill = true
			},
			icon = "rbxassetid://132745487576604"
		},
		{
			Name = "Arrow Smackdown",
			Key = "C",
			CoolDown = 12,
			Stamina = 18,
			Max_Hold = 3,
			icon = "rbxassetid://132970161910759"
		},
		{
			Name = "Torrential Arrows",
			Key = "V",
			CoolDown = 16,
			Stamina = 24,
			Max_Hold = 0.8,
			icon = "rbxassetid://130806157255172"
		},
		{
			Name = "Koketsu Arrow",
			SkillStats = {
				additional_damage_scale = 0.45
			},
			Key = "B",
			CoolDown = 50,
			Stamina = 35,
			Boss = "Yahari",
			Max_Hold = 0.6,
			icon = "rbxassetid://100895709337578"
		}
	}
}