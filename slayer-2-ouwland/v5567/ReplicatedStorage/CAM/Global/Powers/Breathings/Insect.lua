local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	Icon = "rbxassetid://98591569041732",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Compound Eye Hexagon",
			Key = "Z",
			SkillStats = {
				additional_damage_scale = 0.57,
				strict_stun = true,
				cancel_bypass = true
			},
			CoolDown = 17,
			Stamina = 28,
			icon = "rbxassetid://111525805312469",
			Max_Hold = 3.2
		},
		{
			Name = "True Flutter",
			Key = "X",
			CoolDown = 16,
			Stamina = 14,
			icon = "rbxassetid://94242984701652",
			Max_Hold = 3,
			SkillStats = {
				strict_stun = true
			}
		},
		{
			Name = "Fluttering Sting",
			Key = "C",
			CoolDown = 16,
			Stamina = 22,
			icon = "rbxassetid://85922268652373",
			Max_Hold = 1.1
		},
		{
			Name = "Hundred-Legged Zigzag",
			Key = "V",
			SkillStats = {
				strict_stun = true
			},
			CoolDown = 18,
			Stamina = 26,
			icon = "rbxassetid://136861618421363",
			Max_Hold = 3.3
		},
		{
			Name = "Illusory Light",
			Key = "B",
			CoolDown = 50,
			Stamina = 35,
			icon = "rbxassetid://117921474432074",
			Boss = "Shinora",
			Max_Hold = 8
		}
	}
}