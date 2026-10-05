local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return {
	["Stonemason Tobei"] = {
		BeforeRun = function(_, _)
			local data = Utility.GetData(Players.LocalPlayer)

			if data ~= nil and data.Inventory.Inventory:FindFirstChild("Nightfall Gauntlet Schematic") ~= nil then
				return "Statues_Done"
			end

			local GauntletStatuesController = require(ReplicatedStorage.CAM.Client.Controllers.GauntletStatuesController)

			if GauntletStatuesController.Done() then
				return "Statues_Ready"
			end

			return nil
		end,
		Text = "Mind where you lean. Half this village is my father's stone, and it remembers who leaned on it.",
		Answers = true,
		IfTrue = "Statues_2"
	},
	Statues_2 = {
		Text = "He cut three warriors before he died. Never told a soul where he stood them, and never went back to look.",
		Answers = {
			["What were they for?"] = "Statues_3",
			Close = ""
		}
	},
	Statues_3 = {
		Text = "He said stone only wakes for the thing it was cut to remember. One remembers steel. One remembers breath. One remembers a bare hand.",
		Answers = {
			["Why?"] = "StatuesHeard",
			Close = ""
		}
	},
	Statues_4 = {
		Text = "I never asked him. Their eyes are shut, all three. I like to think they are waiting.",
		Answers = {
			Close = ""
		}
	},
	Statues_Ready = {
		Text = "Their eyes are open. All three. Then you are the one he cut them for.",
		Answers = {
			["Take the drawings"] = "GauntletTakeSchematic",
			["Not yet"] = ""
		}
	},
	Statues_Given = {
		Text = "He drew these the year he finished them. Take them to a smith, and he will know the rest.",
		Answers = {
			Close = ""
		}
	},
	Statues_Done = {
		Text = `You have the {Utility.NameTag("drawings")}. There is nothing else of his I can give you.`,
		Answers = {
			Close = ""
		}
	}
}