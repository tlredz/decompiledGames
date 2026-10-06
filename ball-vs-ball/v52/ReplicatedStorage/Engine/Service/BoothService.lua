local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Net = require(ReplicatedStorage.Packages.Net)
local ServerTeleport = require(ReplicatedStorage.Packages.ServerTeleport)
local PlayerData = require(script.Parent.PlayerData)
local AuditService = require(script.Parent.AuditService)
local ItemService = require(script.Parent.ItemService)
local CurrencyService = require(script.Parent.CurrencyService)
local TimeService = require(script.Parent.TimeService)
local ServerTypeService = require(script.Parent.ServerTypeService)
local RAPService = require(script.Parent.RAPService)
local Leaderboard = require(script.Parent.Leaderboard)
local SerialRegistryService = require(script.Parent.SerialRegistryService)
local flag = false

local function referencedItemId(value)
	if typeof(value) == "string" then
		return value
	end

	if typeof(value) == "table" and value.kind == "flyer" and typeof(value.id) == "string" then
		return value.id
	end

	return nil
end

local v = {}
local v2 = {}
local remoteEvent = Net:RemoteEvent("BoothSellerChanged")
local remoteEvent2 = Net:RemoteEvent("BoothStateChanged")
local remoteEvent3 = Net:RemoteEvent("BoothOpenPanel")
local remoteFunction = Net:RemoteFunction("BoothListRequest")
local remoteFunction2 = Net:RemoteFunction("BoothUnlistRequest")
local remoteFunction3 = Net:RemoteFunction("BoothCloseRequest")
local remoteFunction4 = Net:RemoteFunction("BoothPurchaseRequest")
local remoteEvent4 = Net:RemoteEvent("BoothItemSold")
local remoteFunction5 = Net:RemoteFunction("BoothGetSellerListings")
local remoteFunction6 = Net:RemoteFunction("BoothGetAllStates")

-- equivalent calls inferred from this helper; original call sites unknown
local function findStallOwnedBy(p: number)
	for k, v3 in v do
		if v3.ownerUserId == p then
			return k
		end
	end

	return nil
end

local function buildDisplayListings(p)
	local boothListings = PlayerData.server[p].boothListings()
	local items = PlayerData.server[p].items()
	local result = {}

	for k, boothListing in boothListings do
		local item = items[boothListing.itemInstanceId]

		if item then
			table.insert(result, {
				listingId = k,
				itemInstanceId = boothListing.itemInstanceId,
				itemType = item.itemType,
				itemId = item.itemId,
				serial = item.serial,
				price = boothListing.price,
				listedAt = boothListing.listedAt
			})
		end
	end

	table.sort(result, function(a, b)
		return (a.listedAt or 0) < (b.listedAt or 0)
	end)
	return result
end

local function hasEquippedSign(playerByUserId)
	local character = playerByUserId.Character

	if not character then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return false
	end

	for _, tool in character:GetChildren() do
		if tool:IsA("Tool") and tool.Name == "手持展牌" then
			return true
		end
	end

	return false
end

