local parent = script.Parent
local Signal = require(parent.Signal)
local UserId = require(parent.UserId)
local Network = require(parent.Network)
local Promise = require(parent.Promise)
local RunContext = require(parent.RunContext)
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}

local function setMockEconomyCheck(p: string, callback)
	if callback then
		v7[p] = callback
	else
		v7[p] = nil
	end
end

local function setPurchaseValidator(p: string, callback)
	assert(RunContext.IsServer or RunContext.IsEdit, "Purchase validators can only be added from the server!")

	if callback then
		v8[p] = callback
	else
		v8[p] = nil
	end
end

local function setProductOwnershipChecker(p: number, callback)
	if callback then
		v9[p] = callback
	else
		v9[p] = nil
	end
end

local function canMockEconomy()
	if next(v7) == nil then
		return false
	end

	for _, v11 in v7 do
		if not v11() then
			return false
		end
	end

	return true
end

local promisify = Promise.promisify(function(p, p2, p3)
	local v11 = UserId.Get(p)

	if p3 == Enum.InfoType.Subscription then
		return MarketplaceService:GetUserSubscriptionStatusAsync(p, p2).IsSubscribed
	end

	if p3 == Enum.InfoType.GamePass then
		return MarketplaceService:UserOwnsGamePassAsync(v11, p2)
	end

	if p3 == Enum.InfoType.Bundle then
		return MarketplaceService:PlayerOwnsBundleAsync(p, p2)
	end

	if p3 ~= Enum.InfoType.Product then
		return MarketplaceService:PlayerOwnsAssetAsync(p, p2)
	end

	local v12 = v9[p2]
	warn("CHECKER", v12, p2, p)

	if v12 then
		return v12(p, p2)
	end

	return false
end)

local function enqueueProductInfoFetch(p, flag: boolean)
	local formatted = `{p.InfoType.Name}_{p.Id}`
	local v11 = v6[formatted]

	if v11 then
		local index = flag and table.find(v5, v11)

		if index then
			table.remove(v5, index)
			table.insert(v5, 1, v11)
		end
	else
		v6[formatted] = p

		if flag then
			table.insert(v5, 1, p)
		else
			table.insert(v5, p)
		end
	end
end

task.spawn(function()
	if RunContext.IsClient and not RunContext.IsEdit then
		return
	end

	while task.wait(0.2) do
		local v11 = table.remove(v5, 1)

		if not v11 then
			continue
		end

		local formatted = `{v11.InfoType.Name}_{v11.Id}`
		local v12 = v11
		local success, result = pcall(function()
			return MarketplaceService:GetProductInfoAsync(v12.Id, v12.InfoType)
		end)
		v6[formatted] = nil

		if success then
			v11.Resolve(result)
		else
			v11.Attempts += 1

			if v11.Attempts < 5 then
				local v13 = v11
				task.delay(2, function()
					local v14 = v13
					local formatted2 = `{v14.InfoType.Name}_{v14.Id}`

					if v6[formatted2] then
						return
					end

					v6[formatted2] = v14
					table.insert(v5, v14)
				end)
			else
				v11.Reject(result)
			end
		end
	end
end)
local reliableEvent = Network.ReliableEvent("Marketplace_GrantPurchase", function(player, p, infoType)
	local v11

	if typeof(player) == "Instance" then
		v11 = player:IsA("Player")
	else
		v11 = false
	end

	assert(v11)
	assert(p ~= nil)

	if infoType == nil then
		return player, p, Enum.InfoType.Asset
	end

	local v12

	if typeof(infoType) == "EnumItem" then
		v12 = infoType:IsA("InfoType")
	else
		v12 = false
	end

	assert(v12)
	return player, p, infoType
end)
local reliableEvent2 = Network.ReliableEvent("Marketplace_PromptPurchase", function(p, infoType)
	assert(p ~= nil)

	if infoType == nil then
		return p, Enum.InfoType.Asset
	end

	local v11

	if typeof(infoType) == "EnumItem" then
		v11 = infoType:IsA("InfoType")
	else
		v11 = false
	end

	assert(v11)
	return p, infoType
end)
local reliableEvent3 = Network.ReliableEvent("Marketplace_RequestProductInfo", function(value, infoType)
	assert(type(value) == "number")
	local v11

	if typeof(infoType) == "EnumItem" then
		v11 = infoType:IsA("InfoType")
	else
		v11 = false
	end

	assert(v11)
	return value, infoType
end)
local reliableEvent4 = Network.ReliableEvent("Marketplace_ProductInfoResult", function(value, infoType, p, p2)
	assert(type(value) == "number")
	local v11

	if typeof(infoType) == "EnumItem" then
		v11 = infoType:IsA("InfoType")
	else
		v11 = false
	end

	assert(v11)
	assert(type(p) == "boolean")
	return value, infoType, p, p2
end)
local reliableEvent5 = Network.ReliableEvent("Marketplace_RequestOwnership", function(value, p, infoType)
	assert(type(value) == "number")
	assert(p ~= nil)
	local v11

	if typeof(infoType) == "EnumItem" then
		v11 = infoType:IsA("InfoType")
	else
		v11 = false
	end

	assert(v11)
	return value, p, infoType
end)
local reliableEvent6 = Network.ReliableEvent("Marketplace_OwnershipResult", function(value, p, infoType, p2, p3)
	assert(type(value) == "number")
	assert(p ~= nil)
	local v11

	if typeof(infoType) == "EnumItem" then
		v11 = infoType:IsA("InfoType")
	else
		v11 = false
	end

	assert(v11)
	assert(type(p2) == "boolean")
	return value, p, infoType, p2, p3
end)
local promptPurchaseFinished2 = Signal.new()
local productGranted = Signal.new()

