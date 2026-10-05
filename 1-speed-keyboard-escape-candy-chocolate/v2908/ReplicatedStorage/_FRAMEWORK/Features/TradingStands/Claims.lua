local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

if not RunService:IsServer() then
	return {}
end

local DataManager = require(ServerScriptService.DataManager)
local GamepassCache = require(ServerScriptService.GamepassCache)
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local Trading = require(ReplicatedStorage._FRAMEWORK.Features.Trading)
require(ReplicatedStorage._FRAMEWORK.Features.Trading.Types)
local Config = require(script.Parent.Config)
require(script.Parent.Types)
local logger = LoggerManager.createLogger("TradingStands", {
	feature = script:GetFullName()
})
local v = nil
local v2 = nil
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local fn
local v7 = {}
local Claims = {}

local function spacedModelName(value: string)
	return (string.gsub(value, "(%l)(%u)", "%1 %2"))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function standKind(instance)
	if instance:GetAttribute("Type") == "Premium" then
		return "Premium"
	end

	return "Standard"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function maxHighlights(instance)
	if standKind(instance) == "Premium" then
		return Config.PremiumHighlightMax
	end

	return Config.StandardHighlightMax
end

local function matchesEntry(p, p2)
	local key = Items.KeyOf(p2)

	if Items.KeyOf(p) ~= key or Items.TierOf(p) ~= Items.TierOf(p2) then
		return false
	end

	if not Items.IsLimitedKey(key) then
		return Items.SignatureOf(p) == Items.SignatureOf(p2)
	end

	return Items.LimitedNumberOf(p2) ~= nil and Items.LimitedNumberOf(p) == Items.LimitedNumberOf(p2) and Items.SignatureOf(p) == Items.SignatureOf(p2)
end

local function takeOwned(clone, p)
	for i, v8 in ipairs(clone) do
		if matchesEntry(v8, p) then
			return table.remove(clone, i)
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyPremiumPriceVisibility(instance)
	instance.Booth.FrontPanel2.TradingFlagship2.PriceText.Visible = (instance:GetAttribute("OwnerUserId") or 0) == 0
end

local function clearStand(instance)
	instance:SetAttribute("OwnerUserId", 0)
	instance:SetAttribute("HighlightItems", "[]")
	local standPanel = instance.Booth.StandPanel
	standPanel.StandName.Container.OwnerName.Text = "CLAIM THIS STAND"
	standPanel.InteractStand.ActionText = "Claim!"
	local interactStand = standPanel.InteractStand
	local name = instance.Name
	interactStand.ObjectText = string.gsub(name, "(%l)(%u)", "%1 %2")
	local frontPanel = instance.Booth.FrontPanel
	frontPanel.TradeStatus.Enabled = false
	frontPanel.TradingFlagship.InfoText.Visible = true

	if standKind(instance) == "Premium" then
		applyPremiumPriceVisibility(instance) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyTradeStatus(p, flag: boolean)
	local tradeStatus = p.Booth.FrontPanel.TradeStatus
	tradeStatus.Enabled = true
	tradeStatus.Contaimer.TextLabel.Text = flag and "Ongoing Trade..." or "Ready to trade!"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writeHighlights(instance, p)
	instance:SetAttribute("HighlightItems", HttpService:JSONEncode(p))
end

local function applyClaim(player, instance)
	local v8 = v3[player]

	if v8 and v8 ~= instance then
		v4[v8] = nil
		clearStand(v8)
	end

	local v9 = v5[player]

	if not v9 then
		v9 = {}
		v5[player] = v9
	end

	local v10 = maxHighlights(instance) -- equivalent call inferred; original call site unknown

	while v10 < #v9 do
		table.remove(v9)
	end

	v3[player] = instance
	v4[instance] = player
	local standPanel = instance.Booth.StandPanel
	local v11 = player.DisplayName .. "'s Stand"
	instance:SetAttribute("OwnerUserId", player.UserId)
	standPanel.StandName.Container.OwnerName.Text = v11
	standPanel.InteractStand.ActionText = "Trade"
	standPanel.InteractStand.ObjectText = v11
	instance.Booth.FrontPanel.TradingFlagship.InfoText.Visible = false

	if standKind(instance) == "Premium" then
		applyPremiumPriceVisibility(instance) -- equivalent call inferred; original call site unknown
	end

	applyTradeStatus(instance, Trading.isInContract(player)) -- equivalent call inferred; original call site unknown
	writeHighlights(instance, v9) -- equivalent call inferred; original call site unknown
	fn(player)
end

local function openConfig(p, instance)
	local highlights = {}

	for _, v9 in ipairs(v5[p]) do
		table.insert(highlights, Items.CopyEntry(v9))
	end

	local v9 = {
		kind = standKind(instance),
		highlights = highlights
	}
	v.openStandConfig:fire(p, v9)
end

