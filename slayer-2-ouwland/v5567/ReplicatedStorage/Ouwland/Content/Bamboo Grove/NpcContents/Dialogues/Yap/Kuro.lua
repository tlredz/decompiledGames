local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Shop

if RunService:IsClient() then
	Shop = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.Components.Shop)
end

local v = {
	"Urokodaki's Mask",
	"Stylish Boa",
	"Sun Eve Drape",
	"Peppermint Scarf",
	"Heart of Night Necklace",
	"Tidal Earrings",
	"Cherry Blossom Lantern",
	"Crown of the Brave",
	"Black Dragon Horns",
	"Solstice Necklace",
	"Black-Cord Necklace",
	"Ivory edge Cloak"
}
local kuro_ = {
	OnShow = function(_, p)
		p.CartShopNode = "Kuro_2"
	end,
	Content = 0,
	Text = "Here's my [inventory]<Color=(1,.85,.3)>, buy what you think you need.",
	Answers = 0
}
local content

if Shop ~= nil then
	content = Shop(v) or nil
end

kuro_.Content = content
kuro_.Answers = {
	["Buy the selection"] = "ReviewCartPurchase",
	Farewell = "Kuro_Farewell"
}
return {
	Kuro = {
		Text = "Well now... not many travelers find me out here [after dark]<Style=Fade,Color=(.6,.6,1)>.",
		Answers = true,
		IfTrue = "Kuro_2"
	},
	Kuro_2 = kuro_,
	Kuro_Farewell = {
		Text = `Keep your coin [#]<img={BunchaIcons.WenRaw}> close… we may meet again [when the moon rises.]<Style=Fade,Color=(.6,.6,1)>`,
		Answers = 1
	}
}