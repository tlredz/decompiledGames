local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag
return {
	["Harvester of Souls Zurinyz"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill learn the Reaping Blades Style(Lv 100)") == "Doing" then
				local data = Utility.GetData(Players.LocalPlayer)
				local illlearntheReapingBladesStyleLv100 = Quests.Holder["Ill learn the Reaping Blades Style(Lv 100)"]
				local child

				if data ~= nil then
					child = illlearntheReapingBladesStyleLv100 ~= nil and data.Quests.Holder:FindFirstChild(illlearntheReapingBladesStyleLv100.QuestInstance.Name) or nil
				end

				local commonFish = child ~= nil and child.Tasks:FindFirstChild("Common Fish") or nil

				if commonFish == nil or not (commonFish.Value.Value < commonFish.Max.Value) then
					return "Zurinyz_Doing"
				end

				return "Zurinyz_DoingFish"
			else
				local data = Utility.GetData(Players.LocalPlayer)
				local value = data ~= nil and data.Powers.FightingStyle.Value or ""

				if value == "" then
					return
				elseif value == "Reaping Blades" then
					return "Zurinyz_Done"
				end

				return "Zurinyz_HasStyle"
			end
		end,
		Text = "Most people come seeking answers before they've earned them.",
		Answers = true,
		IfTrue = "Zurinyz_2"
	},
	Zurinyz_2 = {
		Text = `So, you've decided to walk the path of the {nameTag("Reaper")}. Understand this: strength alone will not earn you this fighting style.`,
		Answers = true,
		IfTrue = "Zurinyz_3"
	},
	Zurinyz_3 = {
		Text = "Before I can teach you, you must prove it. Bring me the catch, the scroll, and my student's defeat.",
		Answers = {
			["Not yet"] = "",
			["Ill learn the Reaping Blades Style(Lv 100)"] = "AddQuest"
		}
	},
	Zurinyz_Doing = {
		Text = "Just give up..",
		Answers = true
	},
	Zurinyz_DoingFish = {
		Text = "Just give up..",
		Answers = {
			["Ill hand over the catch"] = "ZurinyzTakeCatch",
			["Not yet"] = ""
		}
	},
	Zurinyz_Catch = {
		Text = "Good. The cold will keep them.",
		Answers = true
	},
	Zurinyz_NoCatch = {
		Text = "You bring me nothing. Do not make a habit of it.",
		Answers = true
	},
	Zurinyz_HasStyle = {
		Text = "You already walk another path. I will not braid the two.",
		Answers = true
	},
	Zurinyz_Done = {
		Text = "You've done well. The scroll, the training, and Kuzan. You've proven yourself worthy.",
		Answers = true,
		IfTrue = "Zurinyz_Done2"
	},
	Zurinyz_Done2 = {
		Text = `[Nothing wasted. Nothing spared.]<Style=Rainbow> That is what the {nameTag("Reaping Blades")} are for.`,
		Answers = true
	}
}