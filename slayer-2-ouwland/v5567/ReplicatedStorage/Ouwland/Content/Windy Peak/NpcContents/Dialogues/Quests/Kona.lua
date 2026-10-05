local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	["Ill find the pages"] = {
		QuestInstance = Quests.Quest("Recover the Lost Pages", Quests.QuestTask("Lost Pages", 5)),
		Rewards = {
			Exp = 20,
			Wen = 10,
			["Book of Guidance"] = {
				Quantity = 1,
				Unique = true
			}
		},
		Category = "Dialogue",
		CompletionNotify = {
			Npc = "Kona",
			Text = "You found them... The Book of Guidance is yours.",
			Duration = 4
		},
		TaskSpecs = {
			["Lost Pages"] = {
				Type = "Pickup",
				MaxDistance = 25,
				Positions = {
					createVector(-726.984, 1243.199, -939.239),
					createVector(-738, 1258.5, -1264),
					createVector(-452.039, 1241, -927.139),
					createVector(-676.415, 1243.399, -1139.289),
					createVector(-540.68, 1241.31, -928.901)
				}
			}
		}
	}
}