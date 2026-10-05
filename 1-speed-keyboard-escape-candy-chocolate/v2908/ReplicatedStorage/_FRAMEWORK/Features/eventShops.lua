local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local MessagingServiceManager = require(ReplicatedStorage._FRAMEWORK.Features.MessagingServiceManager)
local remo = require(ReplicatedStorage.Packages.remo)
local t = require(ReplicatedStorage.Packages.t)
local EventShop = require(script.EventShop)
local ShopView = require(script.ShopView)
require(script.Types)
local isServer = RunService:IsServer()
local DataManager

if isServer then
	DataManager = require(ServerScriptService.DataManager)
else
	DataManager = nil
end

local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local EventShops = {
	remotes = remo.createRemotes({
		eventShops = remo.namespace({
			requestState = remo.remote(t.string),
			buyWithCurrency = remo.remote(t.string, t.string).middleware(remo.throttleMiddleware(0.3)),
			buyWithRobux = remo.remote(t.string, t.string).middleware(remo.throttleMiddleware(0.3)),
			stateUpdate = remo.remote()
		})
	}).eventShops
}
local v = {}
local v2 = {}
local origin = ""
local count = 0
local v4 = nil
local v5 = {}

local function loadDefinitions()
	local modules = {}

	for _, moduleScript in script.shops:GetChildren() do
		local module = require(moduleScript)

		if module.enabled then
			table.insert(modules, module)
		end
	end

	return modules
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sendState(object, p, p2)
	local payload = object:buildPayload(p)

	if payload or p2 then
		EventShops.remotes.stateUpdate:fire(p, object.definition.id, payload, p2)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sendError(p, p2, error: string)
	EventShops.remotes.stateUpdate:fire(p2, p.definition.id, nil, {
		sound = "ERROR",
		error = error
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sendAllStates(k)
	for _, v6 in v do
		local payload = v6:buildPayload(k)

		if payload then
			EventShops.remotes.stateUpdate:fire(k, v6.definition.id, payload, nil)
		end
	end
end

local function broadcast(object, p)
	if not object:isActive() then
		p = nil
	end

	for _, v6 in Players:GetPlayers() do
		sendState(object, v6, p) -- equivalent call inferred; original call site unknown
	end
end

local function onRequestState(p, p2: string)
	local v6 = v[p2]

	if v6 then
		local payload = v6:buildPayload(p)

		if not payload then
			return
		end

		EventShops.remotes.stateUpdate:fire(p, v6.definition.id, payload, nil)
	end
end

local function onBuyWithCurrency(p, p2: string, p3: string)
	local v6 = v[p2]

	if v6 then
		local buyWithCurrency, error = v6:buyWithCurrency(p, p3)

		if buyWithCurrency then
			sendState(v6, p, {
				sound = "BUY"
			}) -- equivalent call inferred; original call site unknown
		else
			sendError(v6, p, error) -- equivalent call inferred; original call site unknown
		end
	end
end

local function onBuyWithRobux(p, p2: string, p3: string)
	local v6 = v[p2]

	if v6 then
		local v7, v8, error = v6:checkRobuxPurchase(p, p3)

		if v7 and v8 then
			v2[p.UserId] = v8
			MarketplaceService:PromptProductPurchase(p, v8.productId)
		else
			sendError(v6, p, error) -- equivalent call inferred; original call site unknown
		end
	end
end

local function onPromptFinished(p: number, p2: number, flag: boolean)
	local v6 = v2[p]

	if not flag and v6 and v6.productId == p2 then
		v2[p] = nil
	end
end

local function onAdminMessage(data)
	local v6 = v[data.shopId]

	if data.origin ~= origin and v6 then
		v6:applyAdminAction(data.action, data.stamp, data.issuedAt)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function relayAdminAction(p)
	v4.send(p):catch(function(p2)
		logger:warn(string.format("Admin action on %s did not reach other servers: %s", p.shopId, (tostring(p2))))
	end)
end

local function serverInit()
	origin = HttpService:GenerateGUID(false)

	for _, v6 in loadDefinitions() do
		local v7 = EventShop.new(v6)
		v[v6.id] = v7
		v7.changed:Connect(function(p)
			broadcast(v7, p)
		end)
	end

	EventShops.remotes.requestState:connect(onRequestState)
	EventShops.remotes.buyWithCurrency:connect(onBuyWithCurrency)
	EventShops.remotes.buyWithRobux:connect(onBuyWithRobux)
	MarketplaceService.PromptProductPurchaseFinished:Connect(onPromptFinished)
	DataManager.profileLoaded:Connect(sendAllStates)
	Players.PlayerRemoving:Connect(function(player)
		v2[player.UserId] = nil
	end)
	v4 = MessagingServiceManager.createMessageHandler("EventShopsAdmin")
	v4.connect(onAdminMessage)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function serverUpdate()
	local now = os.time()

	for _, v6 in v do
		v6:update(now)
	end
end

local function clientInit()
	for _, v6 in loadDefinitions() do
		local id = v6.id
		local id2 = id
		local id3 = id
		local v10 = ShopView.new(v6, {
			requestState = function()
				EventShops.remotes.requestState:fire(id)
			end,
			buyWithCurrency = function(self: string)
				EventShops.remotes.buyWithCurrency:fire(id2, self)
			end,
			buyWithRobux = function(p: string)
				EventShops.remotes.buyWithRobux:fire(id3, p)
			end
		})
		v5[id] = v10
		local zoneTag = v6.ui.zoneTag

		if not zoneTag then
			continue
		end

		for _, v11 in CollectionService:GetTagged(zoneTag) do
			v10:bindZone(v11)
		end

		local v11 = v10
		CollectionService:GetInstanceAddedSignal(zoneTag):Connect(function(p)
			v11:bindZone(p)
		end)
	end

	EventShops.remotes.stateUpdate:connect(function(p: string, p2, p3)
		local v6 = v5[p]

		if v6 then
			v6:receive(p2, p3)
		end
	end)
	Players.LocalPlayer.CharacterAdded:Connect(function()
		for _, v6 in v5 do
			v6:resetZone()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clientUpdate()
	for _, v6 in v5 do
		v6:update()
	end
end

function EventShops.getShopIds()
	local ids = {}

	for _, v6 in loadDefinitions() do
		table.insert(ids, v6.id)
	end

	table.sort(ids)
	return ids
end

function EventShops.getBaseSlotIds()
	local v6 = {}
	local result = {}

	for _, v7 in loadDefinitions() do
		for _, v8 in EventShop.getBaseSlotIds(v7) do
			if v6[v8] then
				continue
			end

			v6[v8] = true
			table.insert(result, v8)
		end
	end

	table.sort(result)
	return result
end

function EventShops:toggle()
	assert(not isServer, "eventShops: this function is client-only")
	local v6 = v5[self]

	if v6 then
		v6:toggle()
	else
		logger:warn(string.format("No enabled event shop view for '%s'", self))
	end
end

function EventShops.tryGrantRobux(p: number, p2: number)
	assert(isServer, "eventShops: this function is server-only")
	local v6 = v2[p]
	local playerByUserId = Players:GetPlayerByUserId(p)

	if v6 == nil or v6.productId ~= p2 then
		return false, false
	end

	if playerByUserId == nil then
		return true, false
	end

	local v7 = v[v6.shopId]
	local v8 = v7:grantRobuxPurchase(playerByUserId, v6)

	if not v8 then
		return true, v8
	end

	v2[p] = nil
	sendState(v7, playerByUserId, {
		sound = "BUY"
	}) -- equivalent call inferred; original call site unknown
	return true, v8
end

function EventShops.isGiftSource(p: string)
	assert(isServer, "eventShops: this function is server-only")
	local v6 = v[p]
	return v6 ~= nil and v6.definition.giftable
end

function EventShops:resolveGift(p2: string, p3: string, p4: string)
	assert(isServer, "eventShops: this function is server-only")
	local v6 = v[p2]

	if v6 then
		return v6:resolveGift(self, p3, p4)
	end

	return nil, "InvalidGiftSource"
end

function EventShops:consumeGift(p2: string, p3: string, p4: string, p5: number)
	assert(isServer, "eventShops: this function is server-only")
	local v6 = v[p2]

	if not v6 then
		return false, "InvalidGiftSource"
	end

	local v7, v8 = v6:consumeGift(self, p3, p4, p5)

	if not v7 then
		return v7, v8
	end

	local payload = v6:buildPayload(self)

	if not payload then
		return v7, v8
	end

	EventShops.remotes.stateUpdate:fire(self, v6.definition.id, payload, nil)
	return v7, v8
end

function EventShops.runAdminAction(shopId: string, action)
	assert(isServer, "eventShops: this function is server-only")
	local v6 = v[shopId]

	if not v6 then
		return
			false,
			string.format(
				"Unknown event shop '%s'. Enabled shops: %s",
				shopId,
				table.concat(EventShops.getShopIds(), ", ")
			)
	end

	count += 1
	local now = os.time()
	local stamp = now * 100 + count % 100
	local v8, v9 = v6:applyAdminAction(action, stamp, now)

	if v8 then
		relayAdminAction({
			origin = origin,
			shopId = shopId,
			action = action,
			stamp = stamp,
			issuedAt = now
		}) -- equivalent call inferred; original call site unknown
	end

	return v8, v9
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if isServer then
			serverInit()
		else
			clientInit()
		end
	end,
	OnStart = function()
		if isServer then
			for k in DataManager.Profiles do
				sendAllStates(k) -- equivalent call inferred; original call site unknown
			end
		end
	end,
	OnUpdate = function()
		if isServer then
			serverUpdate() -- equivalent call inferred; original call site unknown
		else
			clientUpdate() -- equivalent call inferred; original call site unknown
		end
	end
})
return EventShops