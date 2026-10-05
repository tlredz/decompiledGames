local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

if not RunService:IsServer() then
	return {}
end

local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local Config = require(ReplicatedStorage.Config)
local DataManager = require(ServerScriptService.DataManager)
local TradingServerConfig = require(ServerScriptService._FRAMEWORK.ServerLibraries.TradingServerConfig)
local Config2 = require(script.Parent.Config)
require(script.Parent.Types)
local TradingContract = {}
TradingContract.__index = TradingContract
TradingContract.ProcessResult = table.freeze({
	Noop = 1,
	Completed = 2,
	FailedOwnership = 3,
	PartiesInvalid = 4
})
TradingContract.CloseReason = table.freeze({
	Completed = 1,
	Cancelled = 2
})

local function copyEntry(p)
	return Items.CopyEntry(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function randomProcessDelay()
	local contractProcessDelayMin = TradingServerConfig.ContractProcessDelayMin
	return contractProcessDelayMin + math.random() * (TradingServerConfig.ContractProcessDelayMax - contractProcessDelayMin)
end

local function matchesSelector(p, p2: string, p3: number, p4: number?, p5: number?)
	if Items.KeyOf(p) ~= p2 or Items.TierOf(p) ~= p3 then
		return false
	end

	if not Items.IsLimitedKey(p2) then
		return Items.SignatureOf(p) == p5
	end

	return p4 ~= nil and Items.LimitedNumberOf(p) == p4 and Items.SignatureOf(p) == p5
end

local function removeFirstMatching(clone, p)
	for i, v in ipairs(clone) do
		if not Items.EntriesMatch(v, p) then
			continue
		end

		table.remove(clone, i)
		return true
	end

	return false
end

local function getUnequippedItems(p)
	local store = DataManager:GetStore(p, "Items")
	local selected = store and store:Get({})

	if type(selected) == "table" then
		return selected
	end

	return {}
end

local function pushItemsUpdate(player)
	local store = DataManager:GetStore(player, "Items")
	local store2 = DataManager:GetStore(player, "EquippedItems")
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local itemAction = remotes and remotes:FindFirstChild("ItemAction")

	if store and store2 and itemAction then
		itemAction:FireClient(player, "Update", {
			Items = store:Get({}),
			EquippedItems = store2:Get({})
		})
	end
end

local function inventoryHasOffer(p, list)
	local clone = table.clone((getUnequippedItems(p)))

	for _, v in ipairs(list) do
		if not removeFirstMatching(clone, v) then
			return false
		end
	end

	return true
end

local function removeOfferFromInventory(p, clone)
	local store = DataManager:GetStore(p, "Items")

	if not (store and inventoryHasOffer(p, clone)) then
		return false
	end

	local clone2 = table.clone(store:Get({}))

	for _, v in ipairs(clone) do
		removeFirstMatching(clone2, v)
	end

	store:Set(clone2)
	return true
end

local function grantOffer(p, clone)
	local store = DataManager:GetStore(p, "Items")

	if not store then
		return false
	end

	local v = store:Get({})
	local v2 = type(v) ~= "table" and {} or table.clone(v)

	for _, v3 in ipairs(clone) do
		table.insert(v2, copyEntry(v3))
	end

	store:Set(v2)
	return true
end

local function recordTradeHistory(p, p2, id: string, clone, clone2)
	local store = DataManager:GetStore(p, "TradeHistory")

	if store then
		local v = store:Get({})
		local v2 = type(v) ~= "table" and {} or v
		local given = {}
		local received = {}

		for _, v5 in ipairs(clone) do
			table.insert(given, copyEntry(v5))
		end

		for _, v5 in ipairs(clone2) do
			table.insert(received, copyEntry(v5))
		end

		table.insert(v2, {
			ContractId = id,
			OtherUserId = p2.UserId,
			WorldIndex = Config.WORLD,
			Given = given,
			Received = received,
			Timestamp = os.time()
		})

		while #v2 > Config2.TradeHistoryCap do
			table.remove(v2, 1)
		end

		store:Set(v2)
	end
end

function TradingContract.new(id: string, p2, p3)
	return (setmetatable({
		id = id,
		parties = {
			[p2] = {
				offer = {},
				ready = false
			},
			[p3] = {
				offer = {},
				ready = false
			}
		},
		version = 1,
		processAt = nil,
		destroyed = false,
		onChanged = nil
	}, TradingContract))
end

function TradingContract.IsParty(p, p2)
	return p.parties[p2] ~= nil
end

function TradingContract.GetOther(p, p2)
	for k in pairs(p.parties) do
		if k ~= p2 then
			return k
		end
	end

	return nil
end

function TradingContract.GetParty(p, p2)
	return p.parties[p2]
end

function TradingContract:ClearReadyState()
	for _, party in pairs(self.parties) do
		party.ready = false
	end

	self.processAt = nil
end

function TradingContract:_bumpAndNotify()
	self.version += 1
	self:ClearReadyState()

	if self.onChanged then
		self.onChanged(self)
	end
end

function TradingContract:AddOfferItem(p, p2: string, p3: number, p4: number?, p5: number?)
	local party = self.parties[p]

	if self.destroyed or not party or #party.offer >= Config2.MaxOfferItems then
		return false
	end

	local clone = table.clone((getUnequippedItems(p)))

	for _, v in ipairs(party.offer) do
		removeFirstMatching(clone, v)
	end

	for _, v in ipairs(clone) do
		if not matchesSelector(v, p2, p3, p4, p5) then
			continue
		end

		table.insert(party.offer, copyEntry(v))
		self:_bumpAndNotify()
		return true
	end

	return false
end

function TradingContract:RemoveOfferItem(p, p2: string, p3: number, p4: number?, p5: number?)
	local party = self.parties[p]

	if self.destroyed or not party then
		return false
	end

	for i, v in ipairs(party.offer) do
		if not matchesSelector(v, p2, p3, p4, p5) then
			continue
		end

		table.remove(party.offer, i)
		self:_bumpAndNotify()
		return true
	end

	return false
end

function TradingContract:SetReady(p, ready: boolean)
	local party = self.parties[p]

	if self.destroyed or not party or ready and not (#party.offer >= Config2.MinOfferItems) then
		return false
	end

	party.ready = ready
	local flag = true

	for _, party2 in pairs(self.parties) do
		if party2.ready then
			continue
		end

		flag = false
		break
	end

	local processAt

	if flag then
		processAt = Workspace:GetServerTimeNow() + randomProcessDelay()
	end

	self.processAt = processAt
	self.version += 1

	if self.onChanged then
		self.onChanged(self)
	end

	return true
end

function TradingContract.BuildSnapshot(data)
	local parties = {}

	for k, party in pairs(data.parties) do
		local offer = {}

		for _, v3 in ipairs(party.offer) do
			table.insert(offer, copyEntry(v3))
		end

		parties[k.UserId] = {
			userId = k.UserId,
			name = k.Name,
			displayName = k.DisplayName,
			offer = offer,
			ready = party.ready
		}
	end

	return {
		contractId = data.id,
		version = data.version,
		processing = data.processAt ~= nil,
		parties = parties
	}
end

function TradingContract:BothReadyWithOffers()
	for _, party in pairs(self.parties) do
		if not party.ready or #party.offer < Config2.MinOfferItems then
			return false
		end
	end

	return true
end

function TradingContract:Process()
	local processResult = TradingContract.ProcessResult
	local v = not self.destroyed

	if v then
		if self.processAt == nil or not (Workspace:GetServerTimeNow() >= self.processAt) then
			v = false
		else
			v = self:BothReadyWithOffers()
		end
	end

	if not v then
		return processResult.Noop
	end

	local v2 = {}

	for k in pairs(self.parties) do
		table.insert(v2, k)
	end

	if #v2 ~= 2 or not (v2[1].Parent and v2[2].Parent) then
		return processResult.PartiesInvalid
	end

	local v3 = v2[1]
	local v4 = v2[2]
	local clone = table.clone(self.parties[v3].offer)
	local clone2 = table.clone(self.parties[v4].offer)

	if inventoryHasOffer(v3, clone) and inventoryHasOffer(v4, clone2) then
		removeOfferFromInventory(v3, clone)
		removeOfferFromInventory(v4, clone2)
		local v5 = grantOffer(v3, clone2)
		local v6 = grantOffer(v4, clone)

		if not (v5 and v6) then
			error("Trading grant failed after validated inventory removal")
		end

		pushItemsUpdate(v3)
		pushItemsUpdate(v4)
		recordTradeHistory(v3, v4, self.id, clone, clone2)
		recordTradeHistory(v4, v3, self.id, clone2, clone)
		return processResult.Completed
	else
		self:ClearReadyState()
		self.version += 1

		if self.onChanged then
			self.onChanged(self)
		end

		return processResult.FailedOwnership
	end
end

function TradingContract:Destroy()
	if self.destroyed then
		return
	end

	self.destroyed = true
	self.processAt = nil

	for _, party in pairs(self.parties) do
		table.clear(party.offer)
		party.ready = false
	end
end

return TradingContract