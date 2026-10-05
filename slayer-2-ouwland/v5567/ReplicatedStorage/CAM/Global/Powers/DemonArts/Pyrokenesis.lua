local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	Icon = "rbxassetid://97673220720568",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Blood Tiles",
			Key = "Z",
			CoolDown = 14,
			Stamina = 20,
			Max_Hold = 4,
			icon = "rbxassetid://100353705296031"
		},
		{
			Name = "Blood Strike",
			Key = "X",
			SkillStats = {
				strict_stun = true
			},
			CoolDown = 13,
			Stamina = 18,
			Max_Hold = 0.9,
			icon = "rbxassetid://96082450409051"
		},
		{
			Name = "Fiery Slash",
			Key = "C",
			CoolDown = 16,
			Stamina = 24,
			Max_Hold = 5.5,
			SkillStats = {
				additional_damage_scale = 0.62,
				strict_stun = true,
				cancel_bypass = true
			},
			icon = "rbxassetid://126321808468388"
		},
		{
			Name = "Heel Bash",
			Key = "V",
			CoolDown = 17,
			Stamina = 24,
			Max_Hold = 4,
			SkillStats = {
				strict_stun = true
			},
			icon = "rbxassetid://91994351892623"
		},
		{
			Name = "Blood Rupture",
			Key = "B",
			CoolDown = 50,
			Stamina = 35,
			Boss = "Nezura",
			Max_Hold = 1.7,
			icon = "rbxassetid://102382175922370"
		}
	}
}