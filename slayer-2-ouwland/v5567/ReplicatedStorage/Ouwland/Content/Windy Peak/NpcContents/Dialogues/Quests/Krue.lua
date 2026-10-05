local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local BanditSettings = require(ReplicatedStorage.Ouwland.Content["Windy Peak"].NpcShared.BanditSettings)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	["Ill take 3 bandits"] = {
		QuestInstance = Quests.Quest(
			"Defeat 3 bandits",
			Quests.QuestTask("Bandits remaining", 3, BanditSettings.Settings.NpcCode)
		),
		Rewards = {
			Exp = 25,
			Wen = 12
		},
		Category = "Combat",
		Position = createVector(-296.759, 1226.214, -1025.3597)
	},
	["Ill take the bandit boss(Lv 7)"] = {
		QuestInstance = Quests.Quest("Defeat The Bandit Boss", Quests.QuestTask("Defeat Zuko", 1, "Zuko")),
		Rewards = {
			Exp = 168,
			Wen = 76
		},
		Requirements = {
			Level = 7
		},
		Category = "Combat",
		Position = createVector(-296.759, 1226.214, -1025.359)
	}
}