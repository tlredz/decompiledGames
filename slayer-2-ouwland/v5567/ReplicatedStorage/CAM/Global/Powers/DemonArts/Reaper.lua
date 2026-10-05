local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	Icon = "rbxassetid://108234262131987",
	Stats = {
		["Dash Speed Factor"] = 0.25
	},
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Reap Of Despair",
			Key = "Z",
			State = true,
			[Menum.skillState.Default] = {
				Name = "Reap Of Despair",
				CoolDown = 13,
				Stamina = 18,
				Max_Hold = 4,
				icon = "rbxassetid://129888728787568"
			},
			[Menum.skillState.Air] = {
				Name = "Reaping Slashes",
				CoolDown = 13,
				Stamina = 18,
				Max_Hold = 1.05,
				icon = "rbxassetid://121185661921533"
			}
		},
		{
			Name = "Reaptide",
			Key = "X",
			CoolDown = 19,
			Stamina = 28,
			Max_Hold = 5,
			icon = "rbxassetid://91746290508005"
		},
		{
			Name = "Sonido",
			SkillStats = {
				additional_damage_scale = 0.25
			},
			Key = "C",
			CoolDown = 10,
			Stamina = 14,
			Max_Hold = 3,
			icon = "rbxassetid://129613854553832"
		},
		{
			Name = "Phantom Step",
			Key = "V",
			CoolDown = 18,
			Stamina = 26,
			Max_Hold = 3.4,
			icon = "rbxassetid://86058539585781"
		},
		{
			Name = "Sonido Surge",
			Key = "B",
			CoolDown = 50,
			Stamina = 35,
			Boss = "Reaper",
			Max_Hold = 0.6,
			icon = "rbxassetid://98662378990382",
			SkillStats = {
				strict_stun = true,
				transparent = true
			}
		}
	}
}