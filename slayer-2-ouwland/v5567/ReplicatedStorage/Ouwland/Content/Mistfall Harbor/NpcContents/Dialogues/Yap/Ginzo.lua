local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Sell

if RunService:IsClient() then
	Sell = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.Components.Sell)
end

local Shop2

if RunService:IsClient() then
	Shop2 = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.Components.Shop)
end

local content

if Sell ~= nil then
	content = Sell() or nil
end

local Ginzo = {
	Ginzo = {
		BeforeRun = function(_, _)
			local playerQuestState = Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill find the jewelry box(Lv 45)")

			if playerQuestState == "Done" then
				return "Ginzo_Sell"
			end

			if playerQuestState ~= "Doing" then
				return
			end

			local data = Utility.GetData(Players.LocalPlayer)

			if data == nil or data.Inventory.Inventory:FindFirstChild("Jewelry Box") == nil then
				return "Ginzo_Waiting"
			end

			return "Ginzo_Return"
		end,
		Text = "I'll buy whatever you're selling, human or otherwise. Business is business.",
		Answers = true,
		IfTrue = "Ginzo_Offer"
	},
	Ginzo_Offer = {
		Text = "But first, retrieve my Jewelry Box from my home in the Village Hidden in the Mist.",
		Answers = true,
		IfTrue = "Ginzo_Offer2"
	},
	Ginzo_Offer2 = {
		Text = "Bring it back, and we'll talk.",
		Answers = {
			Close = "",
			["Ill find the jewelry box(Lv 45)"] = "AddQuest"
		}
	},
	Ginzo_Waiting = {
		Text = "Well? Where's my box?",
		Answers = true
	},
	Ginzo_Return = {
		Text = "That's it. That's my box.",
		Answers = {
			Close = "",
			["Hand over the jewelry box"] = "DeliverJewelryBoxToGinzo"
		}
	},
	Ginzo_Thanks = {
		Text = "Excellent. That's exactly what I was looking for.",
		Answers = true,
		IfTrue = "Ginzo_Thanks2"
	},
	Ginzo_Thanks2 = {
		Text = "A deal is a deal.",
		Answers = 1
	},
	Ginzo_NoBox = {
		Text = "You're not carrying my box.",
		Answers = true
	},
	Ginzo_Sell = {
		Content = content,
		Text = "I'll buy whatever you sell.",
		Answers = {
			["Sell the selection"] = "GinzoReview",
			["Show me your stock"] = "Ginzo_Buy",
			Farewell = "Ginzo_Bye"
		}
	}
}
local ginzo_Buy = {
	OnShow = function(_, p)
		p.CartShopNode = "Ginzo_Buy"
	end,
	Content = 0,
	Text = "Scrap and thread. Every forge wants both, and nobody wants to go digging for them.",
	Answers = 0
}
local content2

if Shop2 ~= nil then
	content2 = Shop2({ "Metal Scraps", "Silk Thread" }) or nil
end

ginzo_Buy.Content = content2
ginzo_Buy.Answers = {
	["Buy the selection"] = "ReviewCartPurchase",
	Back = "Ginzo_Sell",
	Farewell = "Ginzo_Bye"
}
Ginzo.Ginzo_Buy = ginzo_Buy
Ginzo.Ginzo_Confirm = {
	Text = function(_, p)
		local sellTotals, v4 = Shop.GetSellTotals(p.SellSelection)
		p.SellTotals = sellTotals
		return (`{v4} piece(s) then. I will give you {Shop.FormatSellTotalsTextPlus(sellTotals)} for the lot. Deal?`)
	end,
	Answers = {
		Deal = "GinzoSell",
		["Let me look again"] = "Ginzo_Sell"
	}
}
Ginzo.Ginzo_Sold = {
	Text = function(_, p)
		return (`A pleasure. {Shop.FormatSellTotalsTextPlus(p.SoldFor or {})}, as promised.`)
	end,
	Answers = {
		["Sell more"] = "Ginzo_Sell",
		Close = ""
	}
}
Ginzo.Ginzo_Nothing = {
	Text = "You have not picked anything out yet.",
	Answers = true,
	IfTrue = "Ginzo_Sell"
}
Ginzo.Ginzo_NoSale = {
	Text = "Hm. Nothing there I can pay for.",
	Answers = true,
	IfTrue = "Ginzo_Sell"
}
Ginzo.Ginzo_Bye = {
	Text = "Come back when your pockets are heavier.",
	Answers = 1
}
return Ginzo