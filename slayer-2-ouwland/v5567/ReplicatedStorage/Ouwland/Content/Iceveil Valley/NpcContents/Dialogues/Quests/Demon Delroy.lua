local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local KanoeDemonSlayerSettings = require(script.Parent.Parent.Parent.Parent.NpcShared.KanoeDemonSlayerSettings)
return {
	["Theyre not welcome here(Lv 90)"] = {
		QuestInstance = Quests.Quest(
			"Thin the Kanoe Ranks",
			Quests.QuestTask("Kanoe Demon Slayers defeated", 8, KanoeDemonSlayerSettings.Settings.NpcCode)
		),
		Rewards = {
			Exp = 1620,
			Wen = 729
		},
		Requirements = {
			Race = { "Demon", "Hybrid" },
			Level = 90
		},
		Category = "Combat",
		CompletionNotify = {
			Npc = "Demon Delroy",
			Text = "Eight fewer of them in this valley. That will hold for a while."
		},
		Markers = {
			["Kanoe Demon Slayers defeated"] = {
				Icon = "",
				Position = KanoeDemonSlayerSettings.Center + vector.create(0, 15, 0)
			}
		}
	}
}