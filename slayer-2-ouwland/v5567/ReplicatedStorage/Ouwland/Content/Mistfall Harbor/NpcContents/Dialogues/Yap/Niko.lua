local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag
return {
	["Estate Worker Niko"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill deliver the supply box(Lv 70)") ~= "Doing" then
				return
			end

			local child = Utility.GetData(Players.LocalPlayer).Quests.Holder:FindFirstChild(Quests.Holder["Ill deliver the supply box(Lv 70)"].QuestInstance.Name)
			local delivertoShiori = child and child.Tasks:FindFirstChild("Deliver to Shiori")

			if delivertoShiori and delivertoShiori.Value.Value >= delivertoShiori.Max.Value then
				return "Niko_Return"
			end

			return "Niko_Waiting"
		end,
		Text = "Hey.",
		Answers = true,
		IfTrue = "Niko_2"
	},
	Niko_2 = {
		Text = `I've got a shipment off the morning boat that needs to go down to the {nameTag("Butterfly Estate")}.`,
		Answers = true,
		IfTrue = "Niko_3"
	},
	Niko_3 = {
		Text = `Medicine, mostly. {nameTag("Shiori")} has been asking after it for a week.`,
		Answers = true,
		IfTrue = "Niko_4"
	},
	Niko_4 = {
		Text = "Normally I'd run it down myself, but I'm buried in work.",
		Answers = true,
		IfTrue = "Niko_5"
	},
	Niko_5 = {
		Text = "[It's right here]<Color=(1,.85,.3)>, packed and ready. Mind helping me out?",
		Answers = {
			Close = "",
			["Ill deliver the supply box(Lv 70)"] = "AddQuest",
			["Where is the estate?"] = "Niko_Way"
		}
	},
	Niko_Way = {
		Text = "Head east out of the harbour and follow the river down. The estate sits at the bottom of it.",
		Answers = true,
		IfTrue = "Niko_Way2"
	},
	Niko_Way2 = {
		Text = "Set your spawn at their crystal while you're down there. Saves you the climb back.",
		Answers = true,
		IfTrue = "Niko_5"
	},
	Niko_Waiting = {
		Text = "You've still got the box. Don't keep them waiting.",
		Answers = true
	},
	Niko_Return = {
		Text = "Back already. Did it get down there in one piece?",
		Answers = {
			Close = "",
			["Shiori says thank you"] = "ReportSupplyBoxToNiko"
		}
	},
	Niko_Thanks = {
		Text = "Looks like it arrived safely. Appreciate the help.",
		Answers = true,
		IfTrue = "Niko_Thanks2"
	},
	Niko_Thanks2 = {
		Text = "There'll be another boat in before long. Come find me.",
		Answers = true
	}
}