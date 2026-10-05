local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local SpinBalance = require(ReplicatedStorage.CAM.Global.SpinBalance)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Analytics

if RunService:IsServer() then
	local ServerStorage = game:GetService("ServerStorage")
	Analytics = require(ServerStorage.SAM.Services.Reporting.Analytics)
else
	Analytics = nil
end

local Spins = {}

function Spins.FormulateTextPlusText(p: number)
	return (`[#]<img={BunchaIcons.SpinsIconRaw}> [{Utility.addCommasToNumber(p)} Spins]<{gameSettings.RichTextPopularConfigs.SoroundColor}>`)
end

function Spins.FormulateRichText(p: number)
	return (`<font {string.lower(gameSettings.RichTextPopularConfigs.SoroundColorRBX)}>{Utility.addCommasToNumber(p)} Spins</font>`)
end

function Spins.GetContent(price: number)
	return {
		Icon = BunchaIcons.SpinsIcon,
		Price = price
	}
end

function Spins.CanBuy(p, p2: number)
	return p2 <= SpinBalance.Total(p, false)
end

function Spins.Buy(p, p2: number, p3, p4: string?)
	if not SpinBalance.Charge(p, false, p2) then
		return
	end

	if Analytics ~= nil and p3 ~= nil then
		Analytics.Economy(p3, "Spins", "Sink", p2, "ShopPurchase", p4)
	end
end

return Spins