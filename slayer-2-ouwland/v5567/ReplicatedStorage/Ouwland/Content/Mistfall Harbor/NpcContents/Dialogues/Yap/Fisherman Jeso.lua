local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag
local Shop2

if RunService:IsClient() then
	Shop2 = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.Components.Shop)
end

local v = { "Worm" }
local FishermanJeso = {
	["Fisherman Jeso"] = {
		BeforeRun = function(_, _)
			local data = Utility.GetData(Players.LocalPlayer)

			if data ~= nil and data.Inventory.Inventory:FindFirstChild("Legendary Fishing Rod") ~= nil then
				return "Jeso_Successor"
			end

			local playerQuestState = Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill find the permit stamp(Lv 45)")

			if playerQuestState == "Done" then
				return "Jeso_Approved"
			elseif playerQuestState == "Doing" then
				return "Jeso_Waiting"
			end

			return nil
		end,
		Text = "Well now. Come to buy a rod off an old man, have you?",
		Answers = true,
		IfTrue = "Jeso_Regulations"
	},
	Jeso_Regulations = {
		Text = "I'd hand you one gladly, but the village won't have it. Permits, they want now. Paper, for water.",
		Answers = true,
		IfTrue = "Jeso_SendToSofen"
	},
	Jeso_SendToSofen = {
		Text = `Go see {nameTag("Dock Master Sofen")} about the stamp, and mind your manners with him. Then come back to me.`,
		Answers = 1
	},
	Jeso_Waiting = {
		Text = "No stamp on you yet, young one. These eyes are old, not blind.",
		Answers = true
	},
	Jeso_Approved = {
		Text = "There we are. Stamped and proper. Now the old man can do business with you.",
		Answers = {
			["The rods?"] = "Jeso_Price",
			["Got any bait?"] = "Jeso_BaitShopIntro",
			["Better bait than worms?"] = "Jeso_BaitTip",
			Farewell = ""
		}
	},
	Jeso_BaitShopIntro = {
		Text = "Worms. Dug them fresh this morning, so don't go turning your nose up.",
		Answers = true,
		IfTrue = "Jeso_BaitShop"
	}
}
local jeso_BaitShop = {
	OnShow = function(_, p)
		p.CartShopNode = "Jeso_BaitShop"
	end,
	Content = 0,
	Text = 0,
	Answers = 0
}
local content

if Shop2 ~= nil then
	content = Shop2(v) or nil
end

