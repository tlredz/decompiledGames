local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
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
			Name = "Throwing Strike",
			Key = "Z",
			CoolDown = 1,
			Max_Hold = 5
		},
		{
			Name = "Crazy Cutting",
			Key = "X",
			CoolDown = 1,
			CooldownGroup = "Counter",
			SkillStats = {
				counter = Menum.CounterType.All
			},
			Max_Hold = 3
		},
		{
			Name = "Slice and Dice",
			Key = "C",
			CoolDown = 1,
			Max_Hold = 4
		},
		{
			Name = "Palisade Bite",
			Key = "V",
			CoolDown = 1,
			Max_Hold = 4
		},
		{
			Name = "Devouring Rush",
			Key = "B",
			CoolDown = 1,
			Max_Hold = 2.7333333333333334
		}
	}
}