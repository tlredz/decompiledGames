local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Crimson Hanagoromo",
			Key = "Z",
			CoolDown = 1,
			SkillStats = {
				iframe = true
			},
			Max_Hold = 2
		},
		{
			Name = "Peonies of Futility",
			Key = "X",
			CoolDown = 1,
			Max_Hold = 3
		}
	}
}