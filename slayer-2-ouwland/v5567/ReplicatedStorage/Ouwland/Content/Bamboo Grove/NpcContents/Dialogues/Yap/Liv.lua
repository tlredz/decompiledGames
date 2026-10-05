local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
return {
	Liv = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill look for the penny(Lv 14)") == "Doing" then
				return "Liv_PennyDoing"
			end

			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill find the coins(Lv 21)") == "Doing" then
				return "Liv_CoinsDoing"
			end

			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill find the coins(Lv 21)") == "Done" then
				return "Liv_AllDone"
			end

			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill look for the penny(Lv 14)") == "Done" then
				return "Liv_Coins"
			end
		end,
		Text = "Hey there! You look like you've got sharp eyes.",
		Answers = true,
		IfTrue = "Liv_2"
	},
	Liv_2 = {
		Text = "I dropped my [lucky penny]<Color=(1,.85,.3)> somewhere around here, and I can't find it anywhere.",
		Answers = true,
		IfTrue = "Liv_3"
	},
	Liv_3 = {
		Text = "Could you look around for it? I'll make it worth your while.",
		Answers = {
			Close = "",
			["Ill look for the penny(Lv 14)"] = "AddQuest"
		}
	},
	Liv_PennyDoing = {
		Text = "Any luck? It's small, but it's [shiny!]<Color=(1,.85,.3)>",
		Answers = true
	},
	Liv_Coins = {
		Text = "Alright... you're good at finding things. I've got a much bigger job for you.",
		Answers = true,
		IfTrue = "Liv_Coins2"
	},
	Liv_Coins2 = {
		Text = "I've been flipping coins under this tree all day. I never pick up the losers.",
		Answers = true,
		IfTrue = "Liv_Coins3"
	},
	Liv_Coins3 = {
		Text = "My whole fortune's sitting in the dirt around us.",
		Answers = true,
		IfTrue = "Liv_Coins4"
	},
	Liv_Coins4 = {
		Text = "Gather up [500 pennies]<Color=(1,.85,.3)>. Yeah, [five hundred.]<Style=Fade,Color=(1,.85,.3)> They're all around here!",
		Answers = {
			Close = "",
			["Ill find the coins(Lv 21)"] = "AddQuest"
		}
	},
	Liv_CoinsDoing = {
		Text = "Keep at it! They're all around this tree. Stare at the dirt till you spot one!",
		Answers = true
	},
	Liv_AllDone = {
		Text = "My pockets are heavy again, and it's all thanks to you. Feeling lucky yourself?",
		Answers = {
			Close = "",
			["Lets gamble"] = "Liv_Gamble"
		}
	},
	Liv_Gamble = {
		Text = `One flip, [ALL]<Color=(1,.3,.3)> your [#]<img={BunchaIcons.WenRaw}>. Heads, you get [1.5x]<Color=(1,.85,.3)>. Tails, I keep it all. Deal?`,
		Answers = {
			Nevermind = "",
			["Flip it"] = "LivGamble"
		}
	},
	Liv_GambleBroke = {
		Text = "You've got nothing to gamble, kid. Come back when your pockets jingle.",
		Answers = true
	}
}