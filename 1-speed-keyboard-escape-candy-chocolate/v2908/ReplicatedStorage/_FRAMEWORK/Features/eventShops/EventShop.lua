local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local EventsConfig = require(ReplicatedStorage.EventsConfig)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local AdminAbuseEvent = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent)
local Rotation = require(script.Parent.Rotation)
require(script.Parent.Types)
local isServer = RunService:IsServer()
local DataManager

if isServer then
	DataManager = require(ServerScriptService.DataManager)
else
	DataManager = nil
end

local EventCurrencyManager

if isServer then
	EventCurrencyManager = require(ServerScriptService.EventCurrencyManager)
else
	EventCurrencyManager = nil
end

local EconomyTracker

if isServer then
	EconomyTracker = require(ServerScriptService.Utilities.EconomyTracker)
else
	EconomyTracker = nil
end

local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})

local function isEventWindowOpen(event: string, now: number)
	for _, event2 in ipairs(EventsConfig.Events) do
		if event2.Name == event then
			return event2.Start <= now and now < event2.End
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function listingSlotId(listing)
	local tier = listing.tier or 0

	if tier > 0 then
		return listing.itemKey .. "_T" .. tier
	end

	return listing.itemKey
end

local function buildBaseSlots(catalog, pools, effectiveCycle: number)
	local itemEntries = {}

	if catalog.kind == "Rotating" then
		for i, slot in ipairs(catalog.slots) do
			local item = Rotation.pickItem(pools, slot, i, effectiveCycle)

			if item then
				itemEntries[slot.id] = {
					itemKey = item,
					tier = 0,
					stock = slot.stock,
					price = nil
				}
			end
		end
	else
		for _, listing in ipairs(catalog.listings) do
			local v = listingSlotId(listing) -- equivalent call inferred; original call site unknown
			itemEntries[v] = {
				itemKey = listing.itemKey,
				tier = listing.tier or 0,
				stock = listing.stock,
				price = listing.price
			}
		end
	end

	return itemEntries
end

-- equivalent calls inferred from this helper; original call sites unknown
local function remainingStock(p, value: number?)
	if p.stock == nil then
		return nil
	end

	return (math.max(0, p.stock - (value or 0)))
end

local function hasStockLeft(p, value: number?)
	local v = remainingStock(p, value) -- equivalent call inferred; original call site unknown
	return v == nil or v > 0
end

local function isIntegerBetween(p: number, p2: number, p3: number)
	return p % 1 == 0 and p2 <= p and p <= p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshPlayerUi(player)
	local playerData

	if player.Parent then
		playerData = DataManager:GetPlayerData(player)
	end

	if playerData then
		ReplicatedStorage.Remotes.UpdateUI:FireClient(player, playerData)
	end
end

local EventShop = {}
EventShop.__index = EventShop

function EventShop.new(definition)
	local catalog = definition.catalog
	local object = setmetatable({
		definition = definition,
		changed = Signal.new(),
		pools = catalog.kind ~= "Rotating" and {} or Rotation.buildPools(definition.eventKey),
		baseCycle = -1,
		baseSlots = {},
		itemOverrides = {},
		stockOverrides = {},
		extras = {},
		slotEpochs = {},
		cycleOverride = nil,
		forcedRestockAt = nil,
		lastNaturalCycle = 0
	}, EventShop)
	object.lastNaturalCycle = object:naturalCycle(os.time())
	return object
end

function EventShop.getBaseSlotIds(p)
	local catalog = p.catalog
	local result = {}

	if catalog.kind == "Rotating" then
		for _, slot in ipairs(catalog.slots) do
			table.insert(result, slot.id)
		end
	else
		for _, listing in ipairs(catalog.listings) do
			local v = listingSlotId(listing) -- equivalent call inferred; original call site unknown
			table.insert(result, v)
		end
	end

	return result
end

function EventShop:naturalCycle(p2: number)
	local catalog = self.definition.catalog

	if catalog.kind == "Rotating" then
		return (math.floor(p2 / catalog.restockInterval))
	end

	return 0
end

function EventShop:effectiveCycle()
	return self.cycleOverride or self:naturalCycle(os.time())
