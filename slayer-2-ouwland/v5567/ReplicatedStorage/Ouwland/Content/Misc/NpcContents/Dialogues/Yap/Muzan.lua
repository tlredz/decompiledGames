local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local MuzanSettings = require(ReplicatedStorage.CAM.Global.MuzanSettings)
return {
	Muzan = {
		BeforeRun = function(_, _)
			local data = Utility.GetData(Players.LocalPlayer)

			if data == nil then
				return "Muzan_Dismiss"
			end

			if data.Race.Value == "Demon" then
				return "Muzan_Demon"
			end

			if data.Race.Value ~= "Human" then
				return "Muzan_Dismiss"
			end

			local reputation = data:FindFirstChild("Reputation")

			if reputation == nil or reputation.Value > MuzanSettings.EligibleReputation then
				return "Muzan_Dismiss"
			end

			if data.Inventory.Inventory:FindFirstChild("Biwa Bell") == nil then
				return
			else
				return "Muzan_HasBell"
			end
		end,
		Text = "[I have watched you since the day you drew your first breath into this rotten world.]<Style=Fade,Color=(.8,.7,1)>",
		Answers = true,
		IfTrue = "Muzan_2"
	},
	Muzan_2 = {
		Text = "Every kill. Every cruelty. [Every quiet step you've taken deeper into the dark, I was there, watching it bloom.]<Style=Fade,Color=(.8,.7,1)>",
		Answers = true,
		IfTrue = "Muzan_3"
	},
	Muzan_3 = {
		Text = "You were never meant for their world of [slayers]<Color=(1,.3,.3)> and hollow justice.",
		Answers = true,
		IfTrue = "Muzan_4"
	},
	Muzan_4 = {
		Text = "[Become a demon.]<Style=Fade,Color=(1,.3,.3)> Shed that fragile, dying shell and become [eternal.]<Style=Fade,Color=(.8,.7,1)>",
		Answers = true,
		IfTrue = "Muzan_5"
	},
	Muzan_5 = {
		Text = "Use this [\"Biwa Bell\"]<Color=(1,.85,.3)> to travel to my lair.",
		Answers = {
			["Not yet"] = "",
			["Take the bell"] = "MuzanGiveBell"
		}
	},
	Muzan_Dismiss = {
		Text = "[Get lost.]<Color=(1,.3,.3)>",
		Answers = true
	},
	Muzan_HasBell = {
		Text = "You already carry my gift. [Ring it when the night is deep.]<Style=Fade,Color=(.8,.7,1)>",
		Answers = true
	},
	Muzan_Demon = {
		Text = "You bear my blood already. [Do not waste it.]<Style=Fade,Color=(1,.3,.3)>",
		Answers = {
			["Give me a mission"] = "MuzanLair_DemonTask",
			["Not yet"] = ""
		}
	}
}