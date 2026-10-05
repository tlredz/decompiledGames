local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Analytics, Discord

if RunService:IsServer() then
	local ServerStorage = game:GetService("ServerStorage")
	Analytics = require(ServerStorage.SAM.Services.Reporting.Analytics)
	local ServerStorage2 = game:GetService("ServerStorage")
	Discord = require(ServerStorage2.SAM.Services.Reporting.Discord)
else
	Discord = nil
	Analytics = nil
end

local Wen = {}

function Wen.FormulateTextPlusText(p: number)
	return (`${Utility.addCommasToNumber(p)} [#]<img={BunchaIcons.WenRaw}>`)
end

function Wen.FormulateRichText(p: number)
	return (`<font color="rgb(214,253,61)">{Utility.addCommasToNumber(p)} Wen</font>`)
end

function Wen.GetContent(price: number)
	return {
		Icon = BunchaIcons.Wen,
		Price = price
	}
end

function Wen.CanBuy(p, p2: number)
	return p2 <= p.Wen.Value
end

function Wen.Buy(p, p2: number, p3, p4: string?)
	if Discord ~= nil and p3 ~= nil then
		Discord.ExpectWen(p3)
	end

	p.Wen.Value -= p2

	if Analytics ~= nil and p3 ~= nil then
		Analytics.Economy(p3, "Wen", "Sink", p2, "ShopPurchase", p4)
	end
end

return Wen