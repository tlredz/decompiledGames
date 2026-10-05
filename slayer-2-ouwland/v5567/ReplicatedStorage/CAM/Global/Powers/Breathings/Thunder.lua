local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	Icon = "rbxassetid://74166650843382",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Thunder Clap and Flash",
			Key = "Z",
			CoolDown = 12,
			Stamina = 14,
			icon = "rbxassetid://127992376017080",
			Max_Hold = 5,
			SkillStats = {
				strict_stun = true
			}
		},
		{
			Name = "Lightning Fold",
			Key = "X",
			CoolDown = 13,
			Stamina = 18,
			icon = "rbxassetid://73295142249677",
			Max_Hold = 5
		},
		{
			Name = "Rice Spirit",
			Key = "C",
			SkillStats = {
				strict_stun = true
			},
			CoolDown = 17,
			Stamina = 24,
			icon = "rbxassetid://105345444081366",
			Max_Hold = 3
		},
		{
			Name = "Godspeed",
			Key = "V",
			CoolDown = 18,
			Stamina = 26,
			icon = "rbxassetid://132748533245500",
			Max_Hold = 5
		},
		{
			Name = "Flaming Thunder God",
			SkillStats = {
				additional_damage_scale = 0.24
			},
			Key = "B",
			CoolDown = 50,
			Stamina = 35,
			icon = "rbxassetid://122686936817985",
			Boss = "Zentaro",
			Max_Hold = 5
		}
	}
}