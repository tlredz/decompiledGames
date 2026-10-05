local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Blacksmith

if RunService:IsClient() then
	Blacksmith = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.Components.Blacksmith)
end

local Exchange

if RunService:IsClient() then
	Exchange = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.Components.Exchange)
end

local content

if Blacksmith ~= nil then
	content = Blacksmith({
		Station = "Ouwland"
	}) or nil
end

local content2

if Exchange ~= nil then
	content2 = Exchange() or nil
end

return {
	["Blacksmith Togane"] = {
		Content = content,
		Text = "Mind the slag. Show me what you've brought.",
		Answers = {
			["Your other forge"] = "Togane_Pattern",
			["The climb"] = "Togane_Climb",
			["The set drawings"] = "Togane_Sets",
			["Swap materials"] = "Togane_Exchange",
			Farewell = ""
		}
	},
	Togane_Exchange = {
		Content = content2,
		Text = "Any of the six for any other, one for one. Pick both sides.",
		Answers = {
			["Make the exchange"] = "ToganeExchangeReview",
			Back = "Blacksmith Togane",
			Farewell = ""
		}
	},
	Togane_ExchangeNothing = {
		Text = "Pick what you're giving and what you want first.",
		Answers = true,
		IfTrue = "Togane_Exchange"
	},
	Togane_ExchangeConfirm = {
		Text = function(_, p)
			local exchange = p.Exchange
			return (`{exchange.Amount} {Utility.NameTag(exchange.Give)} for {exchange.Amount} {Utility.NameTag(exchange.Take)}. Fair enough?`)
		end,
		Answers = {
			Deal = "ToganeExchange",
			["Let me look again"] = "Togane_Exchange"
		}
	},
	Togane_ExchangeDone = {
		Text = "There. Weighed it out even, which is rare for me.",
		Answers = {
			["Swap more"] = "Togane_Exchange",
			Back = "Blacksmith Togane",
			Farewell = ""
		}
	},
	Togane_ExchangeFail = {
		Text = "That's more than you're carrying. Count again.",
		Answers = true,
		IfTrue = "Togane_Exchange"
	},
	Togane_Sets = {
		Text = "Bring me a whole set of drawings and I'll draw the last two myself.",
		Answers = {
			Firstlight = "SeriesCapstoneFirstlight",
			Nightfall = "SeriesCapstoneNightfall",
			Back = "Blacksmith Togane"
		}
	},
	Togane_SetsMissing = {
		Text = "You're a drawing or two short. Come back with the lot.",
		Answers = {
			Back = "Blacksmith Togane",
			Farewell = ""
		}
	},
	Togane_SetsGiven = {
		Text = "There. The top and the bottom, drawn to match the rest.",
		Answers = {
			Back = "Blacksmith Togane",
			Farewell = ""
		}
	},
	Togane_SetsDone = {
		Text = "You've had those two off me already. Go and cut them.",
		Answers = {
			Back = "Blacksmith Togane",
			Farewell = ""
		}
	},
	Togane_Pattern = {
		BeforeRun = function()
			local playerQuestState = Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill find the forge(Lv 65)")

			if playerQuestState == "Done" then
				return "Togane_PatternDone"
			elseif playerQuestState == "Doing" then
				return "Togane_PatternDoing"
			end
		end,
		Text = "Up in [Ouwigahara]<Color=(.8,.7,1)>. Bring a blade you own and it goes up a tier.",
		Answers = true,
		IfTrue = "Togane_Pattern2"
	},
	Togane_Pattern2 = {
		Text = "Trouble is the portal past the plains. Shut for years. Go and open it.",
		Answers = {
			["Ill find the forge(Lv 65)"] = "AddQuest",
			Back = "Blacksmith Togane",
			Farewell = ""
		}
	},
	Togane_PatternDoing = {
		Text = "Still here? It's past the plains. Go on.",
		Answers = {
			Back = "Blacksmith Togane",
			Farewell = ""
		}
	},
	Togane_PatternDone = {
		Text = "You got it open. Come and find me up there.",
		Answers = {
			Back = "Blacksmith Togane",
			Farewell = ""
		}
	},
	Togane_Climb = {
		Text = "I managed forty floors once. My knees still bring it up.",
		Answers = true,
		IfTrue = "Togane_Climb2"
	},
	Togane_Climb2 = {
		Text = "Knew a man who did ninety. He came back different.",
		Answers = {
			Back = "Blacksmith Togane",
			Farewell = ""
		}
	}
}