local function getOwnershipRecord(p, p2, p3)
	local v13 = p3 or Enum.InfoType.Asset
	local v14 = v[p]

	if not v14 then
		v[p] = {}
		v14 = v[p]
	end

	local formatted = `{v13.Name}_{p2}`
	local v15 = v14[formatted]

	if not v15 then
		v14[formatted] = {
			Promise = nil,
			Changed = Signal.new()
		}
		return v14[formatted]
	end

	return v15
end

local function promiseOwnership(p, p2: number, p3)
	local ownershipRecord = getOwnershipRecord(p, p2, p3)

	if ownershipRecord.Promise then
		return assert(ownershipRecord.Promise)
	end

	local flag

	if next(v7) == nil then
		flag = false
	else
		local flag2 = true

		for _, v13 in v7 do
			if v13() then
				continue
			end

			flag = false
			flag2 = false
			break
		end

		if flag2 then
			flag = true
		end
	end

	if flag then
		local v13 = false

		if p3 == Enum.InfoType.Product then
			local v14 = v9[p2]

			if v14 then
				v13 = v14(p, p2)
			end
		end

		ownershipRecord.Promise = Promise.resolve(v13)
		return assert(ownershipRecord.Promise)
	else
		local v13 = p3 or Enum.InfoType.Asset
		local v14 = UserId.Get(p)
		local promise

		if RunContext.IsClient and not RunContext.IsEdit then
			local formatted = `{v14}_{v13.Name}_{p2}`
			promise = Promise.new(function(resolve, reject, callback)
				local v16 = {
					Resolve = resolve,
					Reject = reject
				}
				v3[formatted] = v16
				callback(function()
					if v3[formatted] == v16 then
						v3[formatted] = nil
					end
				end)
				reliableEvent5:Client():Fire(v14, p2, v13)
			end)
		else
			promise = Promise.retryWithDelay(promisify, 5, 2, p, p2, p3)

			if RunContext.IsServer and not RunContext.IsEdit then
				promise:andThen(function(flag2: boolean)
					reliableEvent6:Server():Fire(p, v14, p2, v13, true, flag2)
				end)
			end
		end

		ownershipRecord.Promise = promise
		promise:catch(function(_)
			if ownershipRecord.Promise == promise then
				ownershipRecord.Promise = nil
			end
		end)
	end

	return assert(ownershipRecord.Promise)
end

