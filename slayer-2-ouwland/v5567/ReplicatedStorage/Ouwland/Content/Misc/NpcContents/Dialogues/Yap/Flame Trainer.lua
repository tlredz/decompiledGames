local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return {
	["Flame Trainer Rengu"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill learn Flame Breathing(Lv 25)") == "Doing" then
				return "FlameTrainer_Doing"
			end

			local data = Utility.GetData(Players.LocalPlayer)
			local value = data ~= nil and data.Powers.Breathing.Value or ""

			if value == "Flame" then
				return "FlameTrainer_Done"
			end

			if value ~= "" then
				return "FlameTrainer_HasStyle"
			end

			if Character_info_provider.HasPowerAccess(Players.LocalPlayer, "Flame") then
				return
			else
				return "FlameTrainer_NoAccess"
			end
		end,
		Text = "HAH! A new face! I can already see it: there is a fire in your eyes.",
		Answers = true,
		IfTrue = "FlameTrainer_2"
	},
	FlameTrainer_2 = {
		Text = "Let us see if that fire survives training, and my top student.",
		Answers = {
			["Not yet"] = "",
			["Ill learn Flame Breathing(Lv 25)"] = "AddQuest"
		}
	},
	FlameTrainer_Doing = {
		Text = "Still standing? Good. Back to it.",
		Answers = true
	},
	FlameTrainer_Done = {
		Text = `Magnificent! [Burning brighter than fear.]<Style=Rainbow> That is {Utility.NameTag("Flame Breathing")}.`,
		Answers = true,
		IfTrue = "FlameTrainer_Done2"
	},
	FlameTrainer_Done2 = {
		Text = "I have taught you all I can. Go, and never let that flame gutter out!",
		Answers = true
	},
	FlameTrainer_NoAccess = {
		Text = "Breathing is not in you. Seek a different kind of teacher.",
		Answers = true
	},
	FlameTrainer_HasStyle = {
		Text = "You already have a Breathing. I will not teach over it.",
		Answers = true
	}
}