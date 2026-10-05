local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag
return {
	Elara = {
		BeforeRun = function(_, _)
			local playerQuestState = Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill deliver the package")

			if playerQuestState == "Doing" then
				return "Elara_Delivery"
			elseif playerQuestState == "Done" then
				return "Elara_Welcome"
			end
		end,
		Text = "I only do business with a certain caliber of customer. You are not it.",
		Answers = true,
		IfTrue = "Elara_Idle2"
	},
	Elara_Idle2 = {
		Text = "If you want my attention, make yourself useful to someone I trust.",
		Answers = true,
		IfTrue = "Elara_Idle3"
	},
	Elara_Idle3 = {
		Text = `Farmer {nameTag("MoldySugar")} in {nameTag("Windy Peak")} always needs a hand.`,
		Answers = true
	},
	Elara_Delivery = {
		Text = `...That {nameTag("Package")}. Is that the farmer's handwriting on it?`,
		Answers = {
			Close = "",
			["Hand over the package"] = "DeliverPackageToElara"
		}
	},
	Elara_Thanks = {
		Text = `Ah, Farmer {nameTag("Moldy")}'s acquaintance.`,
		Answers = true,
		IfTrue = "Elara_Thanks2"
	},
	Elara_Thanks2 = {
		Text = "Anyone who earns that old farmer's trust is welcome in my shop.",
		Answers = true,
		IfTrue = "Elara_Thanks3"
	},
	Elara_Thanks3 = {
		Text = "Feel free to browse.",
		Answers = 1
	},
	Elara_NoPackage = {
		Text = "You're not carrying anything for me.",
		Answers = true
	},
	Elara_Welcome = {
		Text = "A pleasure doing business with you. Stop by anytime.",
		Answers = true
	}
}