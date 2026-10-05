local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	Icon = "rbxassetid://105129696827308",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Bursting Bloom",
			Key = "Z",
			CoolDown = 10,
			Stamina = 14,
			icon = "rbxassetid://71263444717318",
			Max_Hold = 5
		},
		{
			Name = "Roar",
			Key = "X",
			CoolDown = 13,
			Stamina = 20,
			icon = "rbxassetid://112398591861989",
			SkillStats = {
				cancel_bypass = true
			},
			Max_Hold = 5
		},
		{
			Name = "Exploding Beads",
			Key = "C",
			CoolDown = 15,
			Stamina = 22,
			icon = "rbxassetid://96484177191049",
			SkillStats = {
				strict_stun = true
			},
			Max_Hold = 2.5
		},
		{
			Name = "Resounding Slashes",
			SkillStats = {
				additional_damage_scale = 0.39
			},
			Key = "V",
			CoolDown = 20,
			Stamina = 24,
			icon = "rbxassetid://104208526145412",
			Max_Hold = 5
		},
		{
			Name = "String Performance",
			SkillStats = {
				additional_damage_scale = 0.35
			},
			Key = "B",
			CoolDown = 50,
			Stamina = 35,
			icon = "rbxassetid://116693415036677",
			Boss = "Tengai",
			Max_Hold = 5
		}
	}
}