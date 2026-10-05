local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local MuzanSettings = require(ReplicatedStorage.CAM.Global.MuzanSettings)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local EvilArtSpinning

if RunService:IsClient() then
	EvilArtSpinning = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.Components.EvilArtSpinning)
end

local Shop

if RunService:IsClient() then
	Shop = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.Components.Shop)
end

local SpinsCounter

if RunService:IsClient() then
	SpinsCounter = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.Components.SpinsCounter)
end

local Spinners = require(ReplicatedStorage.CAM.Global.Spinners)
local v = {}

for _, v2 in Spinners.EvilArt.Pool() do
	table.insert(v, (`{v2} Orb`))
end

local v2 = math.round((Spinners.EvilArt.Odds().Nothing or 0) * 100)

local function fireAssign()
	local localPlayer = Players.LocalPlayer
	local data = Utility.GetData(localPlayer)

	if data == nil or data.Race.Value ~= "Human" or localPlayer:GetAttribute(MuzanSettings.LairAttribute) ~= true or data.Inventory.Inventory:FindFirstChild("Muzan's Blood") ~= nil then
		return
	end

	if Quests.GetPlayerQuestState(localPlayer, "Muzan Quest") == "Doing" then
		return
	end

	SignalEvent.ToServer("MuzanLairAssign")
end

local MuzanLair = {
	MuzanLair = {
		BeforeRun = function(_, _)
			local data = Utility.GetData(Players.LocalPlayer)

			if data == nil then
				return "MuzanLair_Dismiss"
			end

			if data.Race.Value == "Demon" or data.Race.Value == "Hybrid" then
				return "MuzanLair_Demon"
			end

			if data.Race.Value ~= "Human" then
				return "MuzanLair_Dismiss"
			end

			if data.Inventory.Inventory:FindFirstChild("Muzan's Blood") ~= nil then
				return "MuzanLair_Drink"
			end

			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Muzan Quest") == "Doing" then
				return "MuzanLair_Busy"
			end
		end,
		OnShow = function(_, _)
			fireAssign()
		end,
		Text = "[So. You made it to me.]<Style=Fade,Color=(.8,.7,1)>",
		Answers = true,
		IfTrue = "MuzanLair_2"
	},
	MuzanLair_2 = {
		Text = "You rang that bell [like it means something.]<Style=Fade,Color=(.8,.7,1)>",
		Answers = true,
		IfTrue = "MuzanLair_3"
	},
	MuzanLair_3 = {
		Text = "Prove you're worth more than [the rest who've knelt here and failed.]<Style=Fade,Color=(1,.3,.3)>",
		Answers = true
	},
	MuzanLair_Busy = {
		Text = "[Finish your task.]<Color=(1,.3,.3)>",
		Answers = true
	},
	MuzanLair_Drink = {
		Text = "You have what you need. [Drink, and shed that fragile, dying shell for good.]<Style=Fade,Color=(.8,.7,1)>",
		Answers = true
	},
	MuzanLair_Demon = {
		Text = "...",
		Answers = {
			["Give me your power"] = "MuzanLair_DemonPower",
			["Give me a task"] = "MuzanLair_DemonTask"
		}
	},
	MuzanLair_DemonPower = {
		Content = EvilArtSpinning,
		Text = `[You have {v2}% chance of rolling nothing, and {100 - v2}% chance of rolling a random Evil Art, good luck.]<Style=Fade,Color=(.8,.7,1)>`,
		Answers = {
			["I don't want to roll"] = "MuzanLair_DemonBuy",
			Farewell = ""
		}
	}
}
local muzanLair_DemonBuy = {
	OnShow = function(_, p)
		p.CartShopNode = "MuzanLair_DemonBuy"
	end,
	Content = 0,
	Text = "…",
	Answers = 0
}
local content

if Shop ~= nil then
	content = Shop(v, {
		Counter = SpinsCounter,
		Single = true
	})
end

muzanLair_DemonBuy.Content = content
muzanLair_DemonBuy.Answers = {
	["Buy the selection"] = "ReviewCartPurchase",
	Back = "MuzanLair_DemonPower",
	Farewell = ""
}
MuzanLair.MuzanLair_DemonBuy = muzanLair_DemonBuy
MuzanLair.MuzanLair_DemonTask = {
	Text = "Slayers grow bold when I'm not watching. [Go remind them why they should be afraid.]<Style=Fade,Color=(1,.3,.3)>",
	Answers = {
		Cancel = ""
	},
	Content = function(p, p2, p3, p4)
		local Quests2 = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.Components.Quests)
		return Quests2(p, p2, p3, p4, "MuzanLair_DemonTask_Denied")
	end
}
MuzanLair.MuzanLair_DemonTask_Denied = {
	Text = function(_, p)
		local huntDenial = p ~= nil and p.HuntDenial or {}

		if huntDenial.Blocking ~= nil and huntDenial.Reason == false then
			return (`You are already bound to {Utility.NameTag(huntDenial.Blocking)}. [Finish it.]<Color=(1,.3,.3)>`)
		end

		if huntDenial.Reason == true then
			return "[Patience. I will not repeat myself so soon.]<Style=Fade,Color=(1,.3,.3)>"
		end

		if huntDenial.Reason == 1 then
			return "That one is already yours. [Go and finish it.]<Color=(1,.3,.3)>"
		end

		return "[That one is not for you.]<Style=Fade,Color=(1,.3,.3)>"
	end,
	Answers = true,
	IfTrue = "MuzanLair_DemonTask",
	ContinueContent = true,
	ContinueIcon = true
}
MuzanLair.MuzanLair_Dismiss = {
	Text = "[Get lost.]<Color=(1,.3,.3)>",
	Answers = true
}
return MuzanLair