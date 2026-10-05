local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local MizunoeDemonSlayerSettings = require(script.Parent.Parent.Parent.Parent.Parent.NpcShared.MizunoeDemonSlayerSettings)
return {
	["Ill break their watch(Lv 75)"] = {
		QuestInstance = Quests.Quest(
			"Break the Cave Watch",
			Quests.QuestTask("Mizunoe Demon Slayers defeated", 6, MizunoeDemonSlayerSettings.Settings.NpcCode)
		),
		Rewards = {
			Exp = 1350,
			Wen = 608
		},
		Requirements = {
			Race = { "Demon", "Hybrid" },
			Level = 75
		},
		Category = "Combat",
		CompletionNotify = {
			Npc = "Demon Mokuro",
			Text = "The mouth is quiet again. They'll send more, but not today."
		},
		Markers = {
			["Mizunoe Demon Slayers defeated"] = {
				Icon = "",
				Position = MizunoeDemonSlayerSettings.Center + vector.create(0, 15, 0)
			}
		}
	}
}