local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
return {
	["Demon Delroy"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Theyre not welcome here(Lv 90)") == "Doing" then
				return "Delroy_Doing"
			end
		end,
		Text = "Slayers keep working their way up this valley. [Kanoe]<Color=(.7,.8,.95)> rank.",
		Answers = true,
		IfTrue = "Delroy_2"
	},
	Delroy_2 = {
		Text = "They've come close enough that it's my problem now.",
		Answers = true,
		IfTrue = "Delroy_3"
	},
	Delroy_3 = {
		Text = "Eight of them. That should make the rest think twice about coming up here.",
		Answers = {
			Close = "",
			["Theyre not welcome here(Lv 90)"] = "AddQuest"
		}
	},
	Delroy_Doing = {
		Text = "Are they still up there?",
		Answers = true
	}
}