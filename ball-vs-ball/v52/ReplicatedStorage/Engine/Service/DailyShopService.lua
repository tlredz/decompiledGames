local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Net = require(ReplicatedStorage.Packages.Net)
local Config = require(ReplicatedStorage.Engine.Service.Config)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local TimeService = require(ReplicatedStorage.Engine.Service.TimeService)
local GachaPool = require(ReplicatedStorage.Engine.Service.GachaPool)
local CurrencyService = require(ReplicatedStorage.Engine.Service.CurrencyService)
local DevProductService = require(ReplicatedStorage.Engine.Market.DevProductService)
local gachaIdsByCnId = {}
local cnIds = {}
local DailyShopService = {
	server = {},
	client = {}
}

for _, v in not Config.dailyShop and {} or Config.dailyShop.list or {} do
	if typeof(v.cnId) ~= "string" or gachaIdsByCnId[v.cnId] then
		continue
	end

	table.insert(cnIds, v.cnId)
	gachaIdsByCnId[v.cnId] = v.gachaId
end

DailyShopService.SLOT_IDS = cnIds
local remoteFunction = Net:RemoteFunction("DailyShop/Buy")
local remoteEvent = Net:RemoteEvent("DailyShop/Granted")

function DailyShopService.getDayKey()
	return TimeService.getDayKey(0)
end

function DailyShopService.secondsUntilRefresh()
	return (math.max(0, (DailyShopService.getDayKey() + 1) * 86400 - TimeService.now()))
end

function DailyShopService.getOffer(p: string, value: string?, value2: number?)
	local v = Config.dailyShop and Config.dailyShop.byCnId[p]

	if not v or typeof(value) ~= "string" or typeof(value2) ~= "number" then
		return nil
	end

	for _, v2 in v do
		if not (v2.itemType == value and v2.rating == value2) then
			continue
		end

		if v2.currency == "金币" or v2.currency == "钻石" then
			if typeof(v2.price) == "number" and v2.price > 0 then
				return {
					currency = v2.currency,
					price = v2.price
				}
			end
		elseif v2.currency == "Robux" then
			local productKey = v2.productKey

			if typeof(productKey) == "string" and DevProductService.products.byProductKey[productKey] then
				return {
					currency = "Robux",
					price = v2.price,
					productKey = productKey
				}
			end
		end

		return nil
	end

	return nil
end

local v = nil

local function getCandidates(p: string)
	if not v then
		local v2 = {}

		for _, v3 in cnIds do
			local v4 = gachaIdsByCnId[v3]
			local v5 = {}

			for _, v6 in typeof(v4) ~= "string" and {} or GachaPool.getPool(v4) or {} do
				if DailyShopService.getOffer(v3, v6.itemType, v6.rating) then
					table.insert(v5, v6)
				elseif RunService:IsServer() then
					warn((`[DailyShopService] {v3}（{tostring(v4)}）-> {v6.targetId}（{tostring(v6.itemType)} 品质 {tostring(v6.rating)}）在 dailyShop 表里没有有效价格，已从每日商店剔除`))
				end
			end

			if #v5 == 0 and RunService:IsServer() then
				warn((`[DailyShopService] {v3}（{tostring(v4)}）没有任何可售物品，该格子不会刷新商品`))
			end

			v2[v3] = v5
		end

		v = v2
	end

	return v[p] or {}
end

function DailyShopService.getSlotRow(p: string, p2)
	if typeof(p2) ~= "table" or typeof(p2.targetId) ~= "string" then
		return nil
	end

	for _, v2 in getCandidates(p) do
		if v2.targetId == p2.targetId and v2.itemType == p2.itemType then
			return v2
		end
	end

	return nil
end