end

function EventShop:nextRestockTime()
	local catalog = self.definition.catalog

	if catalog.kind == "Rotating" then
		return self.forcedRestockAt or (self:naturalCycle(os.time()) + 1) * catalog.restockInterval
	end

	return nil
end

function EventShop:isActive()
	local activity = self.definition.activity

	if activity.kind ~= "AdminAbuse" then
		return (isEventWindowOpen(activity.event, os.time()))
	end

	for _, v in AdminAbuseEvent.getActiveStates() do
		if table.find(activity.modules, v.name) then
			return true
		end
	end

	return false
end

function EventShop:getBaseSlots()
	local effectiveCycle = self:effectiveCycle()

	if self.baseCycle ~= effectiveCycle then
		self.baseCycle = effectiveCycle
		self.baseSlots = buildBaseSlots(self.definition.catalog, self.pools, effectiveCycle)
	end

	return self.baseSlots
end

function EventShop:getLiveSlots()
	local result = {}

	for k, v in self:getBaseSlots() do
		local stock = self.stockOverrides[k]
		local v2 = {
			itemKey = self.itemOverrides[k] or v.itemKey,
			tier = v.tier,
			stock = 0,
			price = 0,
			isExtra = false
		}

		if stock == nil then
			stock = v.stock
		end

		v2.stock = stock
		v2.price = v.price
		result[k] = v2
	end

	for k, extra in self.extras do
		result[k] = {
			itemKey = extra.itemKey,
			tier = extra.tier,
			stock = extra.stock,
			price = extra.price,
			isExtra = true
		}
	end

	return result
end

function EventShop:priceOf(p2)
	return p2.price or self.definition.prices[Items.ITEMS[p2.itemKey].rarity]
end

function EventShop:productOf(p2)
	local robuxProducts = self.definition.robuxProducts

	if robuxProducts then
		return robuxProducts[Items.ITEMS[p2.itemKey].rarity]
	end

	return nil
end

function EventShop:reconcile(p)
	local activeData = DataManager:GetActiveData(p)

	if not activeData then
		return nil
	end

	local effectiveCycle = self:effectiveCycle()
	local v = activeData.EventShopsState[self.definition.id]

	if v == nil or v.cycle ~= effectiveCycle then
		v = {
			cycle = effectiveCycle,
			purchases = {},
			slotEpochs = {}
		}
		activeData.EventShopsState[self.definition.id] = v
	end

	for k, slotEpoch in self.slotEpochs do
		if v.slotEpochs[k] == slotEpoch then
			continue
		end

		v.purchases[k] = nil
		v.slotEpochs[k] = slotEpoch
	end

	return v
end

function EventShop:checkSlot(p, slotId: string)
	if not self:isActive() then
		return false, nil, "ShopInactive"
	end

	local state = self:reconcile(p)
	local slot = self:getLiveSlots()[slotId]

	if state == nil then
		return false, nil, "NoData"
	end

	if slot == nil then
		return false, nil, "InvalidSlot"
	end

	local v3 = remainingStock(slot, state.purchases[slotId]) -- equivalent call inferred; original call site unknown

	if v3 == nil or v3 > 0 then
		return true, {
			state = state,
			slot = slot,
			slotId = slotId
		}, nil
	end

	return false, nil, "OutOfStock"
end

function EventShop:consumeStock(data)
	if data.slot.stock ~= nil then
		local purchases = data.state.purchases
		purchases[data.slotId] = (purchases[data.slotId] or 0) + 1
	end
end

function EventShop:releaseStock(data)
	local purchases = data.state.purchases
	local purchas = purchases[data.slotId]

	if data.slot.stock ~= nil and purchas ~= nil and purchas > 0 then
		purchases[data.slotId] = purchas - 1
	end
end

function EventShop:spend(p2, p3: number)
	local currency = self.definition.currency

	if currency.kind ~= "Wins" then
		return (EventCurrencyManager:Spend(p2, currency.key, p3))
	end

	local store = DataManager:GetStore(p2, "Wins")
	local v = store:Get(0)

	if p3 <= v then
		store:Set(v - p3)
		return true
	else
		return false
	end
end

