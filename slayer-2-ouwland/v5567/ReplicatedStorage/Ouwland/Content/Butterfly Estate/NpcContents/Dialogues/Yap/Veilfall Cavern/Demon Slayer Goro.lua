local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
return {
	["Demon Slayer Goro"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill thin them out(Lv 75)") == "Doing" then
				return "Goro_LesserDoing"
			end

			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill go up after the greater ones(Lv 83)") == "Doing" then
				return "Goro_GreaterDoing"
			end
		end,
		Text = "The cavern behind this fall is crawling with demons.",
		Answers = true,
		IfTrue = "Goro_1b"
	},
	Goro_1b = {
		Text = "Two kinds, and I can't tell you exactly what either one will throw at you.",
		Answers = true,
		IfTrue = "Goro_2"
	},
	Goro_2 = {
		Text = "That's not for lack of looking.",
		Answers = true,
		IfTrue = "Goro_2b"
	},
	Goro_2b = {
		Text = "Every demon down there grew its own blood art in the dark. No two of them fight the same way.",
		Answers = true,
		IfTrue = "Goro_3"
	},
	Goro_3 = {
		Text = "The [Lesser Demons]<Color=(1,.4,.4)> keep to the floor. One art apiece.",
		Answers = true,
		IfTrue = "Goro_3b"
	},
	Goro_3b = {
		Text = "Once one has shown you its trick, you've seen everything it has.",
		Answers = true,
		IfTrue = "Goro_4"
	},
	Goro_4 = {
		Text = "The [Greater Demons]<Color=(.9,.3,.6)> hold the ledges.",
		Answers = true,
		IfTrue = "Goro_4b"
	},
	Goro_4b = {
		Text = "They carry two arts each, so don't relax just because you lived through the first one.",
		Answers = true,
		IfTrue = "Goro_5"
	},
	Goro_5 = {
		Text = "One more thing. The lessers are there to keep you off the ledges.",
		Answers = true,
		IfTrue = "Goro_5b"
	},
	Goro_5b = {
		Text = "They'll mob anything that steps inside.",
		Answers = true,
		IfTrue = "Goro_5c"
	},
	Goro_5c = {
		Text = "The greaters come down one at a time, but each one is a harder fight.",
		Answers = true,
		IfTrue = "Goro_6"
	},
	Goro_6 = {
		Text = "Six of the lessers, or seven of the greaters. If you've never been inside, start on the floor.",
		Answers = {
			Close = "",
			["Ill thin them out(Lv 75)"] = "AddQuest",
			["Ill go up after the greater ones(Lv 83)"] = "AddQuest"
		}
	},
	Goro_LesserDoing = {
		Text = "Watch your back on the floor. The lessers don't take turns.",
		Answers = true
	},
	Goro_GreaterDoing = {
		Text = "Only one greater will come at you at a time.",
		Answers = true,
		IfTrue = "Goro_GreaterDoing2"
	},
	Goro_GreaterDoing2 = {
		Text = "Once it's shown you both of its arts, it has nothing left to surprise you with.",
		Answers = true
	}
}