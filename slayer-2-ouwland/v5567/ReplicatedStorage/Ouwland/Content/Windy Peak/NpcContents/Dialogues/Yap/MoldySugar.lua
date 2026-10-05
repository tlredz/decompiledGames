local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag
return {
	MoldySugar = {
		BeforeRun = function(_, _)
			local playerQuestState = Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill deliver the package")

			if playerQuestState == "Doing" then
				return "MoldySugar_Doing"
			elseif playerQuestState == "Done" then
				return "MoldySugar_Done"
			end
		end,
		Text = `Hey, could you deliver this {nameTag("Package")} to the Tailor {nameTag("Elara")}?`,
		Answers = true,
		IfTrue = "MoldySugar_2"
	},
	MoldySugar_2 = {
		Text = "She's not exactly the friendliest person around.",
		Answers = true,
		IfTrue = "MoldySugar_3"
	},
	MoldySugar_3 = {
		Text = "She usually only does business with a certain caliber of customer.",
		Answers = true,
		IfTrue = "MoldySugar_4"
	},
	MoldySugar_4 = {
		Text = "Who knows? This might be your chance to get on her good side.",
		Answers = {
			Close = "",
			["Ill deliver the package"] = "AddQuest"
		}
	},
	MoldySugar_Doing = {
		Text = "hm…",
		Answers = true
	},
	MoldySugar_Done = {
		Text = "She took the package [AND]<Color=(1,.85,.3)> let you in the shop? Ha! Told you it was worth it.",
		Answers = true
	}
}