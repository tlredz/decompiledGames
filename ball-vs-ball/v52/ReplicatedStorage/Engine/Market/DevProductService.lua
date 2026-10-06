local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local Net = require(game.ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
local PurchaseVisual = require(script.PurchaseVisual)
local GiftUI = require(script.GiftUI)
local products = {
	list = {},
	byName = {},
	byProductId = {},
	byProductKey = {}
}
local v2 = {}
local remoteEvent = Net:RemoteEvent("DevProductService/SetGift")
local remoteEvent2 = Net:RemoteEvent("PromptPurchaseVisual")
local remoteEvent3 = Net:RemoteEvent("DevProductService/PurchaseGranted")
local dataStore = RunService:IsServer() and DataStoreService:GetDataStore("DevProductPurchase")
local bindableEvent

if RunService:IsServer() then
	bindableEvent = Instance.new("BindableEvent")
else
	bindableEvent = nil
end

local function getProduct(p)
	local v3 = products.byProductKey[p]

	if v3 == nil then
		error((`产品不存在:{p}`))
	end

	return v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function popPendingGiftTarget(playerId: number, productId: number)
	local v3 = v2[playerId] and v2[playerId][productId]

	if v3 and #v3 ~= 0 then
		return table.remove(v3, 1)
	end

	return nil
end

local function tryTillSuccess(fn, ...)
	local v3 = 1
	local result

	while true do
		local success
		success, result = pcall(fn, ...)

		if success then
			break
		end

		task.wait(v3)
		v3 = math.clamp(v3 * 2, 1, 60)
	end

	return result
end

local function serverBindProduct(p, callback)
	local v3 = products.byProductKey[p]

	if v3 == nil then
		error((`产品不存在:{p}`))
	end

	MarketplaceService:BindReceiptHandler(Enum.ReceiptType.DeveloperProduct, function(data)
		local playerByUserId = Players:GetPlayerByUserId(data.PlayerId)

		if not playerByUserId then
			return Enum.ReceiptDecision.NotProcessedYet
		end

		local success, result = pcall(function()
			return dataStore:UpdateAsync(data.PurchaseId, function(p2)
				if p2 then
					return p2
				end

				local v4 = popPendingGiftTarget(data.PlayerId, v3.ProductId) -- equivalent call inferred; original call site unknown
				return {
					recipientUserId = v4 or data.PlayerId,
					granted = false
				}
			end)
		end)

		if not success then
			warn(result)
			return Enum.ReceiptDecision.NotProcessedYet
		end

		if result.granted then
			return Enum.ReceiptDecision.Processed
		end

		local playerByUserId2 = Players:GetPlayerByUserId(result.recipientUserId)

		if not playerByUserId2 then
			return Enum.ReceiptDecision.NotProcessedYet
		end

		local v4 = {
			plr = playerByUserId2,
			buyer = playerByUserId,
			isGift = result.recipientUserId ~= data.PlayerId,
			productId = v3.ProductId,
			productName = v3.Name,
			purchaseId = data.PurchaseId,
			robuxSpent = RunService:IsStudio() and v3.PriceInRobux or data.CurrencySpent
		}
		local success2, result2 = pcall(callback, v4)

		if not success2 then
			warn((`发放{v3.Name}给uid:{result.recipientUserId}失败:{result2}`))
			return Enum.ReceiptDecision.NotProcessedYet
		end

		task.spawn(function()
			if bindableEvent then
				bindableEvent:Fire(v4)
			end

			remoteEvent3:FireClient(v4.plr, v4)
		end)

		if not pcall(function()
			dataStore:UpdateAsync(data.PurchaseId, function(p2)
				if p2 then
					p2.granted = true
				end

				return p2
			end)
		end) then
			warn((`标记{v3.Name}给uid:{result.recipientUserId}的发放记录失败，道具已实际发放，仅内部记账缺失`))
		end

		return Enum.ReceiptDecision.Processed
	end, { v3.ProductId })
end

local function fetchAllProducts()
	local v3 = tryTillSuccess(function()
		return MarketplaceService:GetDeveloperProductsAsync()
	end)
	local result = {}

	while true do
		for _, v4 in v3:GetCurrentPage() do
			table.insert(result, v4)
		end

		if v3.IsFinished then
			return result
		else
			tryTillSuccess(function()
				v3:AdvanceToNextPageAsync()
			end)
		end
	end
end

local function initProducts()
	for _, v3 in fetchAllProducts() do
		table.insert(products.list, v3)
		products.byName[v3.Name] = v3
		products.byProductId[v3.ProductId] = v3
		products.byProductKey[v3.Name] = v3
		products.byProductKey[v3.ProductId] = v3
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clientSetGift(userId: number, p)
	remoteEvent:FireServer(userId, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clientPromptPurchase(p)
	local v3 = products.byProductKey[p]

	if v3 == nil then
		error((`产品不存在:{p}`))
	end

	MarketplaceService:PromptProductPurchase(Players.LocalPlayer, v3.ProductId)
	PurchaseVisual.play()
end

local function clientPromptGift(p)
	local v3 = products.byProductKey[p]

	if v3 == nil then
		error((`产品不存在:{p}`))
	end

	GiftUI.open(v3, function(p2)
		clientSetGift(p2.UserId, p) -- equivalent call inferred; original call site unknown
		clientPromptPurchase(p) -- equivalent call inferred; original call site unknown
	end)
end

local function serverHandleSetGift()
	remoteEvent.OnServerEvent:Connect(function(p, p2: number, p3)
		local v3 = products.byProductKey[p3]

		if v3 == nil then
			error((`产品不存在:{p3}`))
		end

		local userId = p.UserId
		v2[userId] = v2[userId] or {}
		v2[userId][v3.ProductId] = v2[userId][v3.ProductId] or {}
		table.insert(v2[userId][v3.ProductId], p2)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function handleGiftCancelled(p: number, p2: number, flag: boolean)
	if flag then
		return
	end

	local v3 = v2[p] and v2[p][p2]

	if v3 and #v3 > 0 then
		table.remove(v3)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function handleHidePurchaseVisual(p: number)
	local playerByUserId = Players:GetPlayerByUserId(p)

	if playerByUserId then
		remoteEvent2:FireClient(playerByUserId, false)
	end
end

local function serverHandlePurchaseFinished()
	MarketplaceService.PromptProductPurchaseFinished:Connect(function(p: number, p2: number, flag: boolean)
		handleGiftCancelled(p, p2, flag) -- equivalent call inferred; original call site unknown
		handleHidePurchaseVisual(p) -- equivalent call inferred; original call site unknown
	end)
end

local function serverHandlePlayerRemoving()
	Players.PlayerRemoving:Connect(function(player)
		v2[player.UserId] = nil
	end)
end

local function clientHandlePurchaseVisual()
	remoteEvent2.OnClientEvent:Connect(function(flag: boolean)
		if flag then
			PurchaseVisual.play()
		else
			PurchaseVisual.stop()
		end
	end)
end

local v3 = {}

local function clientHandlePurchaseGranted()
	remoteEvent3.OnClientEvent:Connect(function(p)
		local v4 = {}

		for _, v5 in { p.productName, p.productId } do
			for _, v6 in v3[v5] or {} do
				if v4[v6] then
					continue
				end

				v4[v6] = true
				v6(p)
			end
		end
	end)
end

local function clientOnPurchaseGranted(p, callback)
	v3[p] = v3[p] or {}
	local v4 = v3[p]
	table.insert(v4, callback)
	return function()
		local index = table.find(v4, callback)

		if index then
			table.remove(v4, index)
		end
	end
end

initProducts()

if RunService:IsServer() then
	remoteEvent.OnServerEvent:Connect(function(p, p2: number, p3)
		local v4 = products.byProductKey[p3]

		if v4 == nil then
			error((`产品不存在:{p3}`))
		end

		local userId = p.UserId
		v2[userId] = v2[userId] or {}
		v2[userId][v4.ProductId] = v2[userId][v4.ProductId] or {}
		table.insert(v2[userId][v4.ProductId], p2)
	end)
	MarketplaceService.PromptProductPurchaseFinished:Connect(function(p: number, p2: number, flag: boolean)
		handleGiftCancelled(p, p2, flag) -- equivalent call inferred; original call site unknown
		handleHidePurchaseVisual(p) -- equivalent call inferred; original call site unknown
	end)
	Players.PlayerRemoving:Connect(function(player)
		v2[player.UserId] = nil
	end)
end

if RunService:IsClient() then
	remoteEvent2.OnClientEvent:Connect(function(flag: boolean)
		if flag then
			PurchaseVisual.play()
		else
			PurchaseVisual.stop()
		end
	end)
	remoteEvent3.OnClientEvent:Connect(function(p)
		local v4 = {}

		for _, v5 in { p.productName, p.productId } do
			for _, v6 in v3[v5] or {} do
				if v4[v6] then
					continue
				end

				v4[v6] = true
				v6(p)
			end
		end
	end)
end

return {
	robuxEmoji = utf8.char(57346),
	products = products,
	server = {
		bindProduct = serverBindProduct,
		onPurchaseSucceeded = function(onEvent)
			assert(RunService:IsServer(), "onPurchaseSucceeded 只能由服务器调用")
			assert(bindableEvent, "购买成功信号未初始化")
			return bindableEvent.Event:Connect(onEvent)
		end
	},
	client = {
		promptPurchase = clientPromptPurchase,
		promptGift = clientPromptGift,
		onPurchaseGranted = clientOnPurchaseGranted
	}
}