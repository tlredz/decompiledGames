local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local DayAndNightHandler = require(ReplicatedStorage.CAM.Global.DayAndNightHandler)
return {
	Rin = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill drive them off(Lv 47)") == "Doing" then
				return "Rin_Doing"
			end

			if DayAndNightHandler.IsEnabled() and not DayAndNightHandler.IsNight() then
				return "Rin_Day"
			end
		end,
		Text = "[Beast Born Demons]<Color=(1,.3,.3)> are closing in on the harbor again tonight.",
		Answers = true,
		IfTrue = "Rin_2"
	},
	Rin_2 = {
		Text = "Please, [clear them out]<Style=Fade,Color=(1,.3,.3)> before anyone gets hurt.",
		Answers = {
			Close = "",
			["Ill drive them off(Lv 47)"] = "AddQuest"
		}
	},
	Rin_Doing = {
		Text = "The demons are still out there. Please hurry.",
		Answers = true
	},
	Rin_Day = {
		Text = "They only come with the dark. Find me again after sundown.",
		Answers = true
	}
}