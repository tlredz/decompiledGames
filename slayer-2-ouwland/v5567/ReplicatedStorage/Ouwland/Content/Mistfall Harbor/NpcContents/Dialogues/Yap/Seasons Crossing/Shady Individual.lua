local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return {
	["Shady Individual Rooyi"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill eliminate the Mizunoto(Lv 62)") == "Doing" then
				return "Shady Individual_Doing"
			end
		end,
		Text = "The Demon King has taken notice of five promising Mizunoto Demon Slayers.",
		Answers = true,
		IfTrue = "Shady Individual_2"
	},
	["Shady Individual_2"] = {
		Text = "They survived encounters that should have killed them.",
		Answers = true,
		IfTrue = "Shady Individual_3"
	},
	["Shady Individual_3"] = {
		Text = "Before they grow stronger, they must be [eliminated.]<Style=Fade,Color=(1,.3,.3)>",
		Answers = {
			Close = "",
			["Ill eliminate the Mizunoto(Lv 62)"] = "AddQuest"
		}
	},
	["Shady Individual_Doing"] = {
		Text = "Have you gotten rid of the threat yet?",
		Answers = {
			Close = "",
			["Hand over the katanas"] = "DeliverKatanasToRooyi"
		}
	},
	["Shady Individual_Thanks"] = {
		Text = "Good job. I see why you were acknowledged.",
		Answers = true
	},
	["Shady Individual_NotEnough"] = {
		Text = `Five broken blades. Bring me every {Utility.NameTag("Broken Nichirin Katana")} they carry.`,
		Answers = true
	}
}