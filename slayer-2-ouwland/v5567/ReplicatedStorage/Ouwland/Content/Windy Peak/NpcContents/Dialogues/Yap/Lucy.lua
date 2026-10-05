local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag
return {
	Lucy = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill restock the pantry(Lv 10)") == "Doing" then
				return "Lucy_Delivery"
			end
		end,
		Text = "We're out of [meat]<Color=(1,.3,.3)>.",
		Answers = true,
		IfTrue = "Lucy_2"
	},
	Lucy_2 = {
		Text = "Could you help me restock the pantry?",
		Answers = true,
		IfTrue = "Lucy_3"
	},
	Lucy_3 = {
		Text = `Go see the hunter {nameTag("Tom")} in {nameTag("Bamboo Grove")} for some {nameTag("Bear Meat")}.`,
		Answers = {
			Close = "",
			["Ill restock the pantry(Lv 10)"] = "AddQuest"
		}
	},
	Lucy_Delivery = {
		Text = "Got any meat? The hunters by the bamboo say the [bears]<Color=(1,.3,.3)> out there carry plenty.",
		Answers = {
			Close = "",
			["Hand over the meat"] = "DeliverMeatToLucy"
		}
	},
	Lucy_Thanks = {
		Text = `Thank you… These {nameTag("Cooked Bear Meat")} restore health if you're in trouble.`,
		Answers = 1
	},
	Lucy_NoMeat = {
		Text = `That's... not meat. Come back when you've got some {nameTag("Bear Meat")} on you.`,
		Answers = true
	}
}