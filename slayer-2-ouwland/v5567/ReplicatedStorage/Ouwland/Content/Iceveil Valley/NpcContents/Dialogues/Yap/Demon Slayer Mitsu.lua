local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
return {
	["Demon Slayer Mitsu"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill drive back the frost(Lv 105)") == "Doing" then
				return "Mitsu_IceDoing"
			end

			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill put out the blaze(Lv 115)") == "Doing" then
				return "Mitsu_FireDoing"
			end
		end,
		Text = "Careful. You're already on their ground.",
		Answers = true,
		IfTrue = "Mitsu_2"
	},
	Mitsu_2 = {
		Text = "Neither kind runs at you. They stop, set their feet, and throw.",
		Answers = true,
		IfTrue = "Mitsu_3"
	},
	Mitsu_3 = {
		Text = "The [Ice Profound Demons]<Color=(.5,.8,1)> throw a bolt that bursts where it lands, and the cold sticks to you.",
		Answers = true,
		IfTrue = "Mitsu_4"
	},
	Mitsu_4 = {
		Text = "The [Fire Profound Demons]<Color=(1,.45,.2)> do the same thing with fire, and the burn sticks just as long.",
		Answers = true,
		IfTrue = "Mitsu_5"
	},
	Mitsu_5 = {
		Text = "When one stops to set its feet, that's your opening. Get in close before it throws.",
		Answers = true,
		IfTrue = "Mitsu_6"
	},
	Mitsu_6 = {
		Text = "The frost ones are everywhere up on this shelf. The burning ones are rarer, and a lot worse.",
		Answers = true,
		IfTrue = "Mitsu_7"
	},
	Mitsu_7 = {
		Text = "Nine of the frost ones, or eight of the burning. Pick whichever you think you can walk away from.",
		Answers = {
			Close = "",
			["Ill drive back the frost(Lv 105)"] = "AddQuest",
			["Ill put out the blaze(Lv 115)"] = "AddQuest"
		}
	},
	Mitsu_IceDoing = {
		Text = "Watch them wind up. Get inside it and there's nothing else they can do.",
		Answers = true
	},
	Mitsu_FireDoing = {
		Text = "There's fewer of them, but the burn sticks around. Don't stand where it lands.",
		Answers = true
	}
}