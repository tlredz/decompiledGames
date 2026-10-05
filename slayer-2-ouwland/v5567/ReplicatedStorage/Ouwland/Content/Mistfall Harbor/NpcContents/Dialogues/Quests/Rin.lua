local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local BeastBornSettings = require(script.Parent.Parent.Parent.Parent.NpcShared.BeastBornSettings)
return {
	["Ill drive them off(Lv 47)"] = {
		QuestInstance = Quests.Quest(
			"Hold the Night",
			Quests.QuestTask("Beast Born Demons defeated", 5, BeastBornSettings.Settings.NpcCode)
		),
		Rewards = {
			Exp = 846,
			Wen = 381
		},
		Requirements = {
			Level = 47
		},
		Category = "Combat",
		CompletionNotify = {
			Npc = "Rin",
			Text = "You've kept everyone safe tonight. Thank you."
		},
		Hint = "They come for the civilians after dark.",
		Markers = {
			["Beast Born Demons defeated"] = {
				Icon = "",
				Position = BeastBornSettings.Center
			}
		}
	}
}