local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag
return {
	Chaka = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill clear out his subordinates(Lv 26)") == "Doing" then
				return "Chaka_SubsDoing"
			end

			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill deal with Kaiden(Lv 34)") == "Doing" then
				return "Chaka_Doing"
			end

			local playerQuestState = Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill get this letter delivered")

			if playerQuestState == "Doing" then
				return "Chaka_Delivery"
			end

			if playerQuestState == "Done" then
				return
			else
				return "Chaka_Idle"
			end
		end,
		Text = "The bears were never my concern.",
		Answers = true,
		IfTrue = "Chaka_2"
	},
	Chaka_2 = {
		Text = "[Kaiden]<Color=(1,.3,.3)> is.",
		Answers = true,
		IfTrue = "Chaka_3"
	},
	Chaka_3 = {
		Text = "I've watched him long enough, and he's become a threat.",
		Answers = true,
		IfTrue = "Chaka_4"
	},
	Chaka_4 = {
		Text = "It's time he [disappeared.]<Style=Fade,Color=(1,.3,.3)>",
		Answers = {
			Close = "",
			["Ill clear out his subordinates(Lv 26)"] = "AddQuest",
			["Ill deal with Kaiden(Lv 34)"] = "AddQuest"
		}
	},
	Chaka_Idle = {
		Text = `You should speak with {nameTag("Kazu")} in {nameTag("Windy Peak")} before coming here...`,
		Answers = true
	},
	Chaka_Delivery = {
		Text = "You look like you're carrying something for me.",
		Answers = {
			Close = "",
			["Hand over the letter"] = "DeliverLetterToChaka"
		}
	},
	Chaka_Thanks = {
		Text = `From {nameTag("Noote")}? ...I see. So the bandits have eyes inside the village now.`,
		Answers = true,
		IfTrue = "Chaka"
	},
	Chaka_NoLetter = {
		Text = `You don't seem to have the {nameTag("Letter")} on you.`,
		Answers = true
	},
	Chaka_Doing = {
		Text = "Have you gotten rid of the threat yet?",
		Answers = true
	},
	Chaka_SubsDoing = {
		Text = "His [subordinates]<Color=(1,.3,.3)> are still standing. Thin his ranks.",
		Answers = true
	}
}