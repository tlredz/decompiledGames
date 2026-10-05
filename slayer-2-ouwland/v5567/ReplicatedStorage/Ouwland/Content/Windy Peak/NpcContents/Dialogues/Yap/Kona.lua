local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)

local function hasBook()
	local data = Utility.GetData(Players.LocalPlayer)
	return data ~= nil and data.Inventory.Inventory:FindFirstChild("Book of Guidance") ~= nil
end

return {
	Kona = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill find the pages") == "Doing" then
				return "Kona_Doing"
			end

			local data = Utility.GetData(Players.LocalPlayer)
			local v

			if data == nil then
				v = false
			else
				v = data.Inventory.Inventory:FindFirstChild("Book of Guidance") ~= nil
			end

			if v then
				return "Kona_HasBook"
			end
		end,
		Text = "Ah, there you are.",
		Answers = true,
		IfTrue = "Kona_2"
	},
	Kona_2 = {
		Text = "A gust of wind tore through the village and scattered pages from an old book.",
		Answers = true,
		IfTrue = "Kona_3"
	},
	Kona_3 = {
		Text = "I've searched where I could, but some of the pages are still missing.",
		Answers = true,
		IfTrue = "Kona_4"
	},
	Kona_4 = {
		Text = "Could you help me find them?",
		Answers = true,
		IfTrue = "Kona_5"
	},
	Kona_5 = {
		Text = "Bring back [every page]<Color=(1,.85,.3)> you can recover.",
		Answers = true,
		IfTrue = "Kona_6"
	},
	Kona_6 = {
		Text = "They look like ordinary scraps, but they're [far more important than they seem.]<Style=Fade,Color=(.8,.7,1)>",
		Answers = {
			Close = "",
			["Ill find the pages"] = "AddQuest"
		}
	},
	Kona_Doing = {
		Text = "Please make haste.",
		Answers = true
	},
	Kona_HasBook = {
		Text = `The {Utility.NameTag("Book of Guidance")} is in good hands. Continue the journey it records.`,
		Answers = true
	}
}