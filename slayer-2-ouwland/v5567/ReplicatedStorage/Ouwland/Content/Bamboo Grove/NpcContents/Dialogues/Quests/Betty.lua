local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	["Ill look for it(Lv 10)"] = {
		QuestInstance = Quests.Quest("Find Betty's Gemstone", Quests.QuestTask("Gemstone found", 1)),
		Rewards = {
			Exp = 600,
			Wen = 60
		},
		Requirements = {
			Level = 10
		},
		Category = "Dialogue",
		LogCompletion = true,
		CompletionNotify = {
			Npc = "Betty",
			Text = "You found it! Thank you for bringing it back!"
		},
		TaskSpecs = {
			["Gemstone found"] = {
				Type = "Pickup",
				MaxDistance = 25,
				Positions = { vector.create(682.763, 973.362, -504.465) }
			}
		},
		MarkerData = {
			img = "rbxassetid://127721943897846",
			minDistance = 35,
			margin = 10,
			useName = "Betty-AddedByAreaLocator"
		}
	}
}