local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shop

if RunService:IsClient() then
	Shop = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.Components.Shop)
end

local v = {
	"Health Elixir",
	"Stamina Regen Elixir",
	"Health Regen Elixir",
	"Underwater Breathing Potion"
}
local alchemistMeku_ = {
	OnShow = function(_, p)
		p.CartShopNode = "Alchemist Meku_2"
	end,
	Content = 0,
	Text = "Take a look, they are [high quality]<Color=(1,.85,.3)>.",
	Answers = 0
}
local content

if Shop ~= nil then
	content = Shop(v) or nil
end

alchemistMeku_.Content = content
alchemistMeku_.Answers = {
	["Buy the selection"] = "ReviewCartPurchase",
	Farewell = ""
}
return {
	["Alchemist Meku"] = {
		Text = "You interested in [Elixirs]<Color=(1,.85,.3)>?",
		Answers = true,
		IfTrue = "Alchemist Meku_2"
	},
	["Alchemist Meku_2"] = alchemistMeku_
}