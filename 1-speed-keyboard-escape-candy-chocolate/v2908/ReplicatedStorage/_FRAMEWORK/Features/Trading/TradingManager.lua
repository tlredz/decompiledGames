local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

if not RunService:IsServer() then
	return {}
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local AsyncUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.AsyncUtils)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local DataManager = require(ServerScriptService.DataManager)
local SettingsManager = require(ServerScriptService.SettingsManager)
local TradingContract = require(script.Parent.TradingContract)
local Config = require(script.Parent.Config)
require(script.Parent.Types)
local logger = LoggerManager.createLogger("TradingManager", {
	feature = script:GetFullName()
})
local v = {
	notInServer = Config.InfoFeedback.NotInServer,
	policyBlocked = Config.InfoFeedback.PolicyBlocked,
	tradeBanned = Config.InfoFeedback.TradeBanned,
	targetTradeBanned = Config.InfoFeedback.TargetTradeBanned,
	requestsDisabled = Config.InfoFeedback.RequestsDisabled,
	alreadyTrading = Config.InfoFeedback.AlreadyTrading,
	outboundCap = Config.InfoFeedback.OutboundCap
}
local contractChanged = Signal.new()
local v3 = nil
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local TradingManager = {
	contractChanged = contractChanged
}

-- equivalent calls inferred from this helper; original call sites unknown
local function fireInfo(p, data)
	if v3 then
		v3.showInfo:fire(p, {
			title = data.title,
			description = data.description,
			confirmText = data.confirmText,
			buttonStyle = data.buttonStyle or "Neutral"
		})
	end
end

local function countOutbound(p)
	local count = 0

	for _, v8 in ipairs(v6) do
		if v8.from == p then
			count += 1
		end
	end

	return count
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findPending(p, playerByUserId)
	for _, v8 in ipairs(v6) do
		if v8.from == p and v8.to == playerByUserId then
			return v8
		end
	end

	return nil
end

local function removePending(playerByUserId, p)
	for i = #v6, 1, -1 do
		local v8 = v6[i]

		if v8.from == playerByUserId and v8.to == p then
			table.remove(v6, i)
		end
	end
end

local function removeAllPendingFor(p)
	for i = #v6, 1, -1 do
		local v8 = v6[i]

		if v8.from == p or v8.to == p then
			table.remove(v6, i)
		end
	end
end

local function isBlockedBy(p, p2)
	local v8 = v7[p.UserId]
	return v8 ~= nil and v8[p2.UserId] == true
end

local function isTradeBanned(p)
	local store = DataManager:GetStore(p, "TradeBanned")
	return store ~= nil and store:Get(false) == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function policyAllows(playerByUserId)
	return AsyncUtils.fetchPaidItemTradingAllowed(playerByUserId):expect() == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function canReceiveRequests(playerByUserId)
	return SettingsManager:Get(playerByUserId, "DisableTradeRequests") ~= true
end

local function broadcastSnapshot(object, flag: boolean)
	if v3 and not object.destroyed then
		local snapshot = object:BuildSnapshot()
		local contractOpened

		if flag then
			contractOpened = v3.contractOpened
		else
			contractOpened = v3.contractUpdated
		end

		for k in pairs(object.parties) do
			contractOpened:fire(k, snapshot)
		end
	end
end

local function destroyContract(instance, p, p2)
	if instance.destroyed then
		return
	end

	local v8 = {}

	for k in pairs(instance.parties) do
		table.insert(v8, k)
		v4[k] = nil
	end

	v5[instance.id] = nil
	instance:Destroy()

	for _, v9 in ipairs(v8) do
		contractChanged:Fire(v9, false)
	end

	if v3 then
		for _, v9 in ipairs(v8) do
			if v9.Parent then
				v3.contractClosed:fire(v9, p)
			end
		end
	end

	if p2 and p == TradingContract.CloseReason.Cancelled then
		local v9 = nil

		for _, v10 in ipairs(v8) do
			if v10 ~= p2 then
				v9 = v10
			end
		end

		if v9 and v9.Parent then
			fireInfo(v9, Config.InfoFeedback.TradeCancelled) -- equivalent call inferred; original call site unknown
		end
	end
