local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return {
	["Serpent Trainer Obari"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill learn Serpent Breathing(Lv 25)") == "Doing" then
				return "SerpentTrainer_Doing"
			end

			local data = Utility.GetData(Players.LocalPlayer)
			local value = data ~= nil and data.Powers.Breathing.Value or ""

			if value == "Serpent" then
				return "SerpentTrainer_Done"
			end

			if value ~= "" then
				return "SerpentTrainer_HasStyle"
			end

			if Character_info_provider.HasPowerAccess(Players.LocalPlayer, "Serpent") then
				return
			else
				return "SerpentTrainer_NoAccess"
			end
		end,
		Text = "So. You want to learn the Serpent's way.",
		Answers = true,
		IfTrue = "SerpentTrainer_2"
	},
	SerpentTrainer_2 = {
		Text = "A serpent does not strike blindly. It waits, it coils, it finds the one true opening.",
		Answers = {
			["Not yet"] = "",
			["Ill learn Serpent Breathing(Lv 25)"] = "AddQuest"
		}
	},
	SerpentTrainer_Doing = {
		Text = "Coiling tighter each time. Good, that patience will keep you alive.",
		Answers = true
	},
	SerpentTrainer_Done = {
		Text = `You struck without hesitation, and without wasting a single movement. [The one true opening.]<Style=Rainbow> That is {Utility.NameTag("Serpent Breathing")}.`,
		Answers = true,
		IfTrue = "SerpentTrainer_Done2"
	},
	SerpentTrainer_Done2 = {
		Text = "You have earned my respect. Do not give me a reason to take it back.",
		Answers = true
	},
	SerpentTrainer_NoAccess = {
		Text = "Breathing is not in you. Seek a different kind of teacher.",
		Answers = true
	},
	SerpentTrainer_HasStyle = {
		Text = "You already carry a Breathing. I will not teach over it.",
		Answers = true
	}
}