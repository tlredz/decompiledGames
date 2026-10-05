local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Gamepass = {
	Deferred = true
}
local priceInRobuxes = {}

function Gamepass.GetRobuxPrice(p: number)
	local v = priceInRobuxes[p]

	if v ~= nil then
		return v
	end

	local success, productInfoAsync = pcall(
		MarketplaceService.GetProductInfoAsync,
		MarketplaceService,
		p,
		Enum.InfoType.GamePass
	)

	if not success or productInfoAsync == nil or productInfoAsync.PriceInRobux == nil then
		return nil
	end

	priceInRobuxes[p] = productInfoAsync.PriceInRobux
	return productInfoAsync.PriceInRobux
end

local v = {}

local function ownedKey(p: number, p2: number)
	return p .. "_" .. p2
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, p2: number, flag: boolean)
	if flag then
		v[p.UserId .. "_" .. p2] = true
	end
end)

function Gamepass.OwnsGamepass(p: number, p2: number)
	local v2 = p .. "_" .. p2

	if v[v2] then
		return true
	end

	local success, result = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, p, p2)

	if not success or result ~= true then
		return false
	end

	v[v2] = true
	return true
end

function Gamepass.FormulateTextPlusText(p: number)
	local robuxPrice = Gamepass.GetRobuxPrice(p)

	if robuxPrice == nil then
		return nil
	end

	return (`{Utility.addCommasToNumber(robuxPrice)} [#]<img={BunchaIcons.Robux}>`)
end

function Gamepass.FormulateRichText(p: number)
	local robuxPrice = Gamepass.GetRobuxPrice(p)

	if robuxPrice == nil then
		return nil
	end

	return (`<font color="rgb(255,255,255)">{Utility.addCommasToNumber(robuxPrice)} Robux</font>`)
end

function Gamepass.GetContent(p: number)
	local robuxPrice = Gamepass.GetRobuxPrice(p)

	if robuxPrice == nil then
		return nil
	end

	return {
		Icon = BunchaIcons.Robux,
		Price = robuxPrice,
		Color = gameSettings.robuxColor
	}
end

function Gamepass.CanBuy(p, p2: number)
	local parent

	if p.Parent ~= nil then
		parent = p.Parent.Parent or nil
	end

	local child

	if parent ~= nil then
		child = Players:FindFirstChild(parent.Name)
	end

	return child ~= nil and not Gamepass.OwnsGamepass(child.UserId, p2)
end

function Gamepass.Buy(_, p: number, p2, _: string?)
	if p2 == nil then
		return
	end

	MarketplaceService:PromptGamePassPurchase(p2, p)
end

return Gamepass