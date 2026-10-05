local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	Category = "AxeAndMace",
	Icon = "rbxassetid://118884560853258",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Volcanic Conquest",
			Key = "Z",
			CoolDown = 12,
			Stamina = 18,
			icon = "rbxassetid://127944944722848",
			SkillStats = {
				strict_stun = true,
				cancel_bypass = true
			},
			Max_Hold = 2.3
		},
		{
			Name = "Seismic Burst",
			Key = "X",
			CoolDown = 10,
			Stamina = 14,
			icon = "rbxassetid://116141643859156",
			Max_Hold = 0.85
		},
		{
			Name = "Upper Smash",
			Key = "C",
			CoolDown = 15,
			Stamina = 24,
			icon = "rbxassetid://80327943891842",
			SkillStats = {
				strict_stun = true
			},
			Max_Hold = 5
		},
		{
			Name = "Stone Wall",
			Key = "V",
			CoolDown = 19,
			CooldownGroup = "Counter",
			Stamina = 24,
			icon = "rbxassetid://126990875517168",
			SkillStats = {
				stun_bypass_skill = true,
				counter = Menum.CounterType.All
			},
			Max_Hold = 2.5
		},
		{
			Name = "Arcs of Justice",
			SkillStats = {
				additional_damage_scale = 0.32,
				cancel_bypass = true
			},
			Key = "B",
			CoolDown = 50,
			Stamina = 35,
			icon = "rbxassetid://80796560822561",
			Boss = "Gyorei",
			Max_Hold = 3
		}
	}
}