local function buildSellerPayload(p)
	return {
		ownerUserId = p.UserId,
		ownerName = p.Name,
		totalSold = PlayerData.server[p].boothTotalSold(),
		listings = buildDisplayListings(p),
		version = v2[p.UserId] or 0
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function broadcastSeller(p)
	v2[p.UserId] = (v2[p.UserId] or 0) + 1
	remoteEvent:FireAllClients((buildSellerPayload(p)))
end

local function buildStallPayload(p: number)
	local v3 = v[p]

	if not v3 then
		return nil
	end

	local ownerUserId = v3.ownerUserId
	local v4 = {
		index = p,
		stallName = v3.model.Name,
		ownerUserId = nil,
		ownerName = nil,
		totalSold = 0,
		listings = {}
	}
	local playerByUserId = ownerUserId and Players:GetPlayerByUserId(ownerUserId)

	if not playerByUserId then
		return v4
	end

	v4.ownerUserId = ownerUserId
	v4.ownerName = playerByUserId.Name
	v4.totalSold = PlayerData.server[playerByUserId].boothTotalSold()
	v4.listings = buildDisplayListings(playerByUserId)
	return v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function broadcastStallState(p: number)
	local stallPayload = buildStallPayload(p)

	if stallPayload then
		remoteEvent2:FireAllClients(stallPayload)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseStall(stallOwnedBy: number)
	local v3 = v[stallOwnedBy]

	if not (v3 and v3.ownerUserId) then
		return
	end

	local playerByUserId = Players:GetPlayerByUserId(v3.ownerUserId)
	v3.ownerUserId = nil

	if playerByUserId then
		playerByUserId:SetAttribute("BoothHasStall", false)
	end

	broadcastStallState(stallOwnedBy) -- equivalent call inferred; original call site unknown
end

local function onPromptTriggered(p: number, player)
	local v3 = v[p]

	if not v3 then
		return
	end

	if v3.ownerUserId then
		if v3.ownerUserId == player.UserId then
			remoteEvent3:FireClient(player, "manage", nil)
		else
			remoteEvent3:FireClient(player, "view", v3.ownerUserId)
		end
	else
		-- equivalent call inferred; original call site unknown
		if findStallOwnedBy(player.UserId) then
			return
		end

		v3.ownerUserId = player.UserId
		player:SetAttribute("BoothHasStall", true)
		broadcastStallState(p) -- equivalent call inferred; original call site unknown
		remoteEvent3:FireClient(player, "manage", nil)
	end
end

local function handleClose(p)
	local stallOwnedBy = findStallOwnedBy(p.UserId) -- equivalent call inferred; original call site unknown

	if not stallOwnedBy then
		return false
	end

	releaseStall(stallOwnedBy) -- equivalent call inferred; original call site unknown
	return true
end

local function isValidListPrice(value: number)
	return typeof(value) == "number" and value > 0 and value == math.floor(value) and math.floor(value * 0.95) > 0
end

local function handleList(p, itemInstanceId: string, value2: number)
	local v3

	if typeof(value2) == "number" and value2 > 0 and value2 == math.floor(value2) then
		v3 = math.floor(value2 * 0.95) > 0
	else
		v3 = false
	end

	if not v3 then
		return false, "invalid"
	end

	local boothListings = PlayerData.server[p].boothListings()
	local count = 0

	for _ in boothListings do
		count += 1
	end

	if count >= 8 then
		return false, "full"
	end

	local v4 = PlayerData.server[p].items[itemInstanceId]()

	if typeof(v4) ~= "table" or v4.ownerUserId ~= p.UserId then
		return false, "notOwned"
	end

	if not ItemService.server.canTrade(p, itemInstanceId) then
		return false, "notTradable"
	end

	local GUID = HttpService:GenerateGUID(false)

	if not ItemService.server.setLock(p, itemInstanceId, "booth", GUID) then
		return false, "lockFailed"
	end

	PlayerData.server[p].boothListings[GUID]({
		listingId = GUID,
		itemInstanceId = itemInstanceId,
		price = math.floor(value2),
		listedAt = TimeService.now()
	})
	broadcastSeller(p) -- equivalent call inferred; original call site unknown
	local stallOwnedBy = findStallOwnedBy(p.UserId) -- equivalent call inferred; original call site unknown
	local v5 = stallOwnedBy and buildStallPayload(stallOwnedBy)

	if v5 then
		remoteEvent2:FireAllClients(v5)
	end

	return true, nil
end

local function handleUnlist(p, value: string)
	local v3 = PlayerData.server[p].boothListings[value]()

	if typeof(v3) ~= "table" then
		return false
	end

	ItemService.server.clearLock(p, v3.itemInstanceId, "booth")
	PlayerData.server[p].boothListings[value](nil)
	broadcastSeller(p) -- equivalent call inferred; original call site unknown
	local stallOwnedBy = findStallOwnedBy(p.UserId) -- equivalent call inferred; original call site unknown
	local v4 = stallOwnedBy and buildStallPayload(stallOwnedBy)

	if v4 then
		remoteEvent2:FireAllClients(v4)
	end

	return true
end

local function handlePurchase(p, value: number, value2: string)
	if p.UserId == value then
		return false, "selfBuy"
	end

	local playerByUserId = Players:GetPlayerByUserId(value)

	if not playerByUserId then
		return false, "sellerOffline"
	end

	local stallOwnedBy = findStallOwnedBy(value) -- equivalent call inferred; original call site unknown

	if not (stallOwnedBy or hasEquippedSign(playerByUserId)) then
		return false, "boothClosed"
	end

	local v3 = PlayerData.server[playerByUserId].boothListings[value2]()

	if typeof(v3) ~= "table" then
		return false, "listingGone"
	end

	local v4 = PlayerData.server[playerByUserId].items[v3.itemInstanceId]()

	if typeof(v4) ~= "table" or v4.ownerUserId ~= value then
		return false, "itemGone"
	end

	if v4.tradable ~= true then
		return false, "listingGone"
	end

	local price = v3.price

	if not CurrencyService.server.trySpend(p, CurrencyService.ref.Diamonds, price, {
		transactionType = "摆摊购买",
		sku = v4.itemId,
		channel = "小摊",
		mode = "交易大厅",
		isTransfer = true
	}) then
		return false, "notEnoughCurrency", price
	end

	local v5 = false
	local v6 = nil
	PlayerData.server[playerByUserId].items(function(p2)
		local v7 = p2[v3.itemInstanceId]

		if typeof(v7) ~= "table" or v7.ownerUserId ~= value then
			return p2
		end

		local clone = table.clone(p2)
		clone[v3.itemInstanceId] = nil
		v5 = true
		v6 = v7
		return clone
	end)

	if not v5 then
		CurrencyService.server.give(p, CurrencyService.ref.Diamonds, price)
		return false, "itemGone"
	end

	local now = TimeService.now()
	local clone = table.clone(v6)
	clone.ownerUserId = p.UserId
	clone.locks = {}
	clone.metadata = table.clone(v6.metadata or {})
	clone.metadata.tradeCount = (tonumber(clone.metadata.tradeCount) or 0) + 1
	clone.metadata.lastTradedAt = now
	PlayerData.server[p].items(function(options)
		local clone2 = table.clone(options or {})
		clone2[v3.itemInstanceId] = clone
		return clone2
	end)
	PlayerData.server[playerByUserId].equipment(function(options)
		local clone2 = table.clone(options or {})

		for k, id in clone2 do
			if typeof(id) ~= "string" then
				if typeof(id) == "table" and id.kind == "flyer" and typeof(id.id) == "string" then
					id = id.id
				else
					id = nil
				end
			end

			if id == v3.itemInstanceId then
				clone2[k] = nil
			end
		end

		return clone2
	end)
	ItemService.server.autoEquipAcquiredSkins(p, { v3.itemInstanceId })
	PlayerData.server[playerByUserId].boothListings[value2](nil)
	AuditService.record(playerByUserId, {
		assetType = "item",
		action = "transfer",
		source = "Booth",
		operationId = value2,
		itemInstanceId = v3.itemInstanceId,
		assetId = v6.itemId,
		delta = -1,
		counterpartyUserId = p.UserId
	})
	AuditService.record(p, {
		assetType = "item",
		action = "transfer",
		source = "Booth",
		operationId = value2,
		itemInstanceId = v3.itemInstanceId,
		assetId = v6.itemId,
		delta = 1,
		counterpartyUserId = value
	})
	SerialRegistryService.transfer(playerByUserId, p, { v3.itemInstanceId }, {
		t = "摆摊",
		txn = value2,
		price = price
	})
	local netIncome = math.floor(price * 0.95)
	CurrencyService.server.give(playerByUserId, CurrencyService.ref.Diamonds, netIncome, {
		type = "boothSale",
		arg = value2
	}, {
		transactionType = "摆摊出售",
		sku = v6.itemId,
		channel = "小摊",
		mode = "交易大厅"
	})
	PlayerData.server[playerByUserId].boothTotalSold(function(p2)
		return (tonumber(p2) or 0) + netIncome
	end)
	CurrencyService.server.recordFee(playerByUserId, CurrencyService.ref.Diamonds, price - netIncome, "摆摊")
	RAPService.server.record(v6.itemId, price)
	Leaderboard.Increment("ItemTradeVolume", v6.itemId, 1)
	broadcastSeller(playerByUserId) -- equivalent call inferred; original call site unknown
	local stallOwnedBy2 = findStallOwnedBy(value) -- equivalent call inferred; original call site unknown
	local v8 = stallOwnedBy2 and buildStallPayload(stallOwnedBy2)

	if v8 then
		remoteEvent2:FireAllClients(v8)
	end

	local v9 = {
		transactionId = value2,
		buyerUserId = p.UserId,
		buyerName = p.Name,
		sellerUserId = value,
		itemType = v6.itemType,
		itemId = v6.itemId,
		serial = v6.serial,
		netIncome = netIncome
	}
	remoteEvent4:FireClient(playerByUserId, v9)
	return true, nil, nil, v9
end

local BoothService = {
	server_init = function()
		if flag then
			error("[BoothService] init() called more than once")
		end

		flag = true
		Players.PlayerRemoving:Connect(function(player)
			v2[player.UserId] = nil
		end)
		task.spawn(function()
			if ServerTeleport.getServerType() ~= ServerTypeService.TRADE_POOL_NAME then
				return
			end

			local v3 = Workspace:WaitForChild("交易大厅", 10)

			if not v3 then
				warn("[BoothService] 交易服未找到交易大厅，暂不接线")
				return
			end

			local firstChild = v3:FindFirstChild("摊位")

			if not firstChild then
				warn("[BoothService] 未找到摊位文件夹，暂不接线")
				return
			end

			local count = 0

			for _, model in firstChild:GetChildren() do
				if not model:IsA("Model") then
					continue
				end

				local firstChild2 = model:FindFirstChild("交互点")
				local proximityPrompt = firstChild2 and firstChild2:FindFirstChild("ProximityPrompt")

				if proximityPrompt and proximityPrompt:IsA("ProximityPrompt") then
					count += 1
					v[count] = {
						model = model,
						ownerUserId = nil
					}
					local v4 = count
					proximityPrompt.Triggered:Connect(function(player)
						onPromptTriggered(v4, player)
					end)
				else
					warn(("[BoothService] 摊位 %s 缺少 交互点.ProximityPrompt，已跳过登记"):format(model.Name))
				end
			end

			if count == 0 then
				warn("[BoothService] 摊位文件夹下没有登记到任何坑位，摆摊系统不会生效")
			end

			Players.PlayerRemoving:Connect(function(player)
				local stallOwnedBy = findStallOwnedBy(player.UserId) -- equivalent call inferred; original call site unknown
				local v4 = stallOwnedBy and v[stallOwnedBy]

				if v4 then
					if not v4.ownerUserId then
						return
					end

					local playerByUserId = Players:GetPlayerByUserId(v4.ownerUserId)
					v4.ownerUserId = nil

					if playerByUserId then
						playerByUserId:SetAttribute("BoothHasStall", false)
					end

					broadcastStallState(stallOwnedBy) -- equivalent call inferred; original call site unknown
				end
			end)
		end)

		remoteFunction.OnServerInvoke = function(p, itemInstanceId, value2)
			if typeof(itemInstanceId) == "string" and typeof(value2) == "number" then
				return handleList(p, itemInstanceId, value2)
			end

			return false, "invalid"
		end

		remoteFunction2.OnServerInvoke = function(p, value)
			return typeof(value) == "string" and handleUnlist(p, value)
		end

		remoteFunction3.OnServerInvoke = function(p)
			local stallOwnedBy = findStallOwnedBy(p.UserId) -- equivalent call inferred; original call site unknown

			if not stallOwnedBy then
				return false
			end

			releaseStall(stallOwnedBy) -- equivalent call inferred; original call site unknown
			return true
		end

		remoteFunction4.OnServerInvoke = function(p, value, value2)
			if typeof(value) == "number" and typeof(value2) == "string" then
				return handlePurchase(p, value, value2)
			end

			return false, "invalid"
		end

		remoteFunction5.OnServerInvoke = function(_, value)
			if typeof(value) ~= "number" then
				return nil
			end

			local playerByUserId = Players:GetPlayerByUserId(value)

			if not playerByUserId then
				return nil
			end

			if PlayerData.server.Service:getProfile(playerByUserId) then
				return (buildSellerPayload(playerByUserId))
			end

			return nil
		end

		remoteFunction6.OnServerInvoke = function(_)
			local result = {}

			for k in v do
				table.insert(result, (buildStallPayload(k)))
			end

			return result
		end
	end
}
BoothService.server = {
	init = BoothService.server_init
}
BoothService.client = {
	onSold = function(onOnClientEvent)
		return remoteEvent4.OnClientEvent:Connect(onOnClientEvent)
	end,
	onSellerChanged = function(onOnClientEvent)
		return remoteEvent.OnClientEvent:Connect(onOnClientEvent)
	end,
	requestList = function(p: string, p2: number)
		return remoteFunction:InvokeServer(p, p2)
	end,
	requestUnlist = function(p: string)
		return remoteFunction2:InvokeServer(p)
	end,
	requestClose = function()
		return remoteFunction3:InvokeServer()
	end,
	requestPurchase = function(p: number, p2: string)
		return remoteFunction4:InvokeServer(p, p2)
	end,
	getSellerListings = function(p: number)
		return remoteFunction5:InvokeServer(p)
	end,
	getAllStates = function()
		return remoteFunction6:InvokeServer()
	end,
	onOpenPanel = function(onOnClientEvent)
		remoteEvent3.OnClientEvent:Connect(onOnClientEvent)
	end,
	onStateChanged = function(onOnClientEvent)
		remoteEvent2.OnClientEvent:Connect(onOnClientEvent)
	end
}
return BoothService