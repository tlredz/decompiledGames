local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	["Ill get this letter delivered"] = {
		QuestInstance = Quests.Quest("Deliver the Coded Letter", Quests.QuestTask("Deliver the Letter to Chaka", 1)),
		Rewards = {
			Exp = 480,
			Wen = 60
		},
		Category = "Dialogue",
		LogCompletion = true,
		NoSave = true,
		ConsumeItemOnAccept = "Suspicious Note",
		GrantItemOnAccept = "Letter",
		TaskSpecs = {
			["Deliver the Letter to Chaka"] = {
				Type = "Deliver",
				RequiredItem = "Letter",
				Count = 1,
				TargetNpc = "Chaka"
			}
		},
		MarkerData = {
			img = "rbxassetid://127721943897846",
			minDistance = 35,
			margin = 10,
			useName = "Chaka-AddedByAreaLocator"
		}
	}
}