function EventShop:refund(p2, p3: number)
	local currency = self.definition.currency

	if currency.kind ~= "Wins" then
		EventCurrencyManager:Add(p2, currency.key, p3)
		return
	end

	local store = DataManager:GetStore(p2, "Wins")
	store:Set(store:Get(0) + p3)
end

function EventShop:trackSpend(p2, p3: number)
	if self.definition.currency.kind == "Wins" then
		local v = DataManager:GetStore(p2, "Wins"):Get(0)
		EconomyTracker.trackWins(p2, p3, v, Enum.AnalyticsEconomyFlowType.Sink, nil, self.definition.id)
	end
end

function EventShop:applyCurrencyPurchase(player, p, p2: number)
	if not self:spend(player, p2) then
		return false, "NotEnoughCurrency"
	end

	self:consumeStock(p)
	local success, result, v = pcall(DataManager.GrantItem, DataManager, player, p.slot.itemKey, p.slot.tier)

	if success and result then
		self:trackSpend(player, p2)
		refreshPlayerUi(player) -- equivalent call inferred; original call site unknown
		return true, nil
	else
		self:refund(player, p2)
		self:releaseStock(p)

		if success then
			result = v
		end

		logger:warn(string.format("Could not grant %s to %s: %s", p.slot.itemKey, player.Name, (tostring(result))))
		return false, "GrantFailed"
	end
end

function EventShop:buyWithCurrency(p, p2: string)
	local v, v2, v3 = self:checkSlot(p, p2)
	local v4

	if v2 then
		v4 = self:priceOf(v2.slot)
	end

	if v and v2 and v4 then
		return self:applyCurrencyPurchase(p, v2, v4)
	end

	if v then
		return false, "NoPriceConfig"
	end

	return false, v3
end

function EventShop:checkRobuxPurchase(p, slotId: string)
	local v, v2, v3 = self:checkSlot(p, slotId)
	local productId

	if v2 then
		productId = self:productOf(v2.slot)
	end

	if v and v2 and productId then
		return true, {
			shopId = self.definition.id,
			slotId = slotId,
			itemKey = v2.slot.itemKey,
			tier = v2.slot.tier,
			productId = productId
		}, nil
	end

	if v then
		return false, nil, "NoPriceConfig"
	end

	return false, nil, v3
end

function EventShop:grantRobuxPurchase(p, data)
	local v = DataManager:GrantItem(p, data.itemKey, data.tier, 1, {
		allowLimitedOverflow = true
	})
	local state

	if v then
		state = self:reconcile(p)
	end

	local slot = self:getLiveSlots()[data.slotId]

	if not state or not slot or slot.itemKey ~= data.itemKey then
		return v == true
	end

	local v4 = remainingStock(slot, state.purchases[data.slotId]) -- equivalent call inferred; original call site unknown

	if v4 == nil or v4 > 0 then
		self:consumeStock({
			state = state,
			slot = slot,
			slotId = data.slotId
		})
	end

	return v == true
end

function EventShop:resolveGift(p, p2: string, p3: string)
	local v, v2, v3 = self:checkSlot(p, p2)

	if v and v2 and self.definition.giftable and v2.slot.itemKey == p3 then
		return v2.slot.tier, nil
	end

	if v then
		return nil, "InvalidGiftSource"
	end

	return nil, v3
end

function EventShop:consumeGift(p, slotId: string, p3: string, p4: number)
	local state = self:reconcile(p)
	local slot = self:getLiveSlots()[slotId]

	if state == nil then
		return false, "NoData"
	end

	if slot == nil or slot.itemKey ~= p3 or slot.tier ~= p4 then
		return false, "ListingChanged"
	end

	local v3 = remainingStock(slot, state.purchases[slotId]) -- equivalent call inferred; original call site unknown

	if v3 ~= nil and not (v3 > 0) then
		return false, "OutOfStock"
	end

	self:consumeStock({
		state = state,
		slot = slot,
		slotId = slotId
	})
	return true, nil
end