local function getOwnershipChangedSignal(p, p2: number, p3)
	local ownershipRecord = getOwnershipRecord(p, p2, p3)

	if not ownershipRecord.Changed then
		ownershipRecord.Changed = Signal.new()
	end

	return assert(ownershipRecord.Changed)
end

local function promiseProductInfo(id: number, p2, flag: boolean?)
	if id <= 0 then
		return Promise.reject((`Invalid product id: {id}`))
	end

	local infoType = p2 or Enum.InfoType.Asset
	local formatted = `{infoType.Name}_{id}`
	local v14 = v2[formatted]

	if v14 then
		if flag == false then
			return v14
		end

		local v15 = v6[formatted]

		if not v15 then
			return v14
		end

		for i = 1, #v5 do
			if v5[i] ~= v15 then
				continue
			end

			table.remove(v5, i)
			table.insert(v5, 1, v15)
			return v14
		end

		return v14
	else
		local v15 = Promise.new(function(resolve, reject, callback)
			if not RunContext.IsClient or RunContext.IsEdit then
				enqueueProductInfoFetch({
					Id = id,
					InfoType = infoType,
					Attempts = 0,
					Resolve = resolve,
					Reject = reject
				}, flag ~= false)
				return
			end

			local v16 = {
				Resolve = resolve,
				Reject = reject
			}
			v4[formatted] = v16
			callback(function()
				if v4[formatted] == v16 then
					v4[formatted] = nil
				end
			end)
			reliableEvent3:Client():Fire(id, infoType)
		end)
		v2[formatted] = v15
		v15:catch(function()
			if v2[formatted] == v15 then
				v2[formatted] = nil
			end
		end)
		return v15
	end
end

local function prefetchProductInfo(id: number, p2)
	return promiseProductInfo(id, p2, false)
end

local function setReceiptHandler(p: number, callback)
	assert(RunContext.IsServer or RunContext.IsEdit, "Receipt handlers can only be set from the server!")
	local v13 = v10[p]

	if v13 and v13.Connection then
		v13.Connection:Disconnect()
	end

	if not callback then
		v10[p] = nil
		return
	end

	local function onHandleReceipt(p2)
		local v14 = callback(p2)
		local playerByUserId = v14 == Enum.ProductPurchaseDecision.PurchaseGranted and Players:GetPlayerByUserId(p2.PlayerId)

		if playerByUserId then
			productGranted:Fire(playerByUserId, p, p2)
		end

		return v14
	end

	v10[p] = {
		Callback = onHandleReceipt
	}
end

local function processReceiptAsync(p)
	local v13 = v10[p.ProductId]

	if v13 then
		return v13.Callback(p)
	end

	return nil
end

local function mockReceiptAsync(localPlayer, productId: number)
	return processReceiptAsync({
		PurchaseId = "MOCK_" .. HttpService:GenerateGUID(false),
		PlayerId = localPlayer.UserId,
		PlaceIdWherePurchased = game.PlaceId,
		ReceiptType = Enum.ReceiptType.DeveloperProduct,
		CurrencySpent = 0,
		ProductId = productId,
		CurrencyType = Enum.CurrencyType.Robux,
		ProductPurchaseChannel = Enum.ProductPurchaseChannel.InExperience
	})
end

local function bulkResolveOwnership(p, list)
	local count = #list
	local v13 = table.create(count)

	for i = 1, count do
		local v14 = list[i]

		if v14.Id == nil or v14.Id <= 0 then
			v13[i] = Promise.resolve(false)
		else
			v13[i] = promiseOwnership(p, v14.Id, v14.InfoType)
		end
	end

	return Promise.allSettled(v13):andThen(function()
		local result = table.create(count)

		for i = 1, count do
			local v14, v15 = v13[i]:await()
			result[i] = v14 and v15 or false
		end

		return result
	end)
end

