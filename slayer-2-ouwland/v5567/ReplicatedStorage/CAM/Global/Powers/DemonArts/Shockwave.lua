local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	Icon = "rbxassetid://129123987865967",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Demon Core",
			SkillStats = {
				additional_damage_scale = 0.63
			},
			Key = "Z",
			CoolDown = 15,
			Stamina = 20,
			Max_Hold = 2.5,
			icon = "rbxassetid://138372732851355"
		},
		{
			Name = "Compass Needle",
			Key = "X",
			CoolDown = 13,
			CooldownGroup = "Counter",
			Stamina = 18,
			Max_Hold = 3,
			icon = "rbxassetid://132531910447794",
			SkillStats = {
				counter = Menum.CounterType.All
			}
		},
		{
			Name = "Explosive Fury",
			SkillStats = {
				additional_damage_scale = 0.67
			},
			Key = "C",
			CoolDown = 16,
			Stamina = 24,
			Max_Hold = 5,
			icon = "rbxassetid://125839960375380"
		},
		{
			Name = "Flashing Willow",
			Key = "V",
			State = true,
			[Menum.skillState.Default] = {
				Name = "Flashing Willow",
				CoolDown = 17,
				Stamina = 24,
				Max_Hold = 3,
				icon = "rbxassetid://113331024786889",
				SkillStats = {
					cancel_bypass = true
				}
			},
			[Menum.skillState.Air] = {
				Name = "Flashing Willow Aerial",
				CoolDown = 17,
				Stamina = 24,
				Max_Hold = 0.5,
				icon = "rbxassetid://126372452746132",
				SkillStats = {
					cancel_bypass = true
				}
			}
		},
		{
			Name = "Annihilation Type",
			Key = "B",
			State = true,
			[Menum.skillState.Default] = {
				Name = "Annihilation Type",
				SkillStats = {
					strict_stun = true
				},
				CoolDown = 50,
				Stamina = 35,
				Boss = "Akazo",
				Max_Hold = 3,
				icon = "rbxassetid://107300958665418"
			},
			CompassNeedleBuff = {
				Name = "Chaotic Afterglow",
				SkillStats = {
					additional_damage_scale = 0.29,
					iframe = true,
					strict_stun = true
				},
				CoolDown = 50,
				Stamina = 35,
				Boss = "Akazo",
				Max_Hold = 3,
				icon = "rbxassetid://93937833780111"
			}
		}
	}
}