end

local function handleProcessResult(p, p2)
	local processResult = TradingContract.ProcessResult
	local closeReason = TradingContract.CloseReason

	if p2 == processResult.Completed then
		local v8 = {}

		for k in pairs(p.parties) do
			table.insert(v8, k)
		end

		local id = p.id
		destroyContract(p, closeReason.Completed, nil)

		for _, v9 in ipairs(v8) do
			if not v9.Parent then
				continue
			end

			fireInfo(v9, Config.InfoFeedback.TradeSuccess) -- equivalent call inferred; original call site unknown
		end

		logger:info((`Trade completed contractId={id}`))
	elseif p2 == processResult.FailedOwnership then
		logger:warn((`Trade process failed ownership check contractId={p.id}`))
	elseif p2 == processResult.PartiesInvalid then
		destroyContract(p, closeReason.Cancelled, nil)
	end
end

local function createContract(p, p2)
	local GUID = HttpService:GenerateGUID(false)
	local v8 = TradingContract.new(GUID, p, p2)

	function v8.onChanged(p3)
		broadcastSnapshot(p3, false)
	end

	v5[GUID] = v8
	v4[p] = v8
	v4[p2] = v8
	broadcastSnapshot(v8, true)
	contractChanged:Fire(p, true)
	contractChanged:Fire(p2, true)
	return v8
end

local function checkRequestTradeReady(p, p2: number)
	if p2 == p.UserId then
		return false, nil, nil
	end

	local playerByUserId = Players:GetPlayerByUserId(p2)

	if not playerByUserId then
		return false, nil, "notInServer"
	end

	if v4[p] then
		return false, nil, nil
	end

	-- equivalent call inferred; original call site unknown
	if findPending(p, playerByUserId) then
		return false, nil, nil
	end

	local store = DataManager:GetStore(p, "TradeBanned")
	local v8

	if store == nil then
		v8 = false
	else
		v8 = store:Get(false) == true
	end

	if v8 then
		return false, nil, "tradeBanned"
	end

	if AsyncUtils.fetchPaidItemTradingAllowed(p):expect() ~= true then
		return false, nil, "policyBlocked"
	end

	local store2 = DataManager:GetStore(playerByUserId, "TradeBanned")
	local v9

	if store2 == nil then
		v9 = false
	else
		v9 = store2:Get(false) == true
	end

	if v9 then
		return false, nil, "targetTradeBanned"
	end

	if not (policyAllows(playerByUserId) and canReceiveRequests(playerByUserId)) then
		return false, nil, "requestsDisabled"
	end

	local v10 = v7[playerByUserId.UserId]
	local v11

	if v10 == nil then
		v11 = false
	else
		v11 = v10[p.UserId] == true
	end

	if v11 then
		return false, nil, "requestsDisabled"
	end

	if v4[playerByUserId] then
		return false, nil, "alreadyTrading"
	end

	local count = 0

	for _, v12 in ipairs(v6) do
		if v12.from == p then
			count += 1
		end
	end

	if Config.MaxOutboundRequests <= count then
		return false, nil, "outboundCap"
	end

	return true, playerByUserId, nil
end

local function sendPendingTradeRequest(player, to)
	table.insert(v6, {
		from = player,
		to = to,
		expiresAt = Workspace:GetServerTimeNow() + Config.RequestExpireSeconds
	})

	if v3 then
		v3.tradeRequest:fire(to, {
			userId = player.UserId,
			name = player.Name,
			displayName = player.DisplayName
		})
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyBlock(p, playerByUserId)
	local v8 = v7[p.UserId]

	if not v8 then
		v8 = {}
		v7[p.UserId] = v8
	end

	v8[playerByUserId.UserId] = true
	fireInfo(playerByUserId, Config.InfoFeedback.RequestDeclined) -- equivalent call inferred; original call site unknown