local function checkClaimReady(p, instance)
	local ownerUserId = instance:GetAttribute("OwnerUserId") or 0

	if ownerUserId == p.UserId then
		return true, "configure"
	end

	if ownerUserId ~= 0 then
		return true, "trade"
	end

	if standKind(instance) ~= "Premium" then
		return true, "claim"
	end

	local userOwnsGamePass = GamepassCache:UserOwnsGamePass(p, Config.PremiumStandGamepassId)
	local ownerUserId2 = instance:GetAttribute("OwnerUserId") or 0

	if not p.Parent then
		return false, "taken"
	end

	if ownerUserId2 == p.UserId then
		return true, "configure"
	end

	if ownerUserId2 ~= 0 then
		return false, "taken"
	end

	if userOwnsGamePass then
		return true, "claim"
	end

	return false, "needsPass"
end

local function onTriggered(player, instance)
	local v8, v9 = checkClaimReady(player, instance)

	if v8 then
		if v9 == "configure" then
			openConfig(player, instance)
		elseif v9 == "trade" then
			Trading.requestTrade(player, instance:GetAttribute("OwnerUserId"))
		else
			applyClaim(player, instance)
		end
	elseif v9 == "needsPass" then
		MarketplaceService:PromptGamePassPurchase(player, Config.PremiumStandGamepassId)
	end
end

local function checkHighlightsReady(p, list)
	local v8 = v3[p]

	if not v8 then
		return false, nil, "player has no trading stand"
	end

	local v9 = maxHighlights(v8) -- equivalent call inferred; original call site unknown

	if v9 < #list then
		return false, nil, string.format("highlight count %d exceeds %d", #list, v9)
	end

	local store = DataManager:GetStore(p, "Items")

	if not store then
		return false, nil, "player item store is unavailable"
	end

	local clone = table.clone(store:Get({}))
	local result = {}

	for _, v10 in ipairs(list) do
		local key = Items.KeyOf(v10)
		local tier = Items.TierOf(v10)

		if not Items.ITEMS[key] or tier ~= v10.Tier then
			return false, nil, "unknown highlight item"
		end

		local v11 = takeOwned(clone, v10)

		if not v11 then
			return false, nil, "highlighted item is not owned"
		end

		table.insert(result, Items.CopyEntry(v11))
	end

	return true, result, nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyHighlights(p, p2)
	v5[p] = p2
	writeHighlights(v3[p], p2) -- equivalent call inferred; original call site unknown
end

local function reconcileHighlights(p, p2)
	local v8 = v3[p]
	local v9 = v5[p]

	if v8 and v9 then
		local clone = table.clone(p2)
		local v10 = {}

		for _, v11 in ipairs(v9) do
			local v12 = takeOwned(clone, v11)

			if v12 then
				table.insert(v10, Items.CopyEntry(v12))
			end
		end

		if #v10 ~= #v9 then
			applyHighlights(p, v10) -- equivalent call inferred; original call site unknown
		end
	end
end

fn = function(player)
	local store = not v6[player] and DataManager:GetStore(player, "Items")

	if store then
		v6[player] = true
		store:OnUpdate(function(p)
			reconcileHighlights(player, p)
		end)
	end
end

local function onContractChanged(p, flag: boolean)
	local v8 = v3[p]

	if v8 then
		applyTradeStatus(v8, flag) -- equivalent call inferred; original call site unknown
	end
end

local function releasePlayer(p)
	local v8 = v3[p]
	v3[p] = nil
	v5[p] = nil
	v6[p] = nil

	if v8 then
		v4[v8] = nil
		clearStand(v8)
	end
end

local function unbindStand(p)
	local v8 = v4[p]

	if v8 and v3[v8] == p then
		v3[v8] = nil
		v5[v8] = nil
		v4[p] = nil
	end

	local v9 = v7[p]
	v7[p] = nil

	if v9 then
		v9:Destroy()
	end
end

local function bindStand(p)
	if v7[p] then
		return
	end

	clearStand(p)
	local triggeredConnection = p.Booth.StandPanel.InteractStand.Triggered:Connect(function(player)
		onTriggered(player, p)
	end)
	local v8 = Janitor.new()
	v8:Add(triggeredConnection)
	v7[p] = v8
end

function Claims.setHighlights(p, p2)
	local v8, v9, v10 = checkHighlightsReady(p, p2)

	if v8 and v9 then
		applyHighlights(p, v9) -- equivalent call inferred; original call site unknown
	else
		logger:warn(v10)
	end
end

function Claims.start(p)
	if v2 then
		return
	end

	v = p

	for _, v8 in CollectionService:GetTagged("TradingStand") do
		bindStand(v8)
	end

	local connection = CollectionService:GetInstanceAddedSignal("TradingStand"):Connect(bindStand)
	local connection2 = CollectionService:GetInstanceRemovedSignal("TradingStand"):Connect(unbindStand)
	local playerRemovingConnection = Players.PlayerRemoving:Connect(releasePlayer)
	local contractChangedConnection = Trading.contractChanged:Connect(onContractChanged)
	local promptGamePassPurchaseFinishedConnection = MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p2, p3, p4)
		if p4 and p3 == Config.PremiumStandGamepassId then
			GamepassCache:SetOwns(p2, p3)
		end
	end)
	v2 = Janitor.new()
	v2:Add(connection)
	v2:Add(connection2)
	v2:Add(playerRemovingConnection)
	v2:Add(contractChangedConnection)
	v2:Add(promptGamePassPurchaseFinishedConnection)
end

return Claims