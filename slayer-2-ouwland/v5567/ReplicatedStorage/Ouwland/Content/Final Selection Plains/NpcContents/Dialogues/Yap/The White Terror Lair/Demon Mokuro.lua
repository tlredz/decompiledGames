local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
return {
	["Demon Mokuro"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill break their watch(Lv 75)") == "Doing" then
				return "Mokuro_Doing"
			end
		end,
		Text = "There's a Corps watch camped at the mouth of this cave. [Mizunoe]<Color=(.7,.8,.95)> rank.",
		Answers = true,
		IfTrue = "Mokuro_1b"
	},
	Mokuro_1b = {
		Text = "One rung up from the bottom, and the first the Corps trusts out on its own.",
		Answers = true,
		IfTrue = "Mokuro_2"
	},
	Mokuro_2 = {
		Text = "They camp a little deeper in every week. Nobody's given them a reason to stop.",
		Answers = true,
		IfTrue = "Mokuro_3"
	},
	Mokuro_3 = {
		Text = "If you go down there, they won't wait for you to swing first.",
		Answers = true,
		IfTrue = "Mokuro_3b"
	},
	Mokuro_3b = {
		Text = "And they all drill the same palm strike. Take it square and it puts you flat on the ground.",
		Answers = true,
		IfTrue = "Mokuro_4"
	},
	Mokuro_4 = {
		Text = "Past the palm, they're not all alike.",
		Answers = true,
		IfTrue = "Mokuro_4b"
	},
	Mokuro_4b = {
		Text = "Each one has a technique of their own, so don't assume the second fight will go like the first.",
		Answers = true,
		IfTrue = "Mokuro_5"
	},
	Mokuro_5 = {
		Text = "Kill six of them. It won't end the watch, but it'll push it back out of the cave for a while.",
		Answers = {
			Close = "",
			["Ill break their watch(Lv 75)"] = "AddQuest"
		}
	},
	Mokuro_Doing = {
		Text = "Watch for the palm. The rest of what they do varies, but that strike is on every one of them.",
		Answers = true
	}
}