end

local function acceptTradeRequest(p, playerByUserId)
	if v4[p] or v4[playerByUserId] or not (playerByUserId.Parent and p.Parent) then
		fireInfo(p, Config.InfoFeedback.AlreadyTrading) -- equivalent call inferred; original call site unknown
	else
		local store = DataManager:GetStore(playerByUserId, "TradeBanned")
		local v8

		if store == nil then
			v8 = false
		else
			v8 = store:Get(false) == true
		end

		local targetTradeBanned

		if v8 then
			targetTradeBanned = Config.InfoFeedback.TargetTradeBanned
			fireInfo(p, targetTradeBanned) -- equivalent call inferred; original call site unknown
		else
			local store2 = DataManager:GetStore(p, "TradeBanned")
			local v9

			if store2 == nil then
				v9 = false
			else
				v9 = store2:Get(false) == true
			end

			if v9 then
				targetTradeBanned = Config.InfoFeedback.TargetTradeBanned
				fireInfo(p, targetTradeBanned) -- equivalent call inferred; original call site unknown
			elseif policyAllows(playerByUserId) and policyAllows(p) then
				removeAllPendingFor(playerByUserId)
				removeAllPendingFor(p)
				createContract(playerByUserId, p)
			else
				fireInfo(p, Config.InfoFeedback.TargetCannotTrade) -- equivalent call inferred; original call site unknown
			end
		end
	end
end

function TradingManager.bindRemotes(p)
	v3 = p
end

function TradingManager.isInContract(p)
	return v4[p] ~= nil
end

function TradingManager.onPlayerReady(p)
	AsyncUtils.fetchPaidItemTradingAllowed(p)
end

function TradingManager.onPlayerRemoving(p)
	local v8 = v4[p]

	if v8 then
		local other = v8:GetOther(p)
		destroyContract(v8, TradingContract.CloseReason.Cancelled, nil)

		if other and other.Parent then
			fireInfo(other, Config.InfoFeedback.TradeCancelled) -- equivalent call inferred; original call site unknown
		end
	end

	removeAllPendingFor(p)
	v7[p.UserId] = nil
	AsyncUtils.clearPaidItemTradingAllowed(p.UserId)
end

function TradingManager.update()
	local serverTimeNow = Workspace:GetServerTimeNow()

	for i = #v6, 1, -1 do
		if v6[i].expiresAt <= serverTimeNow then
			table.remove(v6, i)
		end
	end

	local v8 = {}

	for _, v9 in pairs(v5) do
		if v9.processAt and v9.processAt <= serverTimeNow then
			table.insert(v8, v9)
		end
	end

	for _, v9 in ipairs(v8) do
		handleProcessResult(v9, v9:Process())
	end
end

function TradingManager.playerCanTrade(p)
	local store = DataManager:GetStore(p, "TradeBanned")
	return (store == nil or store:Get(false) ~= true) and policyAllows(p)
end

function TradingManager.isTradeBanned(p)
	local store = DataManager:GetStore(p, "TradeBanned")
	return store ~= nil and store:Get(false) == true
end

function TradingManager.setTradeBanned(p, flag: boolean)
	local store = DataManager:GetStore(p, "TradeBanned")

	if not store then
		return false
	end

	store:Set(flag == true)

	if not flag then
		return true
	end

	local v8 = v4[p]

	if v8 then
		local other = v8:GetOther(p)
		destroyContract(v8, TradingContract.CloseReason.Cancelled, nil)

		if other and other.Parent then
			fireInfo(other, Config.InfoFeedback.TradeCancelled) -- equivalent call inferred; original call site unknown
		end
	end

	removeAllPendingFor(p)
	return true
end

