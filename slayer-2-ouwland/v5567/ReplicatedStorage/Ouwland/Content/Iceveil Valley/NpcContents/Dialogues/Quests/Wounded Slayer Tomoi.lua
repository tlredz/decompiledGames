local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local HighDemonSettings = require(script.Parent.Parent.Parent.Parent.NpcShared.HighDemonSettings)
return {
	["Ill help you defeat them(Lv 90)"] = {
		QuestInstance = Quests.Quest(
			"Drive Off the High Demons",
			Quests.QuestTask("High Demons defeated", 8, HighDemonSettings.Settings.NpcCode)
		),
		Rewards = {
			Exp = 1620,
			Wen = 729
		},
		Requirements = {
			Race = { "Slayer", "Hybrid" },
			Level = 90
		},
		Category = "Combat",
		CompletionNotify = {
			Npc = "Wounded Slayer Tomoi",
			Text = "You've done us a great service. Please, take this reward."
		},
		Markers = {
			["High Demons defeated"] = {
				Icon = "",
				Position = HighDemonSettings.Center + vector.create(0, 15, 0)
			}
		}
	}
}