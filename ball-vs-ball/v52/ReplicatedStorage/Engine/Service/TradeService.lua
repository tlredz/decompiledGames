local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Net = require(ReplicatedStorage.Packages.Net)
local TradeQualificationService = require(script.Parent.TradeQualificationService)
local ItemService = require(script.Parent.ItemService)
local PlayerData = require(script.Parent.PlayerData)
local CurrencyService = require(script.Parent.CurrencyService)
local remoteEvent = Net:RemoteEvent("TradeRequest")
local remoteEvent2 = Net:RemoteEvent("TradeRespond")
local remoteEvent3 = Net:RemoteEvent("TradeOffer")
local remoteEvent4 = Net:RemoteEvent("TradeSetDiamonds")
local remoteEvent5 = Net:RemoteEvent("TradeAccept")
local remoteEvent6 = Net:RemoteEvent("TradeCancel")
local remoteEvent7 = Net:RemoteEvent("TradeState")
local remoteFunction = Net:RemoteFunction("TradeGetEligibility")
local remoteFunction2 = Net:RemoteFunction("TradeSetRequestsEnabled")

-- equivalent calls inferred from this helper; original call sites unknown
local function receivedAfterTax(p: number)
	return (math.floor(p * 0.95))
end

local function isValidDiamondAmount(value: number)
	return typeof(value) == "number" and value >= 0 and value == math.floor(value) and (value == 0 or math.floor(value * 0.95) > 0)
end

local v = {}

local function now()
	return Workspace:GetServerTimeNow()
end

local function inBattle(instance)
	return instance:GetAttribute("InDuelTable") == true
end

local function getRequestEligibility(p, playerByUserId)
	if not playerByUserId or playerByUserId.Parent ~= Players then
		return {
			ok = false,
			reason = "targetOffline"
		}
	end

	if playerByUserId == p then
		return {
			ok = false,
			reason = "selfTarget"
		}
	end

	PlayerData.server.Service:waitForData(p)
	PlayerData.server.Service:waitForData(playerByUserId)

	if p.Parent ~= Players or playerByUserId.Parent ~= Players then
		return {
			ok = false,
			reason = "targetOffline"
		}
	end

	for i, v2 in ipairs({ p, playerByUserId }) do
		local v3 = i == 1 and "self" or "target"

		if v2:GetAttribute("InDuelTable") == true then
			return {
				ok = false,
				reason = v3 .. "InBattle"
			}
		end

		if v2:GetAttribute("ModeTeleportPending") == true then
			return {
				ok = false,
				reason = v3 .. "Teleporting"
			}
		end

		if v[v2.UserId] then
			return {
				ok = false,
				reason = v3 .. "InTrade"
			}
		end

		local eligibility = TradeQualificationService.getEligibility(v2)

		if not eligibility.ok then
			return {
				ok = false,
				reason = v3 .. "Level",
				requiredLevel = eligibility.requiredLevel
			}
		end
	end

	if PlayerData.server[playerByUserId].tradeRequestsEnabled() == true then
		return {
			ok = true
		}
	end

	return {
		ok = false,
		reason = "requestsDisabled"
	}
end

local function other(p, p2)
	if p.a == p2 then
		return p.b
	end

	return p.a
end

local function clearSession(state)
	state.a:SetAttribute("InTrade", nil)
	state.b:SetAttribute("InTrade", nil)

	if v[state.a.UserId] == state then
		v[state.a.UserId] = nil
	end

	if v[state.b.UserId] == state then
		v[state.b.UserId] = nil
	end
end

local function itemsFor(p, list)
	local result = {}

	for _, instanceId in ipairs(list) do
		local v3 = PlayerData.server[p].items[instanceId]()

		if not v3 then
			continue
		end

		local v4 = {
			instanceId = instanceId,
			itemId = v3.itemId,
			itemType = v3.itemType,
			serial = v3.serial,
			killCount = 0
		}
		local killCount

		if typeof(v3.metadata) == "table" and typeof(v3.metadata.killCount) == "number" then
			killCount = v3.metadata.killCount
		end

		v4.killCount = killCount
		table.insert(result, v4)
	end

	return result
end

