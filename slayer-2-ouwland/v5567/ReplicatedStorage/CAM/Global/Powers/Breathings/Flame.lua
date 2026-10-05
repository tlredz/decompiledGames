local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	Icon = "rbxassetid://122638691732413",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Unknowing Fire",
			Key = "Z",
			CoolDown = 17,
			Stamina = 22,
			icon = "rbxassetid://127301357010840",
			SkillStats = {
				cancel_bypass = true,
				strict_stun = true
			},
			Max_Hold = 5
		},
		{
			Name = "Blazing Universe",
			Key = "X",
			CoolDown = 14,
			Stamina = 18,
			icon = "rbxassetid://77002398736078",
			Max_Hold = 5
		},
		{
			Name = "Flame Undulation",
			Key = "C",
			CoolDown = 15,
			CooldownGroup = "Counter",
			Stamina = 24,
			icon = "rbxassetid://139797349210093",
			SkillStats = {
				counter = Menum.CounterType.All,
				cancel_bypass = true
			},
			Max_Hold = 5
		},
		{
			Name = "Flame Tiger",
			Key = "V",
			CoolDown = 20,
			Stamina = 26,
			icon = "rbxassetid://73052261085534",
			SkillStats = {
				strict_stun = true
			},
			Max_Hold = 3.2
		},
		{
			Name = "Purgatory",
			Key = "B",
			CoolDown = 50,
			Stamina = 35,
			icon = "rbxassetid://124063778859730",
			Boss = "Rengu",
			Max_Hold = 5
		}
	}
}