local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	Icon = "rbxassetid://134819096812923",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Spinning Throw",
			Key = "Z",
			CoolDown = 13,
			Stamina = 18,
			Max_Hold = 2.7,
			icon = "rbxassetid://94911966234907"
		},
		{
			Name = "Dunk",
			Key = "X",
			CoolDown = 14,
			Stamina = 20,
			Max_Hold = 5,
			icon = "rbxassetid://130116108473440"
		},
		{
			Name = "Piercing Kick",
			Key = "C",
			CoolDown = 15,
			Stamina = 22,
			Max_Hold = 5,
			icon = "rbxassetid://111684508905590"
		},
		{
			Name = "Meteor",
			SkillStats = {
				additional_damage_scale = 0.88
			},
			Key = "V",
			CoolDown = 18,
			Stamina = 26,
			Max_Hold = 5,
			icon = "rbxassetid://81341343781342"
		},
		{
			Name = "Spiraling Shot",
			Key = "B",
			CoolDown = 50,
			Stamina = 35,
			Boss = "Sumari",
			Max_Hold = 2,
			icon = "rbxassetid://70841094867944"
		}
	}
}