local function push(data, outcome: string?, insufficientUserId: number?)
	print((`[TradeDebug][Server] push state; id={data.id}; state={data.state}; a={data.a.UserId}; b={data.b.UserId}; outcome={tostring(outcome)}`))

	for _, player in ipairs({ data.a, data.b }) do
		if player.Parent == Players then
			remoteEvent7:FireClient(player, {
				id = data.id,
				state = data.state,
				endsAt = data.endsAt,
				outcome = outcome,
				insufficientUserId = insufficientUserId,
				you = player.UserId,
				inviter = data.a.UserId,
				a = {
					userId = data.a.UserId,
					name = data.a.DisplayName,
					offer = itemsFor(data.a, data.offer[data.a.UserId]),
					diamonds = data.offerDiamonds[data.a.UserId] or 0,
					accepted = data.accepted[data.a.UserId] == true
				},
				b = {
					userId = data.b.UserId,
					name = data.b.DisplayName,
					offer = itemsFor(data.b, data.offer[data.b.UserId]),
					diamonds = data.offerDiamonds[data.b.UserId] or 0,
					accepted = data.accepted[data.b.UserId] == true
				}
			})
		end
	end
end

local function release(data)
	for _, v2 in ipairs({ data.a, data.b }) do
		for _, v3 in ipairs(data.offer[v2.UserId]) do
			ItemService.server.clearLock(v2, v3, "trade")
		end
	end
end

local function cancel(state)
	if v[state.a.UserId] ~= state and v[state.b.UserId] ~= state then
		return
	end

	state.token += 1
	release(state)
	clearSession(state)
	state.state = "Cancelled"
	state.endsAt = nil
	push(state, "cancelled")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function schedule(state, duration: number, fn)
	state.token += 1
	local token = state.token
	task.delay(duration, function()
		if state.token == token and v[state.a.UserId] == state then
			fn()
		end
	end)
end

local function beginCooldown(state)
	state.state = "Cooldown"
	state.endsAt = Workspace:GetServerTimeNow() + 6
	state.accepted[state.a.UserId] = false
	state.accepted[state.b.UserId] = false
	push(state)

	local function fn()
		state.state = "Trading"
		state.endsAt = nil
		push(state)
	end

	schedule(state, 6, fn) -- equivalent call inferred; original call site unknown
end

local function allValid(data)
	for _, v2 in ipairs({ data.a, data.b }) do
		if v2.Parent ~= Players or v2:GetAttribute("InDuelTable") == true then
			return false
		end

		for _, v3 in ipairs(data.offer[v2.UserId]) do
			if not ItemService.server.canTrade(v2, v3, data.id) then
				return false
			end
		end
	end

	return true
end

