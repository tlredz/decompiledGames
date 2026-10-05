local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	["Ill deliver the package"] = {
		QuestInstance = Quests.Quest("Deliver Package to Elara", Quests.QuestTask("Package delivered", 1)),
		Rewards = {
			Exp = 240,
			Wen = 30
		},
		Category = "Dialogue",
		LogCompletion = true,
		GrantItemOnAccept = "Package",
		TaskSpecs = {
			["Package delivered"] = {
				Type = "Deliver",
				RequiredItem = "Package",
				Count = 1,
				TargetNpc = "Elara"
			}
		},
		MarkerData = {
			img = "rbxassetid://127721943897846",
			minDistance = 35,
			margin = 10,
			useName = "Elara-AddedByAreaLocator"
		}
	}
}