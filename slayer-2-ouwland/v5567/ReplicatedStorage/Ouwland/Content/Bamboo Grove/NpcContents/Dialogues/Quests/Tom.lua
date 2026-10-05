local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BearSettings = require(ReplicatedStorage.Ouwland.Content["Bamboo Grove"].NpcShared.BearSettings)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	["Ill drive the bears back(Lv 10)"] = {
		QuestInstance = Quests.Quest("Hunt the Bears", Quests.QuestTask("Bear Cubs hunted", 4, "BearCub")),
		Rewards = {
			Exp = 180,
			Wen = 81,
			["Bear Meat"] = {
				Quantity = 1,
				Unique = true,
				RequiresQuest = "Ill restock the pantry(Lv 10)",
				GrantNotify = {
					Npc = "Lucy",
					Text = "Bring it to me!"
				}
			}
		},
		Requirements = {
			Level = 10
		},
		Category = "Combat",
		CompletionNotify = {
			Npc = "Tom",
			Text = "That thins them out…",
			Duration = 4
		},
		Position = BearSettings.Center
	},
	["Ill fell the Mother Bear(Lv 18)"] = {
		QuestInstance = Quests.Quest("Fell the Mother Bear", Quests.QuestTask("Fell the Mother Bear", 1, "MotherBear")),
		Rewards = {
			Exp = 432,
			Wen = 194,
			["Bear Meat"] = {
				Quantity = 1,
				Unique = true,
				RequiresQuest = "Ill restock the pantry(Lv 10)",
				GrantNotify = {
					Npc = "Lucy",
					Text = "Bring it to me!"
				}
			}
		},
		Requirements = {
			Level = 18
		},
		Category = "Combat",
		CompletionNotify = {
			Npc = "Tom",
			Text = "You actually did it…",
			Duration = 4
		},
		Position = BearSettings.Center
	}
}