local function hasAnyOffer(data)
	if #data.offer[data.a.UserId] > 0 or #data.offer[data.b.UserId] > 0 then
		return true
	end

	return (data.offerDiamonds[data.a.UserId] or 0) > 0 or (data.offerDiamonds[data.b.UserId] or 0) > 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tradeEconomyEvent()
	return {
		transactionType = Enum.AnalyticsEconomyTransactionType.ContextualPurchase.Name,
		sku = "在线交易",
		channel = "在线交易",
		mode = "PlayerTrade",
		isTransfer = true
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetToTrading(state, userId: number)
	state.token += 1
	state.state = "Trading"
	state.endsAt = nil
	state.accepted[state.a.UserId] = false
	state.accepted[state.b.UserId] = false
	push(state, "insufficientBalance", userId)
end

local function finish(state)
	if not (allValid(state) and hasAnyOffer(state)) then
		cancel(state)
		return
	end

	local diamondsA = state.offerDiamonds[state.a.UserId] or 0
	local diamondsB = state.offerDiamonds[state.b.UserId] or 0

	if CurrencyService.server.hasEnough(state.a, CurrencyService.ref.Diamonds, diamondsA) then
		if CurrencyService.server.hasEnough(state.b, CurrencyService.ref.Diamonds, diamondsB) then
			state.state = "Finalizing"
			state.endsAt = nil
			push(state)

			if not ItemService.server.transferBatch(
				state.a,
				state.offer[state.a.UserId],
				state.b,
				state.offer[state.b.UserId],
				state.id,
				{
					diamondsA = diamondsA,
					diamondsB = diamondsB
				}
			) then
				cancel(state)
				return
			end

			if diamondsA > 0 then
				CurrencyService.server.deduct(state.a, CurrencyService.ref.Diamonds, diamondsA, tradeEconomyEvent())
				local v4 = receivedAfterTax(diamondsA) -- equivalent call inferred; original call site unknown

				if v4 > 0 then
					CurrencyService.server.give(state.b, CurrencyService.ref.Diamonds, v4, {
						type = "exchange",
						arg = "在线交易"
					}, tradeEconomyEvent())
				end

				CurrencyService.server.recordFee(state.a, CurrencyService.ref.Diamonds, diamondsA - v4, "在线交易")
			end

			if diamondsB > 0 then
				CurrencyService.server.deduct(state.b, CurrencyService.ref.Diamonds, diamondsB, tradeEconomyEvent())
				local v4 = receivedAfterTax(diamondsB) -- equivalent call inferred; original call site unknown

				if v4 > 0 then
					CurrencyService.server.give(state.a, CurrencyService.ref.Diamonds, v4, {
						type = "exchange",
						arg = "在线交易"
					}, tradeEconomyEvent())
				end

				CurrencyService.server.recordFee(state.b, CurrencyService.ref.Diamonds, diamondsB - v4, "在线交易")
			end

			clearSession(state)
			state.state = "Completed"
			push(state, "completed")
		else
			resetToTrading(state, state.b.UserId) -- equivalent call inferred; original call site unknown
		end
	else
		resetToTrading(state, state.a.UserId) -- equivalent call inferred; original call site unknown
	end
end

remoteFunction.OnServerInvoke = function(p, value)
	if typeof(value) == "number" then
		return (getRequestEligibility(p, Players:GetPlayerByUserId(value)))
	end

	return {
		ok = false,
		reason = "invalidTarget"
	}
end

remoteFunction2.OnServerInvoke = function(instance, tradeRequestsEnabled)
	PlayerData.server.Service:waitForData(instance)

	if typeof(tradeRequestsEnabled) == "boolean" then
		if tradeRequestsEnabled and not TradeQualificationService.getEligibility(instance).ok then
			return {
				ok = false,
				enabled = PlayerData.server[instance].tradeRequestsEnabled() == true,
				reason = "ineligible"
			}
		end

		PlayerData.server[instance].tradeRequestsEnabled(tradeRequestsEnabled)
		instance:SetAttribute("TradeRequestsEnabled", tradeRequestsEnabled)
	end

	return {
		ok = true,
		enabled = PlayerData.server[instance].tradeRequestsEnabled() == true
	}
end

remoteEvent.OnServerEvent:Connect(function(instance, value)
	print((`[TradeDebug][Server] request received; player={instance.UserId}; target={tostring(value)}`))
	local playerByUserId

	if typeof(value) == "number" then
		playerByUserId = Players:GetPlayerByUserId(value)
	end

	local requestEligibility = getRequestEligibility(instance, playerByUserId)

	if not requestEligibility.ok then
		remoteEvent7:FireClient(instance, {
			state = "RequestRejected",
			reason = requestEligibility.reason,
			requiredLevel = requestEligibility.requiredLevel
		})
		return
	end

	assert(playerByUserId)
	local v2 = {
		id = "trade:" .. HttpService:GenerateGUID(false),
		a = instance,
		b = playerByUserId,
		state = "Inviting",
		offer = {
			[instance.UserId] = {},
			[playerByUserId.UserId] = {}
		},
		offerDiamonds = {
			[instance.UserId] = 0,
			[playerByUserId.UserId] = 0
		},
		accepted = {
			[instance.UserId] = false,
			[playerByUserId.UserId] = false
		},
		token = 0
	}
	v[instance.UserId] = v2
	v[playerByUserId.UserId] = v2
	instance:SetAttribute("InTrade", true)
	playerByUserId:SetAttribute("InTrade", true)
	print((`[TradeDebug][Server] session created; id={v2.id}; a={instance.UserId}; b={playerByUserId.UserId}`))
	v2.endsAt = Workspace:GetServerTimeNow() + 30
	push(v2)

	local function fn()
		cancel(v2)
	end

	schedule(v2, 30, fn) -- equivalent call inferred; original call site unknown
end)
remoteEvent2.OnServerEvent:Connect(function(p, p2)
	local v2 = v[p.UserId]

	if not v2 or v2.state ~= "Inviting" or p ~= v2.b then
		return
	end

	if p2 ~= true then
		cancel(v2)
		return
	end

	if not allValid(v2) then
		cancel(v2)
		return
	end

	v2.token += 1
	v2.state = "Trading"
	v2.endsAt = nil
	push(v2)
end)
remoteEvent3.OnServerEvent:Connect(function(p, list)
	local v2 = v[p.UserId]

	if not v2 or v2.state ~= "Trading" and v2.state ~= "Cooldown" or typeof(list) ~= "table" then
		return
	end

	local v3 = {}
	local v4 = {}

	for _, v5 in ipairs(list) do
		if typeof(v5) ~= "string" or v3[v5] or #v4 >= 4 then
			return
		end

		v3[v5] = true
		table.insert(v4, v5)
	end

	local v5 = v2.offer[p.UserId]
	local v6 = {}

	for _, v7 in ipairs(v5) do
		v6[v7] = true
	end

	local v7 = {}

	for _, v8 in ipairs(v4) do
		v7[v8] = true
	end

	for _, v8 in ipairs(v4) do
		if not (v6[v8] or ItemService.server.canTrade(p, v8)) then
			return
		end
	end

	for _, v8 in ipairs(v4) do
		if not v6[v8] then
			ItemService.server.setLock(p, v8, "trade", v2.id)
		end
	end

	for _, v8 in ipairs(v5) do
		if not v7[v8] then
			ItemService.server.clearLock(p, v8, "trade")
		end
	end

	v2.offer[p.UserId] = v4
	beginCooldown(v2)
end)
remoteEvent4.OnServerEvent:Connect(function(p, value)
	local v2 = v[p.UserId]

	if v2 and (v2.state == "Trading" or v2.state == "Cooldown") and typeof(value) == "number" then
		local v3

		if typeof(value) == "number" and value >= 0 and value == math.floor(value) then
			v3 = value == 0 or math.floor(value * 0.95) > 0
		else
			v3 = false
		end

		if v3 then
			if v2.offerDiamonds[p.UserId] == value then
				return
			end

			if CurrencyService.server.hasEnough(p, CurrencyService.ref.Diamonds, value) then
				v2.offerDiamonds[p.UserId] = value
				beginCooldown(v2)
			else
				v2.offerDiamonds[p.UserId] = 0
				beginCooldown(v2)
				push(v2, "insufficientBalance", p.UserId)
			end
		end
	end
end)
remoteEvent5.OnServerEvent:Connect(function(p)
	local v2 = v[p.UserId]

	if not v2 or v2.state ~= "Trading" or not (allValid(v2) and hasAnyOffer(v2)) then
		return
	end

	if not CurrencyService.server.hasEnough(p, CurrencyService.ref.Diamonds, v2.offerDiamonds[p.UserId] or 0) then
		push(v2, "insufficientBalance", p.UserId)
		return
	end

	v2.accepted[p.UserId] = true

	if not (v2.accepted[v2.a.UserId] and v2.accepted[v2.b.UserId]) then
		push(v2)
		return
	end

	v2.state = "FinalCountdown"
	v2.endsAt = Workspace:GetServerTimeNow() + 6
	push(v2)

	local function fn()
		finish(v2)
	end

	schedule(v2, 6, fn) -- equivalent call inferred; original call site unknown
end)
remoteEvent6.OnServerEvent:Connect(function(p)
	local v2 = v[p.UserId]

	if v2 then
		cancel(v2)
	end
end)

local function watch(instance)
	instance:GetAttributeChangedSignal("InDuelTable"):Connect(function()
		local v2 = instance:GetAttribute("InDuelTable") == true and v[instance.UserId]

		if v2 then
			cancel(v2)
		end
	end)
end

Players.PlayerAdded:Connect(watch)

for _, v2 in ipairs(Players:GetPlayers()) do
	local v3 = v2
	v2:GetAttributeChangedSignal("InDuelTable"):Connect(function()
		local v4 = v3:GetAttribute("InDuelTable") == true and v[v3.UserId]

		if v4 then
			cancel(v4)
		end
	end)
end

Players.PlayerRemoving:Connect(function(player)
	local v2 = v[player.UserId]

	if v2 then
		cancel(v2)
	end
end)
return {}