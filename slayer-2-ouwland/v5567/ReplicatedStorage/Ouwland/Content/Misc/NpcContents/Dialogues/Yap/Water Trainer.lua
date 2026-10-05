local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return {
	["Water Trainer Urokodaki"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill learn Water Breathing(Lv 25)") == "Doing" then
				return "WaterTrainer_Doing"
			end

			local data = Utility.GetData(Players.LocalPlayer)
			local value = data ~= nil and data.Powers.Breathing.Value or ""

			if value == "Water" then
				return "WaterTrainer_Done"
			end

			if value ~= "" then
				return "WaterTrainer_HasStyle"
			end

			if Character_info_provider.HasPowerAccess(Players.LocalPlayer, "Water") then
				return
			else
				return "WaterTrainer_NoAccess"
			end
		end,
		Text = "So. You want to learn Water Breathing.",
		Answers = true,
		IfTrue = "WaterTrainer_2"
	},
	WaterTrainer_2 = {
		Text = "Water does not fight the rock in its path. It wears it down. Prove to me that your resolve is fluid, not brittle.",
		Answers = {
			["Not yet"] = "",
			["Ill learn Water Breathing(Lv 25)"] = "AddQuest"
		}
	},
	WaterTrainer_Doing = {
		Text = "Your form is still stiff. Return when it flows.",
		Answers = true
	},
	WaterTrainer_Done = {
		Text = `You beat Sabito. [Fluid, not brittle.]<Style=Rainbow> That is {Utility.NameTag("Water Breathing")}.`,
		Answers = true,
		IfTrue = "WaterTrainer_Done2"
	},
	WaterTrainer_Done2 = {
		Text = "You have earned the right to call yourself a Water Breather. Do not dishonor it.",
		Answers = true
	},
	WaterTrainer_NoAccess = {
		Text = "Breathing is not in you. Seek a different kind of teacher.",
		Answers = true
	},
	WaterTrainer_HasStyle = {
		Text = "You already carry a Breathing. I will not teach over it.",
		Answers = true
	}
}