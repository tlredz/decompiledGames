local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	Icon = "rbxassetid://80798619872554",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Wintry Icicles",
			SkillStats = {
				additional_damage_scale = 0.3
			},
			Key = "Z",
			CoolDown = 15,
			Stamina = 22,
			Max_Hold = 2,
			icon = "rbxassetid://134845055611552"
		},
		{
			Name = "Cold White Princesses",
			Key = "X",
			CoolDown = 28,
			CooldownGroup = "Counter",
			Stamina = 22,
			Max_Hold = 2.5,
			icon = "rbxassetid://110537503017563",
			SkillStats = {
				counter = Menum.CounterType.All,
				stun_bypass_skill = true
			}
		},
		{
			Name = "Barren Hanging Garden",
			Key = "C",
			SkillStats = {
				strict_stun = true
			},
			CoolDown = 16,
			Stamina = 22,
			Max_Hold = 0.6,
			icon = "rbxassetid://126535125593850"
		},
		{
			Name = "Freezing Cloud",
			Key = "V",
			CoolDown = 16,
			Stamina = 24,
			Max_Hold = 4,
			icon = "rbxassetid://101917393005523"
		},
		{
			Name = "Bodhisattva",
			Key = "B",
			CoolDown = 50,
			Stamina = 35,
			Boss = "Domae",
			Max_Hold = 3.55,
			icon = "rbxassetid://117188368608461"
		}
	}
}