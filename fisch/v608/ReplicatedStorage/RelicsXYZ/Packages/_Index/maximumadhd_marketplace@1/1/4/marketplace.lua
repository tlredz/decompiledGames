local parent = script.Parent
local Signal = require(parent.Signal)
local UserId = require(parent.UserId)
local Network = require(parent.Network)
local Promise = require(parent.Promise)
local RunContext = require(parent.RunContext)
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}

local function addMockEconomyCheck(p: string, callback)
	v5[p] = callback
end

local function removeMockEconomyCheck(p: string)
	v5[p] = nil
end

local function addPurchaseValidator(p: string, callback)
	assert(RunContext.IsServer, "Purchase validators can only be added from the server!")
	v6[p] = callback
end

local function removePurchaseValidator(p: string)
	assert(RunContext.IsServer, "Purchase validators can only be removed from the server!")
	v6[p] = nil
end

local function canMockEconomy()
	if next(v5) == nil then
		return false
	end

	for _, v7 in v5 do
		if not v7() then
			return false
		end
	end

	return true
end

local promisify = Promise.promisify(function(p, p2, p3)
	local v7, v8 = UserId.Get(p)

	if v7 < 1 then
		return RunContext.IsStudio
	end

	if p3 == Enum.InfoType.Subscription then
		if v8 then
			return true
		end

		return MarketplaceService:GetUserSubscriptionStatusAsync(p, p2).IsSubscribed
	else
		if p3 == Enum.InfoType.GamePass then
			return MarketplaceService:UserOwnsGamePassAsync(v7, p2)
		end

		if p3 == Enum.InfoType.Bundle then
			if v8 then
				return true
			end

			return MarketplaceService:PlayerOwnsBundleAsync(p, p2)
		else
			if p3 == Enum.InfoType.Product then
				return false
			end

			if v8 then
				return true
			end

			return MarketplaceService:PlayerOwnsAssetAsync(p, p2)
		end
	end
end)

local function enqueueProductInfoFetch(p, flag: boolean)
	local formatted = `{p.InfoType.Name}:{p.Id}`
	local v7 = v4[formatted]

	if v7 then
		local index = flag and table.find(v3, v7)

		if index then
			table.remove(v3, index)
			table.insert(v3, 1, v7)
		end
	else
		v4[formatted] = p

		if flag then
			table.insert(v3, 1, p)
		else
			table.insert(v3, p)
		end
	end
end

task.spawn(function()
	while task.wait(0.2) do
		local v7 = table.remove(v3, 1)

		if not v7 then
			continue
		end

		local formatted = `{v7.InfoType.Name}:{v7.Id}`
		v4[formatted] = nil
		local v8 = v7
		local success, result = pcall(function()
			return MarketplaceService:GetProductInfoAsync(v8.Id, v8.InfoType)
		end)

		if success then
			v7.Resolve(result)
		else
			v7.Attempts += 1

			if v7.Attempts < 5 then
				local v9 = v7
				task.delay(2, function()
					local v10 = v9
					local formatted2 = `{v10.InfoType.Name}:{v10.Id}`

					if v4[formatted2] then
						return
					end

					v4[formatted2] = v10
					table.insert(v3, v10)
				end)
			else
				v7.Reject(result)
			end
		end
	end
end)
local reliableEvent = Network.ReliableEvent("Marketplace_GrantPurchase", function(player, p, infoType)
	local v7

	if typeof(player) == "Instance" then
		v7 = player:IsA("Player")
	else
		v7 = false
	end

	assert(v7)
	assert(p ~= nil)

	if infoType == nil then
		return player, p, Enum.InfoType.Asset
	end

	local v8

	if typeof(infoType) == "EnumItem" then
		v8 = infoType:IsA("InfoType")
	else
		v8 = false
	end

	assert(v8)
	return player, p, infoType
end)
local reliableEvent2 = Network.ReliableEvent("Marketplace_PromptPurchase", function(p, infoType)
	assert(p ~= nil)

	if infoType == nil then
		return p, Enum.InfoType.Asset
	end

	local v7

	if typeof(infoType) == "EnumItem" then
		v7 = infoType:IsA("InfoType")
	else
		v7 = false
	end

	assert(v7)
	return p, infoType
end)
local promptPurchaseFinished2 = Signal.new()

local function getOwnershipRecord(p, p2, p3)
	local v8 = p3 or Enum.InfoType.Asset
	local v9 = v[p]

	if not v9 then
		v[p] = {}
		v9 = v[p]
	end

	local formatted = `{v8.Name}:{p2}`
	local v10 = v9[formatted]

	if not v10 then
		v9[formatted] = {
			Promise = nil,
			Changed = Signal.new()
		}
		return v9[formatted]
	end

	return v10
end

