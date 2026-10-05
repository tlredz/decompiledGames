local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shop

if RunService:IsClient() then
	Shop = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.Components.Shop)
end

local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local nameTag = Utility.NameTag
local v = {
	"Worm",
	"Fish Head",
	"Golden Tentacle x10",
	"Golden Tentacle x75"
}
local BaitmongerNori = {
	["Baitmonger Nori"] = {
		BeforeRun = function(_, _)
			if Quests.GetPlayerQuestState(Players.LocalPlayer, "Ill restock the infirmary(Lv 70)") == "Done" then
				return "Nori_Unlocked"
			end

			return nil
		end,
		Text = "Don't know you. Don't sell to strangers.",
		Answers = true,
		IfTrue = "Nori_Locked2"
	},
	Nori_Locked2 = {
		Text = `Word travels, though. {nameTag("Shiori")} at {nameTag("Butterfly Estate")} is short on medicine.`,
		Answers = true,
		IfTrue = "Nori_Locked3"
	},
	Nori_Locked3 = {
		Text = "Help her, and I'll know your name by the time you're back.",
		Answers = true
	},
	Nori_Unlocked = {
		Text = `Heard what you did for {nameTag("Shiori")}. That's good enough for me.`,
		Answers = true,
		IfTrue = "Nori_Shop"
	}
}
local nori_Shop = {
	OnShow = function(_, p)
		p.CartShopNode = "Nori_Shop"
	end,
	Content = 0,
	Text = "Bait for every depth. Take your pick.",
	Answers = 0
}
local content

if Shop ~= nil then
	content = Shop(v) or nil
end

nori_Shop.Content = content
nori_Shop.Answers = {
	["Buy the selection"] = "ReviewCartPurchase",
	["What's the Golden Tentacle?"] = "Nori_Tentacle",
	Farewell = ""
}
BaitmongerNori.Nori_Shop = nori_Shop
BaitmongerNori.Nori_Tentacle = {
	Text = "Comes off something that lives deeper than my line goes.",
	Answers = true,
	IfTrue = "Nori_Tentacle2"
}
BaitmongerNori.Nori_Tentacle2 = {
	Text = `Worms and {nameTag("Fish Head")} I'll trade for Wen. That one costs more than coin.`,
	Answers = true,
	IfTrue = "Nori_Tentacle3"
}
BaitmongerNori.Nori_Tentacle3 = {
	Text = `Or you go take them. A {nameTag("Sealed Chest")} out in the wild will be holding some.`,
	Answers = true,
	IfTrue = "Nori_Tentacle4"
}
BaitmongerNori.Nori_Tentacle4 = {
	Text = "Sealed until whatever's ringed around it stops breathing. That part's your problem.",
	Answers = true,
	IfTrue = "Nori_Tentacle5"
}
BaitmongerNori.Nori_Tentacle5 = {
	Text = "Nothing marks where they sit, and they don't sit long. Rougher the country, the fatter the haul.",
	Answers = true,
	IfTrue = "Nori_Shop"
}
return BaitmongerNori