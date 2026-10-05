local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag
return {
	Betty = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill look for it(Lv 10)") == "Doing" then
				return "Betty_Doing"
			end

			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill look for it(Lv 10)") == "Done" then
				return "Betty_Done"
			end
		end,
		Text = "Oh no... this is terrible!",
		Answers = true,
		IfTrue = "Betty_2"
	},
	Betty_2 = {
		Text = `My favorite {nameTag("gemstone")} slipped from my pocket and fell into the [river below]<Color=(.4,.85,1)>.`,
		Answers = true,
		IfTrue = "Betty_3"
	},
	Betty_3 = {
		Text = "Could you help me look for it?",
		Answers = {
			Close = "",
			["Ill look for it(Lv 10)"] = "AddQuest"
		}
	},
	Betty_Doing = {
		Text = "Did you find it yet? It's small, but it's shiny!",
		Answers = true
	},
	Betty_Done = {
		Text = `My {nameTag("gemstone")} is back where it belongs, and it's staying in my pocket this time. Thank you!`,
		Answers = true
	}
}