local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	Icon = "rbxassetid://96036098767646",
	Requirements = {
		Race = { "Demon", "Hybrid" }
	},
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Bone Breaker",
			CoolDown = 25,
			CooldownGroup = "Counter",
			icon = "rbxassetid://92984775583011",
			Max_Hold = 2.5,
			Stamina = 22,
			SkillStats = {
				counter = Menum.CounterType.All,
				cancel_bypass = true
			}
		},
		{
			Name = "Face Breaker",
			CoolDown = 14,
			icon = "rbxassetid://137468625168731",
			Max_Hold = 1.2,
			Stamina = 22,
			SkillStats = {
				cancel_bypass = true
			},
			Boss = "SoryuTrainee"
		}
	}
}