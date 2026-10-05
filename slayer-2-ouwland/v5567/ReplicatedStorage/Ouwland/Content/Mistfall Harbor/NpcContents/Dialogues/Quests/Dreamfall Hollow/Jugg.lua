local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local BloodHoundedDemonSettings = require(script.Parent.Parent.Parent.Parent.Parent.NpcShared.BloodHoundedDemonSettings)
return {
	["Ill clear the cave(Lv 62)"] = {
		QuestInstance = Quests.Quest(
			"Purge Dreamfall Hollow",
			Quests.QuestTask("Blood Hounded Demons defeated", 7, BloodHoundedDemonSettings.Settings.NpcCode)
		),
		Rewards = {
			Exp = 1116,
			Wen = 502
		},
		Requirements = {
			Race = { "Slayer", "Hybrid" },
			Level = 62
		},
		Category = "Combat",
		CompletionNotify = {
			Npc = "Jugg",
			Text = "You've done us a great service. Please, take this reward."
		},
		Markers = {
			["Blood Hounded Demons defeated"] = {
				Icon = "",
				Position = BloodHoundedDemonSettings.Center + vector.create(0, 15, 0)
			}
		}
	}
}