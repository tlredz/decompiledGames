local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
return {
	Tom = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill restock the pantry(Lv 10)") == "Doing" then
				SignalEvent.ToServer("QuestProgress", "Ill restock the pantry(Lv 10)", "Go talk to Tom")
			end

			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill drive the bears back(Lv 10)") == "Doing" then
				return "Tom_Doing"
			end

			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill fell the Mother Bear(Lv 18)") == "Doing" then
				return "Tom_MotherDoing"
			end
		end,
		Text = "Those [bears]<Color=(1,.3,.3)>… [something's off about them.]<Style=Fade,Color=(.8,.7,1)>",
		Answers = true,
		IfTrue = "Tom_2"
	},
	Tom_2 = {
		Text = "If you think you're strong enough, prove it. drive those bears back!",
		Answers = {
			Close = "",
			["Ill drive the bears back(Lv 10)"] = "AddQuest",
			["Ill fell the Mother Bear(Lv 18)"] = "AddQuest"
		}
	},
	Tom_Doing = {
		Text = "weakling..",
		Answers = true
	},
	Tom_MotherDoing = {
		Text = "The cubs were nothing. The [mother]<Color=(1,.3,.3)> still breathes.",
		Answers = true
	}
}