function EventShop:buildPayload(p)
	local v = self:reconcile(p)

	if not v then
		return nil
	end

	local itemEntries = {}

	for k, v2 in self:getLiveSlots() do
		local remaining = remainingStock(v2, v.purchases[k]) -- equivalent call inferred; original call site unknown

		if not v2.isExtra or remaining ~= 0 then
			itemEntries[k] = {
				itemKey = v2.itemKey,
				tier = v2.tier,
				rarity = Items.ITEMS[v2.itemKey].rarity,
				price = self:priceOf(v2),
				stock = v2.stock,
				remaining = remaining
			}
		end
	end

	return {
		slots = itemEntries,
		nextRestockTime = self:nextRestockTime()
	}
end

function EventShop:restock()
	table.clear(self.itemOverrides)
	table.clear(self.stockOverrides)
	table.clear(self.extras)
	table.clear(self.slotEpochs)
	self.changed:Fire({
		restock = true
	})
end

function EventShop:update(p: number)
	local naturalCycle = self:naturalCycle(p)
	local forcedRestockAt = self.forcedRestockAt

	if forcedRestockAt == nil or not (forcedRestockAt <= p) then
		if forcedRestockAt == nil and naturalCycle ~= self.lastNaturalCycle then
			self.lastNaturalCycle = naturalCycle
			self.cycleOverride = nil
			self:restock()
		end
	else
		self.forcedRestockAt = nil
		self.cycleOverride += 1
		self.lastNaturalCycle = naturalCycle
		self:restock()
	end
end

function EventShop:findRotatingSlot(p2: string)
	local catalog = self.definition.catalog

	if catalog.kind == "Rotating" then
		for _, slot in ipairs(catalog.slots) do
			if slot.id == p2 then
				return slot
			end
		end
	end

	return nil
end

function EventShop:findExtra(p2: string, p3: number?)
	if self.extras[p2] then
		return p2
	end

	for k, extra in self.extras do
		if extra.itemKey == p2 and (p3 == nil or extra.tier == p3) then
			return k
		end
	end

	return nil
end

function EventShop:checkEventItem(p2: string)
	local v = Items.ITEMS[p2]

	if v and v.EventKey == self.definition.eventKey then
		return true, nil
	end

	return false, string.format("'%s' is not an item of event %s", p2, self.definition.eventKey)
end

function EventShop:checkSwap(data)
	local v = self:getBaseSlots()[data.slotId]
	local v2, v3 = self:checkEventItem(data.itemKey)
	local rotatingSlot = self:findRotatingSlot(data.slotId)

	if v == nil then
		return false, string.format("Unknown slot '%s'", data.slotId)
	end

	if not v2 then
		return false, v3
	end

	if rotatingSlot and not Rotation.slotAllowsRarity(rotatingSlot, Items.ITEMS[data.itemKey].rarity) then
		return false, string.format("Slot %s never rolls %s items", data.slotId, Items.ITEMS[data.itemKey].rarity)
	end

	if data.stock ~= nil and v.stock == nil then
		return false, string.format("Slot %s has unlimited stock", data.slotId)
	end

	if data.stock == nil then
		return true, nil
	end

	local stock = data.stock
	local v4

	if stock % 1 == 0 and stock >= 0 then
		v4 = stock <= 99
	else
		v4 = false
	end

	if not v4 then
		return false, string.format("Stock must be an integer from %d to %d", 0, 99)
	end

	return true, nil
end

function EventShop:checkAdd(data)
	local v, v2 = self:checkEventItem(data.itemKey)

	if not v then
		return false, v2
	end

	local tier = data.tier
	local MAX_TIER = Items.MAX_TIER
	local v3

	if tier % 1 == 0 and tier >= 0 then
		v3 = tier <= MAX_TIER
	else
		v3 = false
	end

	if not v3 then
		return false, string.format("Tier must be an integer from 0 to %d", Items.MAX_TIER)
	end

	local amount = data.amount
	local v4

	if amount % 1 == 0 and amount >= 1 then
		v4 = amount <= 99
	else
		v4 = false
	end

	if not v4 then
		return false, string.format("Stock must be an integer from %d to %d", 1, 99)
	end

	if data.price == nil then
		return true, nil
	end

	local price = data.price
	local v5

	if price % 1 == 0 and price >= 1 then
		v5 = price <= 1000000
	else
		v5 = false
	end

	if not v5 then
		return false, string.format("Price must be an integer from 1 to %d", 1000000)
	end

	return true, nil