local function promiseOwnership(p, id: number, infoType)
	local ownershipRecord = getOwnershipRecord(p, id, infoType)

	if ownershipRecord.Promise then
		return assert(ownershipRecord.Promise)
	end

	local flag

	if next(v5) == nil then
		flag = false
	else
		local flag2 = true

		for _, v8 in v5 do
			if v8() then
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
		ownershipRecord.Promise = Promise.resolve(false)
		return assert(ownershipRecord.Promise)
	end

	local promise = Promise.retryWithDelay(promisify, 5, 2, p, id, infoType)
	ownershipRecord.Promise = promise
	promise:catch(function(_)
		if ownershipRecord.Promise == promise then
			ownershipRecord.Promise = nil
		end
	end)
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
	local formatted = `{infoType.Name}:{id}`
	local v9 = v2[formatted]

	if v9 then
		if flag == false then
			return v9
		end

		local v10 = v4[formatted]

		if not v10 then
			return v9
		end

		for i = 1, #v3 do
			if v3[i] ~= v10 then
				continue
			end

			table.remove(v3, i)
			table.insert(v3, 1, v10)
			return v9
		end

		return v9
	else
		local v10 = Promise.new(function(resolve, reject)
			enqueueProductInfoFetch({
				Id = id,
				InfoType = infoType,
				Attempts = 0,
				Resolve = resolve,
				Reject = reject
			}, flag ~= false)
		end)
		v2[formatted] = v10
		v10:catch(function()
			if v2[formatted] == v10 then
				v2[formatted] = nil
			end
		end)
		return v10
	end
end

local function prefetchProductInfo(id: number, p2)
	return promiseProductInfo(id, p2, false)
end

local function bulkResolveOwnership(p, list)
	local count = #list
	local v8 = table.create(count)

	for i = 1, count do
		local v9 = list[i]

		if v9.Id == nil or v9.Id <= 0 then
			v8[i] = Promise.resolve(false)
		else
			v8[i] = promiseOwnership(p, v9.Id, v9.InfoType)
		end
	end

	return Promise.allSettled(v8):andThen(function()
		local result = table.create(count)

		for i = 1, count do
			local v9, v10 = v8[i]:await()
			result[i] = v9 and v10 or false
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

local function promptPurchase(p, p2, localPlayer)
	if RunContext.IsClient and not RunContext.IsEdit then
		reliableEvent2:Client():Fire(p, p2 or Enum.InfoType.Asset)
		return
	end

	if RunContext.IsEdit then
		localPlayer = Players.LocalPlayer
	end

	if not localPlayer then
		return
	end

	local flag

	if next(v5) == nil then
		flag = false
	else
		local flag2 = true

		for _, v8 in v5 do
			if v8() then
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
			warn("MOCKING PURCHASE", p, p2, "FOR PLAYER", localPlayer)
		elseif RunContext.IsEdit then
			warn("MOCKING PURCHASE IN EDIT MODE", p, p2, "FOR PLAYER", localPlayer)
		end

		grantPurchase(localPlayer, p, p2 or Enum.InfoType.Asset)
	elseif p2 == Enum.InfoType.GamePass then
		MarketplaceService:PromptGamePassPurchase(localPlayer, p)
	elseif p2 == Enum.InfoType.Bundle then
		MarketplaceService:PromptBundlePurchase(localPlayer, p)
	elseif p2 == Enum.InfoType.Product then
		MarketplaceService:PromptProductPurchase(localPlayer, p)
	else
		MarketplaceService:PromptPurchase(localPlayer, p)
	end
end

if RunContext.IsEdit and workspace:GetAttribute("EditModeMockEconomy") then
	function v5.__EditMode()
		return true
	end
end

if RunContext.IsServer or RunContext.IsEdit then
	reliableEvent2:Server():On(function(p, p2, p3)
		for k, v8 in v6 do
			if v8(p, p2, p3) then
				continue
			end

			warn("Purchase blocked by validator", k, "for player", p, "id", p2, "infoType", p3)
			return
		end

		promptPurchase(p2, p3, p)
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
		local v8 = v[p]

		if v8 then
			for _, v9 in v8 do
				if v9.Changed then
					v9.Changed:Destroy()
				end

				if v9.Promise then
					v9.Promise:cancel()
				end
			end

			v[p] = nil
		end
	end

	Players.PlayerRemoving:Connect(onPlayerRemoving)
elseif not RunContext.IsEdit then
	reliableEvent:Client():On(grantPurchase)
end

return table.freeze({
	GetOwnership = promiseOwnership,
	GetProductInfo = promiseProductInfo,
	PrefetchProductInfo = prefetchProductInfo,
	BulkResolveOwnership = bulkResolveOwnership,
	GetOwnershipChangedSignal = getOwnershipChangedSignal,
	AddPurchaseValidator = addPurchaseValidator,
	RemovePurchaseValidator = removePurchaseValidator,
	AddMockEconomyCheck = addMockEconomyCheck,
	RemoveMockEconomyCheck = removeMockEconomyCheck,
	PromptPurchase = promptPurchase,
	PromptPurchaseFinished = promptPurchaseFinished2
})