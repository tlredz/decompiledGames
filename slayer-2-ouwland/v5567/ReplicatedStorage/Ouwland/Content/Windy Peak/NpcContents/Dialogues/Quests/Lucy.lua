local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	["Ill restock the pantry(Lv 10)"] = {
		QuestInstance = Quests.Quest(
			"Acquire Bear Meat",
			{ Quests.QuestTask("Go talk to Tom", 1), Quests.QuestTask("Bring bear meat back to Lucy", 1) }
		),
		Rewards = {
			Exp = 180,
			Wen = 81,
			["Cooked Bear Meat"] = {
				Quantity = 3
			}
		},
		Requirements = {
			Level = 10
		},
		Category = "Dialogue",
		TaskSpecs = {
			["Go talk to Tom"] = {
				Type = "Deliver",
				TargetNpc = "Tom"
			},
			["Bring bear meat back to Lucy"] = {
				Type = "Deliver",
				RequiredItem = "Bear Meat",
				Count = 1,
				TargetNpc = "Lucy"
			}
		},
		Markers = {
			["Go talk to Tom"] = {
				Npc = "Tom"
			},
			["Bring bear meat back to Lucy"] = {
				Npc = "Lucy",
				After = { "Go talk to Tom" }
			}
		}
	}
}