end

function EventShop:checkStockTarget(data)
	local extra = self:findExtra(data.target, data.tier)
	local v = self:getBaseSlots()[data.target]
	local amount = data.amount
	local v2

	if amount % 1 == 0 and amount >= 0 then
		v2 = amount <= 99
	else
		v2 = false
	end

	if not v2 then
		return false, nil, string.format("Stock must be an integer from %d to %d", 0, 99)
	end

	if extra then
		return true, extra, nil
	end

	if v == nil then
		return false, nil, string.format("No listing matches '%s'", data.target)
	end

	if v.stock == nil then
		return false, nil, string.format("Slot %s has unlimited stock", data.target)
	end

	return true, data.target, nil
end

function EventShop:adminRestock(cycleOverride: number, p: number)
	local catalog = self.definition.catalog

	if catalog.kind ~= "Rotating" then
		return false, string.format("%s does not rotate", self.definition.id)
	end

	self.cycleOverride = cycleOverride
	self.forcedRestockAt = p + catalog.restockInterval
	self.lastNaturalCycle = self:naturalCycle(os.time())
	self:restock()
	return true, string.format("Restocked %s", self.definition.id)
end

function EventShop:adminSwap(data, p: number)
	local v, v2 = self:checkSwap(data)

	if v and data.stock ~= nil then
		self.itemOverrides[data.slotId] = data.itemKey
		self.stockOverrides[data.slotId] = data.stock
		self.slotEpochs[data.slotId] = p
		self.changed:Fire(nil)
		return true, string.format("%s now sells %s with %d stock (refilled)", data.slotId, data.itemKey, data.stock)
	else
		if not v then
			return false, v2
		end

		self.itemOverrides[data.slotId] = data.itemKey
		self.changed:Fire(nil)
		return true, string.format("%s now sells %s", data.slotId, data.itemKey)
	end
end

function EventShop:adminAdd(data, p: number)
	local v, v2 = self:checkAdd(data)

	if not v then
		return false, v2
	end

	local v3 = "extra_" .. p
	self.extras[v3] = {
		itemKey = data.itemKey,
		tier = data.tier,
		stock = data.amount,
		price = data.price
	}
	self.changed:Fire({
		sound = "ITEM_REWARD",
		itemAdded = {
			itemKey = data.itemKey,
			tier = data.tier
		}
	})
	return true, string.format("Added %s T%d x%d as %s", data.itemKey, data.tier, data.amount, v3)
end

function EventShop:adminRemove(p)
	local extra = self:findExtra(p.target, p.tier)
	local v = self.itemOverrides[p.target] ~= nil or self.stockOverrides[p.target] ~= nil

	if extra then
		self.extras[extra] = nil
		self.changed:Fire(nil)
		return true, string.format("Removed %s", extra)
	else
		if not v then
			return false, string.format("No listing matches '%s'", p.target)
		end

		self.itemOverrides[p.target] = nil
		self.stockOverrides[p.target] = nil
		self.changed:Fire(nil)
		return true, string.format("Cleared the overrides on %s", p.target)
	end
end

function EventShop:adminSetStock(p, p2: number)
	local v, v2, v3 = self:checkStockTarget(p)

	if not (v and v2) then
		return false, v3
	end

	if self.extras[v2] then
		self.extras[v2].stock = p.amount
	else
		self.stockOverrides[v2] = p.amount
	end

	self.slotEpochs[v2] = p2
	self.changed:Fire(nil)
	return true, string.format("%s max stock set to %d (refilled)", v2, p.amount)
end

function EventShop:applyAdminAction(p, p2: number, p3: number)
	if p.kind == "restock" then
		return self:adminRestock(p2, p3)
	end

	if p.kind == "swap" then
		return self:adminSwap(p, p2)
	end

	if p.kind == "add" then
		return self:adminAdd(p, p2)
	end

	if p.kind == "remove" then
		return self:adminRemove(p)
	end

	return self:adminSetStock(p, p2)
end

return EventShop