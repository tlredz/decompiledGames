local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag

local function hasNote()
	local data = Utility.GetData(Players.LocalPlayer)
	return data ~= nil and data.Inventory.Inventory:FindFirstChild("Suspicious Note") ~= nil
end

return {
	Kazu = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill help clear them out") == "Doing" then
				return "Kazu_Doing"
			end

			local data = Utility.GetData(Players.LocalPlayer)
			local v

			if data == nil then
				v = false
			else
				v = data.Inventory.Inventory:FindFirstChild("Suspicious Note") ~= nil
			end

			if not v then
				return
			end

			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill bring him the notes") == "None" then
				return "Kazu_Done"
			end

			return "Kazu_Nudge"
		end,
		Text = "We've got people acting strange around the village. I don't trust them.",
		Answers = true,
		IfTrue = "Kazu_2"
	},
	Kazu_2 = {
		Text = "Help me clear out a few of these [\"villagers.\"]<Style=Fade,Color=(1,.3,.3)>",
		Answers = {
			Close = "",
			["Ill help clear them out"] = "AddQuest"
		}
	},
	Kazu_Doing = {
		Text = "Have you cleared out those [\"villagers\"]<Color=(1,.3,.3)> yet?",
		Answers = true
	},
	Kazu_Done = {
		Text = "You see this? These notes...",
		Answers = true,
		IfTrue = "Kazu_Done2"
	},
	Kazu_Done2 = {
		Text = "They're not random. I can't decode it all, but someone is giving orders.",
		Answers = true,
		IfTrue = "Kazu_Done3"
	},
	Kazu_Done3 = {
		Text = `Take them to {nameTag("Noote")}, the chief's nephew. Codes are his thing.`,
		Answers = {
			Close = "",
			["Ill bring him the notes"] = "AddQuest"
		}
	},
	Kazu_Nudge = {
		Text = `You're still carrying those notes. {nameTag("Noote")} is the one who can read them.`,
		Answers = true
	}
}