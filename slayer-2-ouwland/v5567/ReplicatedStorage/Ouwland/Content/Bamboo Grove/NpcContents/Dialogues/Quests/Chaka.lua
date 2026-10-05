local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	["Ill clear out his subordinates(Lv 26)"] = {
		QuestInstance = Quests.Quest(
			"Clear Kaiden's Subordinates",
			Quests.QuestTask("Subordinates defeated", 4, "KaidenSub")
		),
		Rewards = {
			Exp = 468,
			Wen = 211
		},
		Requirements = {
			Level = 26
		},
		Category = "Combat",
		CompletionNotify = {
			Npc = "Chaka",
			Text = "His guard is thin now… Kaiden is next."
		},
		Position = createVector(585.712, 1146.547, -1314.887)
	},
	["Ill deal with Kaiden(Lv 34)"] = {
		QuestInstance = Quests.Quest("Defeat Kaiden", Quests.QuestTask("Defeat Kaiden", 1, "Kaiden")),
		Rewards = {
			Exp = 816,
			Wen = 367
		},
		Requirements = {
			Level = 34
		},
		Category = "Combat",
		CompletionNotify = {
			Npc = "Chaka",
			Text = "Not bad… You wiped them out."
		},
		Position = createVector(585.712, 1146.547, -1314.887)
	}
}