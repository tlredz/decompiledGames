local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return {
	["Wind Trainer Saneri"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill learn Wind Breathing(Lv 25)") == "Doing" then
				return "WindTrainer_Doing"
			end

			local data = Utility.GetData(Players.LocalPlayer)
			local value = data ~= nil and data.Powers.Breathing.Value or ""

			if value == "Wind" then
				return "WindTrainer_Done"
			end

			if value ~= "" then
				return "WindTrainer_HasStyle"
			end

			if Character_info_provider.HasPowerAccess(Players.LocalPlayer, "Wind") then
				return
			else
				return "WindTrainer_NoAccess"
			end
		end,
		Text = "Tch. Another one who thinks Wind Breathing is just swinging fast.",
		Answers = true,
		IfTrue = "WindTrainer_2"
	},
	WindTrainer_2 = {
		Text = "It is cutting through anything in your way, hesitation included. Do not waste my time.",
		Answers = {
			["Not yet"] = "",
			["Ill learn Wind Breathing(Lv 25)"] = "AddQuest"
		}
	},
	WindTrainer_Doing = {
		Text = "You look like you want to quit. Prove me wrong.",
		Answers = true
	},
	WindTrainer_Done = {
		Text = `Hah. You did not hold back. [A storm that does not stop.]<Style=Rainbow> That is {Utility.NameTag("Wind Breathing")}.`,
		Answers = true,
		IfTrue = "WindTrainer_Done2"
	},
	WindTrainer_Done2 = {
		Text = "Now go make some noise out there. Do not embarrass me.",
		Answers = true
	},
	WindTrainer_NoAccess = {
		Text = "Breathing is not in you. Seek a different kind of teacher.",
		Answers = true
	},
	WindTrainer_HasStyle = {
		Text = "You already carry a Breathing. I will not teach over it.",
		Answers = true
	}
}