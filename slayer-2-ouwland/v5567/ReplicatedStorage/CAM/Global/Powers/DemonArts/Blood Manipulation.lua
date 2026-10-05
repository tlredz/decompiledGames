local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	Icon = "rbxassetid://96706601549949",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Bend",
			SkillStats = {
				additional_damage_scale = 0.26
			},
			Key = "Z",
			CoolDown = 13,
			Stamina = 18,
			icon = "rbxassetid://93846626126677",
			Max_Hold = 3
		},
		{
			Name = "Rampant Arc Rampage",
			Key = "X",
			CoolDown = 16,
			Stamina = 22,
			icon = "rbxassetid://75386191562744",
			Max_Hold = 3,
			SkillStats = {
				additional_damage_scale = 0.34,
				cancel_bypass = true
			}
		},
		{
			Name = "On Slaught",
			Key = "C",
			CoolDown = 16,
			Stamina = 24,
			icon = "rbxassetid://104054702339197",
			Max_Hold = 2,
			SkillStats = {
				additional_damage_scale = 0.44,
				strict_stun = true
			}
		},
		{
			Name = "Rotating Blood Scythe",
			Key = "V",
			CoolDown = 16,
			Stamina = 24,
			icon = "rbxassetid://73334943761848",
			Max_Hold = 5,
			SkillStats = {
				additional_damage_scale = 0.5,
				strict_stun = true
			}
		},
		{
			Name = "Circular Slashes",
			Key = "B",
			CoolDown = 50,
			Stamina = 35,
			Boss = "Gyutai",
			icon = "rbxassetid://104576401654266",
			Max_Hold = 5,
			SkillStats = {
				additional_damage_scale = 0.65
			}
		}
	}
}