if RunService:IsServer() then
	local GachaService = require(ReplicatedStorage.Engine.Service.GachaService)
	local ItemService = require(ReplicatedStorage.Engine.Service.ItemService)
	local random = Random.new()
	local v2 = {}
	local flag = false
	local v3 = {
		["金币"] = CurrencyService.ref.Coins,
		["钻石"] = CurrencyService.ref.Diamonds
	}

	local function ownershipMultiplier(p)
		local v4 = {}

		for _, v5 in PlayerData.server[p].items() do
			if not (typeof(v5.itemType) == "string" and typeof(v5.itemId) == "string") then
				continue
			end

			v4[GachaPool.ownedKey(v5.itemType, v5.itemId)] = true
		end

		local dailyShopUnownedRate = Config.misc.dailyShopUnownedRate

		if typeof(dailyShopUnownedRate) ~= "number" or dailyShopUnownedRate < 0 then
			warn((`[DailyShopService] misc.dailyShopUnownedRate 非法（{tostring(dailyShopUnownedRate)}），按 1 处理`))
			dailyShopUnownedRate = 1
		end

		return function(p2)
			if v4[GachaPool.ownedKey(GachaPool.toEngineItemType(p2.itemType), p2.targetId)] then
				return 1
			end

			return dailyShopUnownedRate
		end
	end

	local function rollSlots(p)
		local multiplier = ownershipMultiplier(p)
		local result = {}

		for _, v5 in cnIds do
			local v6 = GachaPool.pick(getCandidates(v5), random, {
				multiplier = multiplier
			})

			if v6 then
				result[v5] = {
					itemType = v6.itemType,
					targetId = v6.targetId
				}
			end
		end

		return result
	end

	local function isValidState(dailyShop)
		if typeof(dailyShop) ~= "table" or typeof(dailyShop.slots) ~= "table" or typeof(dailyShop.purchased) ~= "table" then
			return false
		end

		for _, slot in dailyShop.slots do
			if typeof(slot) ~= "table" or typeof(slot.itemType) ~= "string" or typeof(slot.targetId) ~= "string" then
				return false
			end
		end

		return true
	end

	local function ensureCurrentDay(p)
		local v4 = PlayerData.server[p]
		local dayKey = DailyShopService.getDayKey()
		local dailyShop = v4.dailyShop()

		if dailyShop.dayKey ~= dayKey or not isValidState(dailyShop) then
			dailyShop = {
				dayKey = dayKey,
				slots = rollSlots(p),
				purchased = {}
			}
			v4.dailyShop(dailyShop)
		end

		return dailyShop
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function markPurchased(p, dayKey: number, p2: string)
		PlayerData.server[p].dailyShop(function(p3)
			if p3.dayKey ~= dayKey then
				return p3
			end

			local clone = table.clone(p3)
			clone.purchased = table.clone(p3.purchased)
			clone.purchased[p2] = true
			return clone
		end)
	end

	local function isSlotId(value)
		return typeof(value) == "string" and gachaIdsByCnId[value] ~= nil
	end

	local function buy(p, value)
		local v4

		if typeof(value) == "string" then
			v4 = gachaIdsByCnId[value] ~= nil
		else
			v4 = false
		end

		if not v4 then
			return {
				ok = false,
				reason = "invalid_request"
			}
		end

		local currentDay = ensureCurrentDay(p)

		if currentDay.purchased[value] then
			return {
				ok = false,
				reason = "sold_out"
			}
		end

		local slotRow = DailyShopService.getSlotRow(value, currentDay.slots[value])
		local v5 = slotRow and DailyShopService.getOffer(value, slotRow.itemType, slotRow.rating)
		local v6 = v5 and v3[v5.currency]

		if not (slotRow and v5 and v6) then
			return {
				ok = false,
				reason = "invalid_offer"
			}
		end

		local purchaseBatch = ItemService.server.purchaseBatch(p, { slotRow }, gachaIdsByCnId[value], v6, v5.price, {
			source = "每日商店",
			sku = "每日商店" .. ":" .. slotRow.targetId,
			channel = "每日商店"
		})

		if not purchaseBatch.ok then
			return purchaseBatch
		end

		markPurchased(p, currentDay.dayKey, value) -- equivalent call inferred; original call site unknown
		return {
			ok = true,
			result = purchaseBatch.results[1]
		}
	end

	local function grantRobuxPurchase(data, p: string, p2: string, p3: number)
		local plr = data.plr
		PlayerData.server.Service:waitForData(plr)
		local currentDay = ensureCurrentDay(plr)
		local slotRow = DailyShopService.getSlotRow(p, currentDay.slots[p])
		local v4 = slotRow and DailyShopService.getOffer(p, slotRow.itemType, slotRow.rating)

		if slotRow and v4 and v4.productKey == data.productName then
			if currentDay.purchased[p] then
				warn((`[DailyShopService] 玩家 {plr.UserId} 当天重复付款 {data.productName}，照常发放当前格子物品 {slotRow.targetId}`))
			end

			markPurchased(plr, currentDay.dayKey, p) -- equivalent call inferred; original call site unknown
		else
			local v5 = GachaPool.pick(getCandidates(p), random, {
				filter = function(p4)
					return p4.itemType == p2 and p4.rating == p3
				end,
				multiplier = ownershipMultiplier(plr)
			})
			local slot = currentDay.slots[p]
			warn((`[DailyShopService] 玩家 {plr.UserId} 付款 {data.productName} 与当前{p}（{tostring(slot and slot.targetId)}）不匹配，按 {p2} 品质 {p3} 随机发放 {not v5 and "（无候选）" or v5.targetId or "（无候选）"}`))
			slotRow = v5 or slotRow
		end

		if not slotRow then
			warn((`[DailyShopService] 玩家 {plr.UserId} 付款 {data.productName} 后在{p}找不到可发放的物品，需人工补偿（purchaseId={data.purchaseId}）`))
			return
		end

		remoteEvent:FireClient(plr, (GachaService.server.grantPickedItem(plr, slotRow, "每日商店", gachaIdsByCnId[p])))
	end

	local function bindRobuxProducts()
		local v4 = {}

		for _, v5 in Config.dailyShop and Config.dailyShop.list or {} do
			local productKey = v5.productKey

			if not (v5.currency == "Robux" and typeof(productKey) == "string") then
				continue
			end

			if v4[productKey] then
				warn((`[DailyShopService] 开发者商品 {productKey} 在 dailyShop 表里出现多次，只按第一行（{v5.cnId}）处理`))
			else
				v4[productKey] = true
				local cnId = v5.cnId
				local itemType = v5.itemType
				local rating = v5.rating
				local success, result = pcall(DevProductService.server.bindProduct, productKey, function(p)
					grantRobuxPurchase(p, cnId, itemType, rating)
				end)

				if success then
					local v9 = false

					for _, v11 in getCandidates(cnId) do
						if not (v11.itemType == itemType and v11.rating == rating) then
							continue
						end

						v9 = true
						break
					end

					if not v9 then
						warn((`[DailyShopService] {cnId} 没有 {itemType} 品质 {rating} 的可售物品，{productKey} 付款不匹配时只能发放当前格子物品`))
					end
				else
					warn((`[DailyShopService] 绑定开发者商品 {productKey} 失败：{result}`))
				end
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function startMidnightLoop()
		task.spawn(function()
			while true do
				task.wait(DailyShopService.secondsUntilRefresh() + 1)

				for _, v4 in Players:GetPlayers() do
					local v5 = v4
					task.spawn(function()
						PlayerData.server.Service:waitForData(v5)

						if v5.Parent == Players then
							ensureCurrentDay(v5)
						end
					end)
				end
			end
		end)
	end

	function DailyShopService.server.debugReroll(p)
		PlayerData.server[p].dailyShop({
			dayKey = 0,
			slots = {},
			purchased = {}
		})
		ensureCurrentDay(p)
	end

	local function init()
		if flag then
			return
		end

		flag = true

		if #cnIds == 0 then
			warn("[DailyShopService] Config.dailyShop 为空，每日商店不会刷新商品")
		end

		for _, v4 in cnIds do
			getCandidates(v4)
		end

		bindRobuxProducts()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function onPlayerAdded(p)
			task.spawn(function()
				PlayerData.server.Service:waitForData(p)

				if p.Parent == Players then
					ensureCurrentDay(p)
				end
			end)
		end

		Players.PlayerAdded:Connect(onPlayerAdded)

		for _, v4 in Players:GetPlayers() do
			onPlayerAdded(v4) -- equivalent call inferred; original call site unknown
		end

		startMidnightLoop() -- equivalent call inferred; original call site unknown

		remoteFunction.OnServerInvoke = function(p, p2)
			if v2[p] then
				return {
					ok = false,
					reason = "busy"
				}
			end

			v2[p] = true
			local success, result = pcall(buy, p, p2)
			v2[p] = nil

			if success then
				return result
			end

			warn((`[DailyShopService] 购买出错: {result}`))
			return {
				ok = false,
				reason = "error"
			}
		end

		Players.PlayerRemoving:Connect(function(player)
			v2[player] = nil
		end)
	end

	DailyShopService.server.init = init
else
	function DailyShopService.client.buy(p: string)
		return remoteFunction:InvokeServer(p)
	end

	function DailyShopService.client.promptRobux(p: string)
		DevProductService.client.promptPurchase(p)
	end

	function DailyShopService.client.onGranted(onOnClientEvent)
		return remoteEvent.OnClientEvent:Connect(onOnClientEvent)
	end
end

return DailyShopService