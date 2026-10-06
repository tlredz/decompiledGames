local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AnalyticsService = game:GetService("AnalyticsService")
local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
local PlayerData = require(script.Parent.PlayerData)
local AuditService = require(script.Parent.AuditService)
local remoteEvent = Net:RemoteEvent("CurrencyChanged")
local v = {}
local v2 = {}

local function fireListeners(items, ...)
	for _, callback in items do
		local success, result = pcall(callback, ...)

		if not success then
			warn("[CurrencyService] 经济事件回调出错: " .. tostring(result))
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function serverGetValueProxy(player, p: string)
	PlayerData.server.Service:waitForData(player)
	return PlayerData.server[player][p]
end

local function serverHasEnough(p, p2: string, p3: number)
	PlayerData.server.Service:waitForData(p)
	return p3 <= PlayerData.server[p][p2]()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function serverNotify(player, p: string, p2: number, p3: number, p4)
	remoteEvent:FireClient(player, p, p2, p3, p4)
end

local function reportEconomyEvent(player, p, p2: string, p3: number, p4: number, data)
	if not data then
		return
	end

	local v3 = p == Enum.AnalyticsEconomyFlowType.Source and "来源" or "消耗"
	local v4 = string.format(
		"[经济分析] %s | 玩家=%s | 货币=%s | 数量=%d | 余额=%d | 类型=%s | SKU=%s | 渠道=%s | 玩法=%s",
		v3,
		player.Name,
		p2,
		p3,
		p4,
		data.transactionType,
		data.sku,
		data.channel,
		data.mode
	)

	if RunService:IsStudio() then
		print(v4 .. " | Studio 跳过上报")
		return
	end

	local success, result = pcall(function()
		AnalyticsService:LogEconomyEvent(player, p, p2, p3, p4, data.transactionType, data.sku, {
			[Enum.AnalyticsCustomFieldKeys.CustomField01.Name] = "渠道:" .. data.channel,
			[Enum.AnalyticsCustomFieldKeys.CustomField02.Name] = "玩法:" .. data.mode
		})
	end)

	if success then
		print(v4)
	else
		warn(v4 .. " | 上报失败: " .. tostring(result))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function describeSource(p, p2)
	if p2 then
		return p2.sku
	end

	if p then
		return (`{p.type}:{p.arg}`)
	end

	return "unknown"
end

local function serverGive(player, assetId: string, delta: number, p3, p4)
	if delta <= 0 then
		return false
	end

	local after = (serverGetValueProxy(player, assetId))(function(p5: number)
		return p5 + delta
	end)
	local record = AuditService.record
	local v4 = {
		assetType = "currency",
		assetId = assetId,
		action = "grant",
		delta = delta,
		before = after - delta,
		after = after,
		source = 0,
		channel = 0,
		mode = 0
	}
	local source = describeSource(p3, p4) -- equivalent call inferred; original call site unknown
	v4.source = source
	v4.channel = p4 and p4.channel
	v4.mode = p4 and p4.mode
	record(player, v4)
	serverNotify(player, assetId, delta, after, p3) -- equivalent call inferred; original call site unknown
	reportEconomyEvent(player, Enum.AnalyticsEconomyFlowType.Source, assetId, delta, after, p4)
	return true
end

local function serverDeduct(player, assetId: string, p2: number, data)
	if p2 <= 0 then
		return false
	end

	local after = (serverGetValueProxy(player, assetId))(function(p3: number)
		return p3 - p2
	end)
	AuditService.record(player, {
		assetType = "currency",
		assetId = assetId,
		action = "spend",
		delta = -p2,
		before = after + p2,
		after = after,
		source = not data and "unknown" or data.sku,
		channel = data and data.channel,
		mode = data and data.mode
	})
	serverNotify(player, assetId, -p2, after, nil) -- equivalent call inferred; original call site unknown
	reportEconomyEvent(player, Enum.AnalyticsEconomyFlowType.Sink, assetId, p2, after, data)

	if not data or data.isTransfer ~= true then
		fireListeners(v, player, assetId, p2, data)
	end

	return true
end

local function serverRecordFee(p, p2: string, p3: number, p4: string)
	if p3 <= 0 then
		return
	end

	fireListeners(v2, p, p2, p3, p4)
end

local function serverOnSpent(callback)
	table.insert(v, callback)
end

local function serverOnFeeCollected(callback)
	table.insert(v2, callback)
end

local function serverTrySpend(p, assetId: string, p3: number, p4)
	PlayerData.server.Service:waitForData(p)
	return p3 <= PlayerData.server[p][assetId]() and serverDeduct(p, assetId, p3, p4)
end

local function clientGet(p: string)
	return PlayerData.client[p]()
end

local function clientOnChanged(onOnClientEvent)
	remoteEvent.OnClientEvent:Connect(onOnClientEvent)
end

return {
	ref = {
		Coins = "coins",
		Diamonds = "diamonds"
	},
	server = {
		hasEnough = serverHasEnough,
		give = serverGive,
		deduct = serverDeduct,
		trySpend = serverTrySpend,
		recordFee = serverRecordFee,
		onSpent = serverOnSpent,
		onFeeCollected = serverOnFeeCollected
	},
	client = {
		get = clientGet,
		onChanged = clientOnChanged
	}
}