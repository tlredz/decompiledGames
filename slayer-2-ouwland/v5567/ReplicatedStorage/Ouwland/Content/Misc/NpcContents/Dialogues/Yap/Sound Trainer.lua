local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return {
	["Sound Trainer Tengai"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill learn Sound Breathing(Lv 25)") == "Doing" then
				return "SoundTrainer_Doing"
			end

			local data = Utility.GetData(Players.LocalPlayer)
			local value = data ~= nil and data.Powers.Breathing.Value or ""

			if value == "Sound" then
				return "SoundTrainer_Done"
			end

			if value ~= "" then
				return "SoundTrainer_HasStyle"
			end

			if Character_info_provider.HasPowerAccess(Players.LocalPlayer, "Sound") then
				return
			else
				return "SoundTrainer_NoAccess"
			end
		end,
		Text = "WELL WELL WELL! Look who wandered in!",
		Answers = true,
		IfTrue = "SoundTrainer_2"
	},
	SoundTrainer_2 = {
		Text = "You get to be trained by the flashiest Sound Breather in the Corps. Sound Breathing is a performance: explosive, rhythmic, dazzling. Try to keep up with the beat!",
		Answers = {
			["Not yet"] = "",
			["Ill learn Sound Breathing(Lv 25)"] = "AddQuest"
		}
	},
	SoundTrainer_Doing = {
		Text = "Still going? Good. Feel that rhythm yet?",
		Answers = true
	},
	SoundTrainer_Done = {
		Text = `MAGNIFICENT! An explosive finish! [Flashy is non negotiable.]<Style=Rainbow> That is {Utility.NameTag("Sound Breathing")}.`,
		Answers = true,
		IfTrue = "SoundTrainer_Done2"
	},
	SoundTrainer_Done2 = {
		Text = "Now go be dazzling. Anything less and I will pretend I never taught you.",
		Answers = true
	},
	SoundTrainer_NoAccess = {
		Text = "Breathing is not in you. Seek a different kind of teacher.",
		Answers = true
	},
	SoundTrainer_HasStyle = {
		Text = "You already carry a Breathing. I will not teach over it.",
		Answers = true
	}
}