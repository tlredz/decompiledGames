local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Product = {
	Deferred = true
}
local isServer = RunService:IsServer()
local v = {}

local function getInfo(p: number)
	local v2 = v[p]

	if v2 ~= nil then
		return v2
	end

	local success, productInfoAsync = pcall(
		MarketplaceService.GetProductInfoAsync,
		MarketplaceService,
		p,
		Enum.InfoType.Product
	)

	if not success or productInfoAsync == nil or productInfoAsync.PriceInRobux == nil then
		return nil
	end

	local iconImageAssetId = tonumber(productInfoAsync.IconImageAssetId)
	local v3 = {
		Price = productInfoAsync.PriceInRobux,
		Icon = 0
	}
	local icon

	if not (iconImageAssetId == nil or not (iconImageAssetId > 0)) then
		icon = `rbxassetid://{iconImageAssetId}`
	end

	v3.Icon = icon
	v[p] = v3

	if isServer then
		script:SetAttribute(`BasePrice_{p}`, productInfoAsync.PriceInRobux)
	end

	return v3
end

function Product.GetRobuxPrice(p: number)
	local info = getInfo(p)
	return info ~= nil and info.Price or nil
end

function Product.GetBaseRobuxPrice(p: number)
	if isServer then
		return Product.GetRobuxPrice(p)
	end

	return script:GetAttribute((`BasePrice_{p}`))
end

function Product.GetProductIcon(p: number)
	local info = getInfo(p)
	return info ~= nil and info.Icon or nil
end

function Product.FormulateTextPlusText(p: number)
	local robuxPrice = Product.GetRobuxPrice(p)

	if robuxPrice == nil then
		return nil
	end

	return (`{Utility.addCommasToNumber(robuxPrice)} [#]<img={BunchaIcons.Robux}>`)
end

function Product.FormulateRichText(p: number)
	local robuxPrice = Product.GetRobuxPrice(p)

	if robuxPrice == nil then
		return nil
	end

	return (`<font color="rgb(255,255,255)">{Utility.addCommasToNumber(robuxPrice)} Robux</font>`)
end

function Product.GetContent(p: number)
	local robuxPrice = Product.GetRobuxPrice(p)

	if robuxPrice == nil then
		return nil
	end

	return {
		Icon = BunchaIcons.Robux,
		Price = robuxPrice,
		Color = gameSettings.robuxColor
	}
end

function Product.CanBuy(_, _: number)
	return true
end

function Product.Buy(_, p: number, p2, _: string?)
	if p2 == nil then
		return
	end

	MarketplaceService:PromptProductPurchase(p2, p)
end

return Product