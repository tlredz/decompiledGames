local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local IceProfoundDemonSettings = require(script.Parent.Parent.Parent.Parent.NpcShared.IceProfoundDemonSettings)
local FireProfoundDemonSettings = require(script.Parent.Parent.Parent.Parent.NpcShared.FireProfoundDemonSettings)
return {
	["Ill drive back the frost(Lv 105)"] = {
		QuestInstance = Quests.Quest(
			"Drive Back the Frost",
			Quests.QuestTask("Ice Profound Demons defeated", 9, IceProfoundDemonSettings.Settings.NpcCode)
		),
		Rewards = {
			Exp = 1890,
			Wen = 851
		},
		Requirements = {
			Level = 105
		},
		Category = "Combat",
		CompletionNotify = {
			Npc = "Demon Slayer Mitsu",
			Text = "The cold's giving ground. Take this, you earned it out there."
		},
		Markers = {
			["Ice Profound Demons defeated"] = {
				Icon = "",
				Position = IceProfoundDemonSettings.Center + createVector(0, 15, 0)
			}
		}
	},
	["Ill put out the blaze(Lv 115)"] = {
		QuestInstance = Quests.Quest(
			"Put Out the Blaze",
			Quests.QuestTask("Fire Profound Demons defeated", 8, FireProfoundDemonSettings.Settings.NpcCode)
		),
		Rewards = {
			Exp = 2070,
			Wen = 932
		},
		Requirements = {
			Level = 115
		},
		Category = "Combat",
		CompletionNotify = {
			Npc = "Demon Slayer Mitsu",
			Text = "That's the burning ones done. The harder half of this valley."
		},
		Markers = {
			["Fire Profound Demons defeated"] = {
				Icon = "",
				Position = FireProfoundDemonSettings.Center + createVector(0, 15, 0)
			}
		}
	}
}