local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return {
	["Lamplighter Isamu"] = {
		BeforeRun = function(_, _)
			local playerQuestState = Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill walk the order")

			if playerQuestState == "Done" then
				return "Lantern_Done"
			elseif playerQuestState == "Doing" then
				return "Lantern_Doing"
			end

			return nil
		end,
		Text = "Mind the floor. Those plates were laid by the lamplighters before me, and they still keep count.",
		Answers = true,
		IfTrue = "Lantern_2"
	},
	Lantern_2 = {
		Text = "They light in an order. Hold it in your head, then walk it back. Jump from plate to plate, and land square.",
		Answers = true,
		IfTrue = "Lantern_3"
	},
	Lantern_3 = {
		Text = "Five rounds. Each adds a plate to the last, and the lights come quicker the further you get.",
		Answers = true,
		IfTrue = "Lantern_4"
	},
	Lantern_4 = {
		Text = "Miss one and the whole floor goes dark, and you start over from the first. Walk all five, and I will draw you what the old keepers carried.",
		Answers = {
			["Ill walk the order"] = "AddQuest",
			["Not yet"] = ""
		}
	},
	Lantern_Doing = {
		Text = "The floor is lit. Eyes down, and jump clean.",
		Answers = true
	},
	Lantern_Done = {
		Text = `You walked every round. The {Utility.NameTag("drawings")} are yours, and I only draw them once.`,
		Answers = {
			Close = ""
		}
	}
}