function TradingManager.openTargetModalFor(p)
	local store = DataManager:GetStore(p, "TradeBanned")
	local v8

	if store == nil then
		v8 = false
	else
		v8 = store:Get(false) == true
	end

	if v8 then
		fireInfo(p, Config.InfoFeedback.TradeBanned) -- equivalent call inferred; original call site unknown
	elseif policyAllows(p) then
		if v3 then
			v3.openTargetModal:fire(p)
		end
	else
		fireInfo(p, Config.InfoFeedback.PolicyBlocked) -- equivalent call inferred; original call site unknown
	end
end

function TradingManager.queryTarget(p, p2: number)
	if p2 == p.UserId then
		return {
			found = false,
			canTrade = false,
			reason = "self"
		}
	end

	local playerByUserId = Players:GetPlayerByUserId(p2)

	if not playerByUserId then
		return {
			found = false,
			canTrade = false,
			reason = "notFound"
		}
	end

	local v8 = policyAllows(playerByUserId) -- equivalent call inferred; original call site unknown
	local v9 = canReceiveRequests(playerByUserId) -- equivalent call inferred; original call site unknown
	local store = DataManager:GetStore(playerByUserId, "TradeBanned")
	local v10

	if store == nil then
		v10 = false
	else
		v10 = store:Get(false) == true
	end

	local v11 = v4[playerByUserId] ~= nil
	return {
		found = true,
		canTrade = not v10 and v8 and v9 and not v11,
		userId = playerByUserId.UserId,
		name = playerByUserId.Name,
		displayName = playerByUserId.DisplayName,
		reason = v10 and "banned" or not (v8 and v9) and "disabled" or v11 and "busy" or nil
	}
end

function TradingManager.requestTrade(from, p2: number)
	local v8, to, v10 = checkRequestTradeReady(from, p2)

	if v8 then
		sendPendingTradeRequest(from, to)
	elseif v10 and v[v10] then
		fireInfo(from, v[v10]) -- equivalent call inferred; original call site unknown
	end
end

function TradingManager.respondRequest(p, p2: number, p3: string)
	local playerByUserId = Players:GetPlayerByUserId(p2)
	local v8

	if playerByUserId then
		for _, v10 in ipairs(v6) do
			if not (v10.from == playerByUserId and v10.to == p) then
				continue
			end

			v8 = v10
			break
		end
	else
		v8 = playerByUserId
	end

	if playerByUserId and v8 then
		removePending(playerByUserId, p)

		if p3 == "Block" then
			applyBlock(p, playerByUserId) -- equivalent call inferred; original call site unknown
		elseif p3 == "Decline" then
			fireInfo(playerByUserId, Config.InfoFeedback.RequestDeclined) -- equivalent call inferred; original call site unknown
		elseif p3 == "Accept" then
			acceptTradeRequest(p, playerByUserId)
		end
	elseif p3 == "Accept" and (v4[p] or playerByUserId ~= nil and v4[playerByUserId] ~= nil) then
		fireInfo(p, Config.InfoFeedback.AlreadyTrading) -- equivalent call inferred; original call site unknown
	end
end

function TradingManager.addOfferItem(p, p2: string, p3: number, p4: number?, p5: number?)
	local v8 = v4[p]

	if v8 and Items.ITEMS[p2] then
		v8:AddOfferItem(p, p2, p3, p4, p5)
	end
end

function TradingManager.removeOfferItem(p, p2: string, p3: number, p4: number?, p5: number?)
	local v8 = v4[p]

	if v8 then
		v8:RemoveOfferItem(p, p2, p3, p4, p5)
	end
end

function TradingManager.setReady(p, flag: boolean)
	local v8 = v4[p]

	if v8 then
		v8:SetReady(p, flag)
	end
end

function TradingManager.cancelContract(p)
	local v8 = v4[p]

	if v8 then
		destroyContract(v8, TradingContract.CloseReason.Cancelled, p)
	end
end

return TradingManager