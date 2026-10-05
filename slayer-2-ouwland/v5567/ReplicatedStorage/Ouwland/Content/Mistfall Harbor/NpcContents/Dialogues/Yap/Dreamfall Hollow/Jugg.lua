local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
return {
	Jugg = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill clear the cave(Lv 62)") == "Doing" then
				return "Jugg_Doing"
			end
		end,
		Text = "A group of [Blood Hounded Demons]<Color=(1,.3,.3)> has taken over the cave behind me.",
		Answers = true,
		IfTrue = "Jugg_2"
	},
	Jugg_2 = {
		Text = "Get in there and [eliminate them.]<Style=Fade,Color=(1,.3,.3)>",
		Answers = {
			Close = "",
			["Ill clear the cave(Lv 62)"] = "AddQuest"
		}
	},
	Jugg_Doing = {
		Text = "Have you gotten rid of the threat yet?",
		Answers = true
	}
}