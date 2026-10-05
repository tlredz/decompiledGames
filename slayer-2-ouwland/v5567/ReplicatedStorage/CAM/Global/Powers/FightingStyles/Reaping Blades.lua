return {
	Icon = "rbxassetid://70455887864605",
	Requirements = {
		Race = { "Demon", "Hybrid" }
	},
	DemonArt = "Shockwave,Reaper",
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Cross Reaver",
			CoolDown = 12,
			icon = "rbxassetid://94137793247656",
			Max_Hold = 5,
			Stamina = 18
		},
		{
			Name = "Traversal Reap",
			SkillStats = {
				additional_damage_scale = 0.74
			},
			CoolDown = 18,
			icon = "rbxassetid://99035825230315",
			Max_Hold = 5,
			Stamina = 28,
			Boss = "ReaperTrainee"
		}
	}
}