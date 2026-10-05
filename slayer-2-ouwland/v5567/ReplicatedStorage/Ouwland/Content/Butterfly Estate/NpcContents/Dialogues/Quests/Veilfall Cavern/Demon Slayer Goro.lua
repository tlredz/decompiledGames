local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local LesserDemonSettings = require(script.Parent.Parent.Parent.Parent.Parent.NpcShared.LesserDemonSettings)
local GreaterDemonSettings = require(script.Parent.Parent.Parent.Parent.Parent.NpcShared.GreaterDemonSettings)
return {
	["Ill thin them out(Lv 75)"] = {
		QuestInstance = Quests.Quest(
			"Thin the Cavern Floor",
			Quests.QuestTask("Lesser Demons defeated", 6, LesserDemonSettings.Settings.NpcCode)
		),
		Rewards = {
			Exp = 1350,
			Wen = 608
		},
		Requirements = {
			Race = { "Slayer", "Hybrid" },
			Level = 75
		},
		Category = "Combat",
		CompletionNotify = {
			Npc = "Demon Slayer Goro",
			Text = "Six down. They'll fill back in before long. Come find me when they do."
		},
		Markers = {
			["Lesser Demons defeated"] = {
				Icon = "",
				Position = LesserDemonSettings.Center + createVector(0, 15, 0)
			}
		}
	},
	["Ill go up after the greater ones(Lv 83)"] = {
		QuestInstance = Quests.Quest(
			"Hunt the Greater Demons",
			Quests.QuestTask("Greater Demons defeated", 7, GreaterDemonSettings.Settings.NpcCode)
		),
		Rewards = {
			Exp = 1494,
			Wen = 672
		},
		Requirements = {
			Race = { "Slayer", "Hybrid" },
			Level = 83
		},
		Category = "Combat",
		CompletionNotify = {
			Npc = "Demon Slayer Goro",
			Text = "Seven of the greaters. The ledges fill back in slower than the floor does, but they do fill back in."
		},
		Markers = {
			["Greater Demons defeated"] = {
				Icon = "",
				Position = GreaterDemonSettings.Center + createVector(0, 15, 0)
			}
		}
	}
}