jeso_BaitShop.Content = content
jeso_BaitShop.Text = `Anything fancier is {nameTag("Baitmonger Nori")}'s trade.`
jeso_BaitShop.Answers = {
	["Buy the selection"] = "ReviewCartPurchase",
	["Who is Nori?"] = "Jeso_BaitTip",
	Farewell = ""
}
FishermanJeso.Jeso_BaitShop = jeso_BaitShop
FishermanJeso.Jeso_BaitTip = {
	Text = "Worms pull up weed and small fry, and plenty of both. The rare bites want better than a worm.",
	Answers = true,
	IfTrue = "Jeso_BaitTip2"
}
FishermanJeso.Jeso_BaitTip2 = {
	Text = function()
		if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill restock the infirmary(Lv 70)") == "Done" then
			return (`{nameTag("Baitmonger Nori")} keeps the proper stuff, up in {nameTag("Hidden Mist Village")}. He knows your name now.`)
		end

		return (`That'd be {nameTag("Baitmonger Nori")}'s trade, up the hill in {nameTag("Hidden Mist Village")}.`)
	end,
	Answers = true,
	IfTrue = "Jeso_BaitTip3"
}
FishermanJeso.Jeso_BaitTip3 = {
	Text = function()
		if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill restock the infirmary(Lv 70)") == "Done" then
			return "Better bait, fuller line. But the rod sets your ceiling, and don't let anyone tell you different."
		end

		return (`He'll not deal with strangers, mind. Do right by {nameTag("Shiori")} at the {nameTag("Butterfly Estate")} and word travels. It always does.`)
	end,
	Answers = {
		["Which bait for which rod?"] = "Jeso_Pairing",
		Farewell = ""
	}
}
FishermanJeso.Jeso_Pairing = {
	Text = "Sit a moment, this one's worth the hearing. Bait decides how often the line comes back full.",
	Answers = true,
	IfTrue = "Jeso_Pairing2"
}
FishermanJeso.Jeso_Pairing2 = {
	Text = "The rod decides what's on it.",
	Answers = true,
	IfTrue = "Jeso_Pairing2b"
}
FishermanJeso.Jeso_Pairing2b = {
	Text = `Rich bait on that {nameTag("Basic Fishing Rod")} will keep you hauling all day, and it'll be small fry all day.`,
	Answers = true,
	IfTrue = "Jeso_Pairing3"
}
FishermanJeso.Jeso_Pairing3 = {
	Text = `On the {nameTag("Rare Fishing Rod")}, now, a {nameTag("Fish Head")}. That's the rung where good bait starts paying you back.`,
	Answers = true,
	IfTrue = "Jeso_Pairing4"
}
FishermanJeso.Jeso_Pairing4 = {
	Text = `And the {nameTag("Golden Tentacle")} pulls the deep things up. Only the {nameTag("Legendary Fishing Rod")} will hold them.`,
	Answers = true,
	IfTrue = "Jeso_Pairing5"
}
FishermanJeso.Jeso_Pairing5 = {
	Text = "I watched a line go once, hands and all.",
	Answers = {
		Close = "",
		["Whose hands?"] = "Jeso_Isao"
	}
}
FishermanJeso.Jeso_Isao = {
	Text = "Ah. I'll not make a story out of a man's last day, young one.",
	Answers = true,
	IfTrue = "Jeso_Isao2"
}
FishermanJeso.Jeso_Isao2 = {
	Text = "He fished this harbor before I'd sold a single rod. Better than me.",
	Answers = true,
	IfTrue = "Jeso_Isao2b"
}
FishermanJeso.Jeso_Isao2b = {
	Text = `Better than {nameTag("Angler Runo")}, and Runo will not hear that said.`,
	Answers = true,
	IfTrue = "Jeso_Isao3"
}
FishermanJeso.Jeso_Isao3 = {
	Text = "And when I did open, line was the only thing he ever bought off me.",
	Answers = true,
	IfTrue = "Jeso_Isao3b"
}
FishermanJeso.Jeso_Isao3b = {
	Text = "Made his own hooks, his own lures, every piece of it.",
	Answers = true,
	IfTrue = "Jeso_Isao4"
}
FishermanJeso.Jeso_Isao4 = {
	Text = "And half those nights he'd hang none of it. Bare hook, bare line, hours of it.",
	Answers = true,
	IfTrue = "Jeso_Isao4b"
}
FishermanJeso.Jeso_Isao4b = {
	Text = "Said bait was for men who wanted the fish.",
	Answers = true,
	IfTrue = "Jeso_Isao5"
}
FishermanJeso.Jeso_Isao5 = {
	Text = "Every fisherman's got his nonsense, and his was counting.",
	Answers = true,
	IfTrue = "Jeso_Isao5b"
}
FishermanJeso.Jeso_Isao5b = {
	Text = "Five casts in one spot, never a sixth. Said the sixth was greed.",
	Answers = true,
	IfTrue = "Jeso_Isao6"
}
FishermanJeso.Jeso_Isao6 = {
	Text = "Something took his line one night, and he would not let go of it. That's the whole of it.",
	Answers = true,
	IfTrue = "Jeso_Isao7"
}
FishermanJeso.Jeso_Isao7 = {
	Text = "And I'll not have you out on that water hunting whatever it was. Buy a worm and be sensible.",
	Answers = true
}
FishermanJeso.Jeso_Successor = {
	Text = "Well now. That rod worked this water before I had a shop, and I'd still know it anywhere.",
	Answers = {
		["You know it?"] = "Jeso_Successor2",
		["Got any bait?"] = "Jeso_BaitShopIntro",
		Farewell = ""
	}
}
FishermanJeso.Jeso_Successor2 = {
	Text = "His own make, handle to hook. Once I opened, the only thing he ever took off my shelf was line for it.",
	Answers = true,
	IfTrue = "Jeso_Successor3"
}
FishermanJeso.Jeso_Successor3 = {
	Text = "I'll not make a story of him this time either. But he'd be glad it came up, and gladder who has it.",
	Answers = true
}
FishermanJeso.Jeso_Price = {
	Text = `The basic one runs [3,500]<Color=(1,1,1)> [#]<img={BunchaIcons.WenRaw}>. Honest price, and I'll not budge on it.`,
	Answers = true,
	IfTrue = "Jeso_RarePitch"
}
FishermanJeso.Jeso_RarePitch = {
	Text = "The rare rod I'll not sell for coin. Any fool can buy a rod. Not every fool can fish.",
	Answers = true,
	IfTrue = "Jeso_RarePrice"
}
FishermanJeso.Jeso_RarePrice = {
	Text = function()
		return (`Land me {Shop.GetPrice("Rare Fishing Rod", true)}, and she's yours. No haggling with an old man.`)
	end,
	Answers = 1
}
FishermanJeso.Jeso_PurchaseSuccess = {
	Text = "She'll serve you well. Mind the line, and don't yank her.",
	Answers = 1
}
FishermanJeso.Jeso_PurchaseFail = {
	Text = "Come back when the purse is heavier, young one. I'm not going anywhere.",
	Answers = true
}
FishermanJeso.Jeso_RarePurchaseSuccess = {
	Text = `{nameTag("Golden Fish")} on my counter at last. You've earned her, young one.`,
	Answers = 1
}
FishermanJeso.Jeso_RarePurchaseFail = {
	Text = function()
		return (`Not yet. {Shop.GetPrice("Rare Fishing Rod", true)}, and not a fish less. I've waited longer than you have.`)
	end,
	Answers = true
}
return FishermanJeso