local function grantPurchase(p, p2, p3)
	local ownershipRecord = getOwnershipRecord(p, p2, p3)

	if ownershipRecord.Changed then
		ownershipRecord.Changed:FireDeferred(true)
	end

	if ownershipRecord.Promise then
		ownershipRecord.Promise:cancel()
	end

	if RunContext.IsServer then
		reliableEvent:Server():FireAll(p, p2, p3)
	end

	ownershipRecord.Promise = Promise.resolve(true)
	promptPurchaseFinished2:Fire(p, p2, p3)
end

local function promptPurchase(productId, p2, localPlayer)
	if RunContext.IsClient and not RunContext.IsEdit then
		reliableEvent2:Client():Fire(productId, p2 or Enum.InfoType.Asset)
		return
	end

	if RunContext.IsEdit then
		localPlayer = Players.LocalPlayer
	end

	if not localPlayer then
		return
	end

	local flag

	if next(v7) == nil then
		flag = false
	else
		local flag2 = true

		for _, v13 in v7 do
			if v13() then
				continue
			end

			flag = false
			flag2 = false
			break
		end

		if flag2 then
			flag = true
		end
	end

	if flag or RunContext.IsEdit then
		if flag then
			warn("MOCKING PURCHASE", productId, p2, "FOR PLAYER", localPlayer)
		elseif RunContext.IsEdit then
			warn("MOCKING PURCHASE IN EDIT MODE", productId, p2, "FOR PLAYER", localPlayer)
		end

		if p2 == Enum.InfoType.Product then
			task.spawn(function()
				if mockReceiptAsync(localPlayer, productId) == Enum.ProductPurchaseDecision.PurchaseGranted then
					grantPurchase(localPlayer, productId, Enum.InfoType.Product)
				end
			end)
		else
			grantPurchase(localPlayer, productId, p2 or Enum.InfoType.Asset)
		end
	elseif p2 == Enum.InfoType.GamePass then
		MarketplaceService:PromptGamePassPurchase(localPlayer, productId)
	elseif p2 == Enum.InfoType.Bundle then
		MarketplaceService:PromptBundlePurchase(localPlayer, productId)
	elseif p2 == Enum.InfoType.Product then
		MarketplaceService:PromptProductPurchase(localPlayer, productId)
	else
		MarketplaceService:PromptPurchase(localPlayer, productId)
	end
end

if RunContext.IsServer or RunContext.IsEdit then
	reliableEvent2:Server():On(function(p, productId, p3)
		for k, v13 in v8 do
			if v13(p, productId, p3) then
				continue
			end

			warn("Purchase blocked by validator", k, "for player", p, "id", productId, "infoType", p3)
			return
		end

		promptPurchase(productId, p3, p)
	end)
	reliableEvent3:Server():On(function(p, id: number, p3)
		local server = reliableEvent4:Server()
		promiseProductInfo(id, p3, true):andThen(function(p4)
			server:Fire(p, id, p3, true, p4)
		end):catch(function(p4)
			server:Fire(p, id, p3, false, (tostring(p4)))
		end)
	end)
	reliableEvent5:Server():On(function(p, p2: number, p3, p4)
		local server = reliableEvent6:Server()
		local playerByUserId = Players:GetPlayerByUserId(p2)

		if playerByUserId then
			promiseOwnership(playerByUserId, p3, p4):andThen(function(p5)
				server:Fire(p, p2, p3, p4, true, p5)
			end):catch(function(p5)
				server:Fire(p, p2, p3, p4, false, (tostring(p5)))
			end)
		else
			server:Fire(p, p2, p3, p4, false, "Player not found")
		end
	end)

	local function createPurchaseFinishedCallback(p)
		return function(player, p2, flag: boolean)
			if not (player:IsA("Player") and flag) then
				return
			end

			grantPurchase(player, p2, p)
		end
	end

	local promptPurchaseFinished = MarketplaceService.PromptPurchaseFinished
	local asset = Enum.InfoType.Asset
	promptPurchaseFinished:Connect(function(player, p, flag: boolean)
		if not (player:IsA("Player") and flag) then
			return
		end

		grantPurchase(player, p, asset)
	end)
	local promptBundlePurchaseFinished = MarketplaceService.PromptBundlePurchaseFinished
	local bundle = Enum.InfoType.Bundle
	promptBundlePurchaseFinished:Connect(function(player, p, flag: boolean)
		if not (player:IsA("Player") and flag) then
			return
		end

		grantPurchase(player, p, bundle)
	end)
	local promptGamePassPurchaseFinished = MarketplaceService.PromptGamePassPurchaseFinished
	local gamePass = Enum.InfoType.GamePass
	promptGamePassPurchaseFinished:Connect(function(player, p, flag: boolean)
		if not (player:IsA("Player") and flag) then
			return
		end

		grantPurchase(player, p, gamePass)
	end)
	local promptSubscriptionPurchaseFinished = MarketplaceService.PromptSubscriptionPurchaseFinished
	local subscription = Enum.InfoType.Subscription
	promptSubscriptionPurchaseFinished:Connect(function(player, p, flag: boolean)
		if not (player:IsA("Player") and flag) then
			return
		end

		grantPurchase(player, p, subscription)
	end)

	local function onPlayerRemoving(p)
		local v13 = v[p]

		if v13 then
			for _, v14 in v13 do
				if v14.Changed then
					v14.Changed:Destroy()
				end

				if v14.Promise then
					v14.Promise:cancel()
				end
			end

			v[p] = nil
		end
	end

	Players.PlayerRemoving:Connect(onPlayerRemoving)
