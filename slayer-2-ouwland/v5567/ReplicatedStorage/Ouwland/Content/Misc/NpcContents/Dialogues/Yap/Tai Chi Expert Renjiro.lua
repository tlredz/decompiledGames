local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag
return {
	["Tai Chi Expert Renjiro"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill learn the Tai Chi Style(Lv 65)") == "Doing" then
				local data = Utility.GetData(Players.LocalPlayer)
				local illlearntheTaiChiStyleLv65 = Quests.Holder["Ill learn the Tai Chi Style(Lv 65)"]
				local child

				if data ~= nil then
					child = illlearntheTaiChiStyleLv65 ~= nil and data.Quests.Holder:FindFirstChild(illlearntheTaiChiStyleLv65.QuestInstance.Name) or nil
				end

				local commonFish = child ~= nil and child.Tasks:FindFirstChild("Common Fish") or nil

				if commonFish == nil or not (commonFish.Value.Value < commonFish.Max.Value) then
					return "Renjiro_Doing"
				end

				return "Renjiro_DoingFish"
			else
				local data = Utility.GetData(Players.LocalPlayer)
				local value = data ~= nil and data.Powers.FightingStyle.Value or ""

				if value == "" then
					return
				elseif value == "Tai Chi" then
					return "Renjiro_Done"
				end

				return "Renjiro_HasStyle"
			end
		end,
		Text = "You came in loud. Everyone does, at first.",
		Answers = true,
		IfTrue = "Renjiro_2"
	},
	Renjiro_2 = {
		Text = `{nameTag("Tai Chi")} is not something I hand over. Earn it, and it will already be yours by the time I say so.`,
		Answers = {
			["Not yet"] = "",
			["Ill learn the Tai Chi Style(Lv 65)"] = "AddQuest"
		}
	},
	Renjiro_Doing = {
		Text = "Still forcing it. Come back when you stop.",
		Answers = true
	},
	Renjiro_DoingFish = {
		Text = "Still forcing it. Come back when you stop.",
		Answers = {
			["Ill hand over the catch"] = "RenjiroTakeCatch",
			["Not yet"] = ""
		}
	},
	Renjiro_Catch = {
		Text = "Set them down. I will keep the count.",
		Answers = true
	},
	Renjiro_NoCatch = {
		Text = "You brought nothing. Notice that before you walk in next time.",
		Answers = true
	},
	Renjiro_HasStyle = {
		Text = "You have a style already. Set it down before you ask for mine.",
		Answers = true
	},
	Renjiro_Done = {
		Text = "You finished. Quietly, which is the part that matters.",
		Answers = true,
		IfTrue = "Renjiro_Done2"
	},
	Renjiro_Done2 = {
		Text = `[Yield, then answer.]<Style=Rainbow> That is {nameTag("Tai Chi")}. Do not turn it into a hammer.`,
		Answers = true
	}
}