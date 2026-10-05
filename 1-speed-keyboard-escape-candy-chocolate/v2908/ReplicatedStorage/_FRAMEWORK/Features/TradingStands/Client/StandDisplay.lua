local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	return {}
end

local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local MarketplaceInfoCache = require(ReplicatedStorage.Utilities.MarketplaceInfoCache)
local Trading = require(ReplicatedStorage._FRAMEWORK.Features.Trading)
local Config = require(script.Parent.Parent.Config)
local logger = LoggerManager.createLogger("TradingStands", {
	feature = script:GetFullName()
})
local flag = false
local flag2 = false
local text2 = "-"
local v2 = nil
local v3 = {}

local function readHighlights(instance)
	local highlightItems = instance:GetAttribute("HighlightItems")

	if highlightItems then
		return HttpService:JSONDecode(highlightItems)
	end

	return {}
end

local function fillPanel(container, list, p: number, p2: number)
	Trading.clearItemButtons(container)
	local layoutOrder = 1

	for i = p, p2 do
		local v5 = list[i]

		if not v5 then
			continue
		end

		Trading.fillItemButton(v5, container, {
			templateName = "StandTradeItem",
			layoutOrder = layoutOrder
		})
		layoutOrder += 1
	end
end

local function isPremium(instance)
	return instance:GetAttribute("Type") == "Premium"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyPremiumPrice(p)
	if text2 then
		p.Booth.FrontPanel2.TradingFlagship2.PriceText.Text = text2
	else
		p.Booth.FrontPanel2.TradingFlagship2.PriceText.Text = "-"
	end
end

local function publishPrice(p: string)
	text2 = p

	for _, v4 in CollectionService:GetTagged("TradingStand") do
		if v4:GetAttribute("Type") ~= "Premium" then
			continue
		end

		applyPremiumPrice(v4) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function queuePremiumPrice()
	if flag2 then
		return
	end

	flag2 = true
	MarketplaceInfoCache.Request(Config.PremiumStandGamepassId, Enum.InfoType.GamePass, function(p)
		if type(p) == "table" and type(p.PriceInRobux) == "number" then
			publishPrice("ONLY " .. p.PriceInRobux .. "")
		else
			logger:warn("premium stand gamepass price lookup failed")
		end
	end)
end

local function refreshPrompt(instance)
	local interactStand = instance.Booth.StandPanel.InteractStand
	local ownerUserId = instance:GetAttribute("OwnerUserId") or 0
	interactStand.Enabled = true

	if ownerUserId == Players.LocalPlayer.UserId then
		if interactStand.ActionText ~= "Configure" then
			interactStand.ActionText = "Configure"
		end

		if interactStand.ObjectText ~= "Your Trading Stand" then
			interactStand.ObjectText = "Your Trading Stand"
		end
	elseif ownerUserId ~= 0 then
		local text = instance.Booth.StandPanel.StandName.Container.OwnerName.Text

		if interactStand.ActionText ~= "Trade" then
			interactStand.ActionText = "Trade"
		end

		if interactStand.ObjectText ~= text then
			interactStand.ObjectText = text
		end
	end
end

local function refreshItems(instance)
	local highlightItems = instance:GetAttribute("HighlightItems")
	local v4 = not highlightItems and {} or HttpService:JSONDecode(highlightItems)
	local highlightPanelCapacity = Config.HighlightPanelCapacity
	local booth = instance.Booth
	fillPanel(booth.FrontPanel.TradingFlagship.Container, v4, 1, highlightPanelCapacity)

	if instance:GetAttribute("Type") == "Premium" then
		fillPanel(booth.FrontPanel2.TradingFlagship2.Container, v4, highlightPanelCapacity + 1, #v4)
	end
end

local function unbindStand(p)
	local v4 = v3[p]
	v3[p] = nil

	if v4 then
		v4:Destroy()
	end
end

local function bindStand(instance)
	if v3[instance] then
		return
	end

	refreshPrompt(instance)
	refreshItems(instance)

	if instance:GetAttribute("Type") == "Premium" then
		queuePremiumPrice() -- equivalent call inferred; original call site unknown
		applyPremiumPrice(instance) -- equivalent call inferred; original call site unknown
	end

	local interactStand = instance.Booth.StandPanel.InteractStand
	local ownerName = instance.Booth.StandPanel.StandName.Container.OwnerName
	local ownerUserIdChangedConnection = instance:GetAttributeChangedSignal("OwnerUserId"):Connect(function()
		refreshPrompt(instance)
	end)
	local highlightItemsChangedConnection = instance:GetAttributeChangedSignal("HighlightItems"):Connect(function()
		refreshItems(instance)
	end)
	local actionTextChangedConnection = interactStand:GetPropertyChangedSignal("ActionText"):Connect(function()
		refreshPrompt(instance)
	end)
	local objectTextChangedConnection = interactStand:GetPropertyChangedSignal("ObjectText"):Connect(function()
		refreshPrompt(instance)
	end)
	local textChangedConnection = ownerName:GetPropertyChangedSignal("Text"):Connect(function()
		refreshPrompt(instance)
	end)
	local v4 = Janitor.new()
	v4:Add(ownerUserIdChangedConnection)
	v4:Add(highlightItemsChangedConnection)
	v4:Add(actionTextChangedConnection)
	v4:Add(objectTextChangedConnection)
	v4:Add(textChangedConnection)
	v3[instance] = v4
end

return {
	bind = function()
		if flag then
			return
		end

		flag = true

		for _, v4 in CollectionService:GetTagged("TradingStand") do
			bindStand(v4)
		end

		local connection = CollectionService:GetInstanceAddedSignal("TradingStand"):Connect(bindStand)
		local connection2 = CollectionService:GetInstanceRemovedSignal("TradingStand"):Connect(unbindStand)
		v2 = Janitor.new()
		v2:Add(connection)
		v2:Add(connection2)
	end
}