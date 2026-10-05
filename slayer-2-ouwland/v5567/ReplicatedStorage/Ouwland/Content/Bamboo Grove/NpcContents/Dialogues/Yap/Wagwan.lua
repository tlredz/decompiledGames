local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag
return {
	Wagwan = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "I will take care of Hoyuzo(Lv 50)") == "Doing" then
				return "Wagwan_HoyuzoDoing"
			end

			if Quests.GetPlayerQuestState(Players.LocalPlayer, "I will clear out his guards(Lv 40)") == "Doing" then
				return "Wagwan_SubsDoing"
			end
		end,
		Text = `Ohh, my {nameTag("ring")}... I lost it in that [cave]<Color=(1,.3,.3)> over there, and I'm too scared to go in.`,
		Answers = true,
		IfTrue = "Wagwan_2"
	},
	Wagwan_2 = {
		Text = `They say a [bad man]<Color=(1,.3,.3)> named {nameTag("Hoyuzo")} lives in there... along with his goons.`,
		Answers = true,
		IfTrue = "Wagwan_3"
	},
	Wagwan_3 = {
		Text = "Make that cave safe and I'll go find the ring myself.",
		Answers = true,
		IfTrue = "Wagwan_4"
	},
	Wagwan_4 = {
		Text = "Do this for me, and I'll make it worth your while.",
		Answers = {
			Close = "",
			["I will clear out his guards(Lv 40)"] = "AddQuest",
			["I will take care of Hoyuzo(Lv 50)"] = "AddQuest"
		}
	},
	Wagwan_HoyuzoDoing = {
		Text = "Is he gone yet...? I won't set foot near that cave while [Hoyuzo]<Color=(1,.3,.3)> still breathes.",
		Answers = true
	},
	Wagwan_SubsDoing = {
		Text = "His [goons]<Color=(1,.3,.3)> still guard that cave. Thin them out before they gang up on you.",
		Answers = true
	}
}