elseif not RunContext.IsEdit then
	local client = reliableEvent4:Client()
	local client2 = reliableEvent:Client()
	local client3 = reliableEvent6:Client()
	client:On(function(p: number, p2, flag: boolean, p3)
		local formatted = `{p2.Name}_{p}`
		local v13 = v4[formatted]
		v4[formatted] = nil

		if v13 then
			if flag then
				v13.Resolve(p3)
			else
				v13.Reject(p3)
			end
		end
	end)
	client3:On(function(p: number, p2, p3, flag: boolean, p4)
		local formatted = `{p}_{p3.Name}_{p2}`
		local v13 = v3[formatted]
		v3[formatted] = nil

		if v13 then
			if flag then
				v13.Resolve(p4 == true)
			else
				v13.Reject(p4)
			end
		else
			local playerByUserId = flag and Players:GetPlayerByUserId(p)

			if playerByUserId then
				local ownershipRecord = getOwnershipRecord(playerByUserId, p2, p3)

				if not ownershipRecord.Promise then
					ownershipRecord.Promise = Promise.resolve(p4 == true)
				end
			end
		end
	end)
	client2:On(grantPurchase)
end

local function remover(callback)
	return function(p)
		callback(p, nil)
	end
end

return table.freeze({
	GetOwnership = promiseOwnership,
	GetProductInfo = promiseProductInfo,
	PrefetchProductInfo = prefetchProductInfo,
	GrantPurchase = grantPurchase,
	PromptPurchase = promptPurchase,
	BulkResolveOwnership = bulkResolveOwnership,
	GetOwnershipChangedSignal = getOwnershipChangedSignal,
	SetReceiptHandler = setReceiptHandler,
	SetMockEconomyCheck = setMockEconomyCheck,
	SetPurchaseValidator = setPurchaseValidator,
	SetProductOwnershipChecker = setProductOwnershipChecker,
	AddReceiptHandler = setReceiptHandler,
	AddMockEconomyCheck = setMockEconomyCheck,
	AddPurchaseValidator = setPurchaseValidator,
	AddProductOwnershipChecker = setProductOwnershipChecker,
	RemoveReceiptHandler = function(p)
		setReceiptHandler(p, nil)
	end,
	RemoveMockEconomyCheck = function(p)
		setMockEconomyCheck(p, nil)
	end,
	RemovePurchaseValidator = function(p)
		setPurchaseValidator(p, nil)
	end,
	RemoveProductOwnershipChecker = function(p)
		setProductOwnershipChecker(p, nil)
	end,
	ProductGranted = productGranted,
	MockReceiptAsync = mockReceiptAsync,
	ProcessReceiptAsync = processReceiptAsync,
	PromptPurchaseFinished = promptPurchaseFinished2
})