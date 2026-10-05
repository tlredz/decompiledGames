local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag
return {
	["Soryu Expert Kazuma"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill learn the Soryu Style(Lv 62)") == "Doing" then
				local data = Utility.GetData(Players.LocalPlayer)
				local illlearntheSoryuStyleLv62 = Quests.Holder["Ill learn the Soryu Style(Lv 62)"]
				local child

				if data ~= nil then
					child = illlearntheSoryuStyleLv62 ~= nil and data.Quests.Holder:FindFirstChild(illlearntheSoryuStyleLv62.QuestInstance.Name) or nil
				end

				local commonFish = child ~= nil and child.Tasks:FindFirstChild("Common Fish") or nil

				if commonFish == nil or not (commonFish.Value.Value < commonFish.Max.Value) then
					return "Kazuma_Doing"
				end

				return "Kazuma_DoingFish"
			else
				local data = Utility.GetData(Players.LocalPlayer)
				local value = data ~= nil and data.Powers.FightingStyle.Value or ""

				if value == "" then
					return
				elseif value == "Soryu" then
					return "Kazuma_Done"
				end

				return "Kazuma_HasStyle"
			end
		end,
		Text = "Most people come seeking answers before they've earned them.",
		Answers = true,
		IfTrue = "Kazuma_2"
	},
	Kazuma_2 = {
		Text = `I can teach you {nameTag("Soryu")}, but it won't be easy.`,
		Answers = {
			["Not yet"] = "",
			["Ill learn the Soryu Style(Lv 62)"] = "AddQuest"
		}
	},
	Kazuma_Doing = {
		Text = "Just give up..",
		Answers = true
	},
	Kazuma_DoingFish = {
		Text = "Just give up..",
		Answers = {
			["Ill hand over the catch"] = "KazumaTakeCatch",
			["Not yet"] = ""
		}
	},
	Kazuma_Catch = {
		Text = "Hm. They will do. I am keeping count.",
		Answers = true
	},
	Kazuma_NoCatch = {
		Text = "You are holding nothing. Come back with fish.",
		Answers = true
	},
	Kazuma_HasStyle = {
		Text = "You already carry a style. I do not teach over another master's work.",
		Answers = true
	},
	Kazuma_Done = {
		Text = "You've done well. You've proven yourself worthy.",
		Answers = true,
		IfTrue = "Kazuma_Done2"
	},
	Kazuma_Done2 = {
		Text = `[Earned, not given.]<Style=Rainbow> That is what {nameTag("Soryu")} is. Keep it that way.`,
		Answers = true
	}
}