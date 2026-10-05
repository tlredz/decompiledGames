local parent = script.Parent
local Tags = require(parent.Tags)
local Guard = require(parent.Guard)
local Signal = require(parent.Signal)
local Backend = require(parent.Backend)
local Network = require(parent.Network)
require(parent.Promise)
local Secrets = require(parent.Secrets)
local Migration = require(parent.Migration)
local Ownership = require(parent.Ownership)
local PlayerData = require(parent.PlayerData)
local RunContext = require(parent.RunContext)
local ClientReady = require(parent.ClientReady)
local Marketplace = require(parent.Marketplace)
local ModelSquash = require(parent.ModelSquash)
local v = {}
local v2 = {}
local thread = coroutine.running()
shared._relicsGamePassThread = thread
local v3 = Signal.new()
local gamePassAdded = Signal.new()
local gamePassRemoved = Signal.new()
local v6 = Signal.new()
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local EncodingService = game:GetService("EncodingService")
local reliableEvent = Network.ReliableEvent("DEV_ClearGifts", function(player)
	local v7

	if typeof(player) == "Instance" then
		v7 = player:IsA("Player")
	else
		v7 = false
	end

	assert(v7)
	return player
end)
local reliableEvent2 = Network.ReliableEvent("PerformGiftTransaction", function(value, player)
	assert(type(value) == "string")
	assert(v[value] ~= nil)
	local v7

	if typeof(player) == "Instance" then
		v7 = player:IsA("Player")
	else
		v7 = false
	end

	assert(v7)
	return value, player
end)
local reliableEvent3 = Network.ReliableEvent("GiftTransactionResponse", function(value, player, p, value2)
	assert(type(value) == "string")
	assert(v[value] ~= nil)
	local v7

	if typeof(player) == "Instance" then
		v7 = player:IsA("Player")
	else
		v7 = false
	end

	assert(v7)
	assert(type(p) == "boolean")
	assert(type(value2) == "string" or value2 == nil)
	return value, player, p, value2
end)
local reliableEvent4 = Network.ReliableEvent("DEV_GamePassRefresh")

local function performGiftTransactionImpl(p, gamePassId: string, recipient)
	if RunContext.IsClient then
		reliableEvent2:Client():Fire(gamePassId, recipient)
	end

	local v7 = v[gamePassId]

	if not v7 then
		return false, "Game pass not found: " .. tostring(gamePassId)
	end

	if not v7.GiftProductId then
		return false, "Game pass does not have a gift product id: " .. tostring(gamePassId)
	end

	if Ownership.PlayerOwnsAsync(recipient, v7) then
		return false, "Recipient already owns the game pass"
	end

	v2[p] = {
		GamePassId = gamePassId,
		Recipient = recipient
	}
	Marketplace.PromptPurchase(v7.GiftProductId, Enum.InfoType.Product, p)
	return true, nil
end

if RunContext.IsServer or RunContext.IsEdit then
	if shared._relicsGamePassUpdateThread then
		task.cancel(shared._relicsGamePassUpdateThread)
	end

	local v7 = 1e999
	local v8 = {}
	local v9 = {}
	script:ClearAllChildren()

	local function registerSecret(p)
		ClientReady.WaitForClient(p)

		for _, v10 in ipairs(v9) do
			Secrets.RegisterSecretForUser(p, `rbxassetid://{v10.id}`, v10.secret, true)
		end
	end

	local function handleGiftTransaction(data)
		local playerByUserId = Players:GetPlayerByUserId(data.PlayerId)
		local v10 = playerByUserId and v2[playerByUserId]

		if not v10 then
			warn(
				"[RelicsXYZ.GamePasses] Received gift transaction for player",
				data.PlayerId,
				"but no pending gift transaction was found!"
			)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local gamePassId = v10.GamePassId
		local recipient = v10.Recipient

		if not (gamePassId and recipient) then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local v11 = v[gamePassId]

		if not v11 then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		if v11.GiftProductId ~= data.ProductId then
			warn(
				"[RelicsXYZ.GamePasses] Received gift transaction for productId",
				data.ProductId,
				"but expected",
				v11.GiftProductId,
				"for game pass",
				gamePassId
			)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local v12 = PlayerData.Read(recipient.UserId)

		if v12 and v12.Receipts[gamePassId] then
			warn(
				"[RelicsXYZ.GamePasses] Recipient",
				recipient.UserId,
				"already has a receipt for game pass",
				gamePassId,
				v12.Receipts[gamePassId]
			)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		if not PlayerData.Patch(recipient.UserId, function(p)
			p.Receipts[gamePassId] = {
				ProductId = data.ProductId,
				RobuxSpent = data.CurrencySpent,
				PlaceId = data.PlaceIdWherePurchased,
				PurchaseTime = os.time()
			}
		end):andThen(function()
			PlayerData.Get(recipient.UserId):Save(true)
		end):await() then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		v2[playerByUserId] = nil
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local function loadContentFromMetadata(value, p)
		local v10 = nil

		if type(value) == "buffer" then
			v10 = ModelSquash.Deserialize(value)
		elseif type(value) == "table" then
			local model = value.Model

			if type(model) == "buffer" then
				v10 = ModelSquash.Deserialize(model)
				value.Model = nil
			elseif p then
				v10 = p
			else
				v10 = Instance.new("Configuration")
				v10.Name = "Metadata"
			end

			for k, item in pairs(value) do
				if not (type(item) == "string" or type(item) == "number" or type(item) == "boolean") then
					continue
				end

				v10:SetAttribute(k, item)
			end
		end

		if not v10 then
			return nil
		end

		for _, v11 in v10:QueryDescendants("StringValue .RelicsModelPtr") do
			local value2 = v11.Value
			local flag = false

			for _, v13 in Tags.GetTagged("RelicsModel") do
				local aliases = v13:GetAttribute("Aliases")

				if v13.Name == value2 then
					local clone = v13:Clone()
					clone:RemoveTag("RelicsModel")
					clone.Name = v11.Name
					clone.Parent = v11.Parent
					flag = true
					break
				elseif type(aliases) == "string" then
					for _, v15 in aliases:split(",") do
						if v15 ~= value2 then
							continue
						end

						local clone = v13:Clone()
						clone:RemoveTag("RelicsModel")
						clone.Name = v11.Name
						clone.Parent = v11.Parent
						flag = true
						break
					end
				end
			end

			if flag then
				v11:Destroy()
			else
				warn(
					"[RelicsXYZ.GamePasses] Failed to resolve RelicsModelPtr at",
					v11:GetFullName(),
					"to model named",
					value2
				)
			end
		end

		if v10:HasTag("RelicsGamePassContent") then
			v10:SetAttribute("RelicsGamePassId", nil)
			v10:RemoveTag("RelicsGamePassContent")
		end

		local songId = v10:GetAttribute("SongId")
		local secret = v10:GetAttribute("Secret")

		if secret then
			v10:SetAttribute("Secret", nil)
		end

		if type(songId) ~= "string" then
			return v10
		end

		local v11 = type(secret) == "string"
		v10:SetAttribute("SongIsEncrypted", v11)

		if not v11 then
			return v10
		end

		table.insert(v9, {
			id = songId,
			secret = secret
		})

		if RunContext.IsEdit then
			if tonumber(songId) then
				songId = `rbxassetid://{songId}`
			end

			Secrets.RegisterEncryptedAsset(songId, secret)
		end

		return v10
	end

	local function updateGamepasses(flag: boolean?)
		v7 = 1e999
		Backend.GET("roblox/games/game-passes", nil, flag):andThen(function(list)
			local endDate = 1e999
			local v10 = {}

			if list == nil then
				return
			end

			for _, v11 in ipairs(list) do
				local parent2 = v8[v11.id]
				local metadata = v11.metadata

				if not parent2 then
					parent2 = Instance.new("Configuration")
					parent2.Name = v11.name
					parent2.Archivable = false
					parent2.Parent = script
					v8[v11.id] = parent2
				end

				v10[v11.id] = true
				local relicsAssetType = v11.relicsAssetType
				local v13 = tonumber(v11.assetId:match("%d+$")) or 0
				local v14 = not metadata and "{}" or HttpService:JSONEncode(metadata)
				local resolved, v15 = Migration.Resolve(v11.id, v11.name, v13, v14)
				local v16 = parent2.Name:sub(1, 8) == "@CONFIG_"
				local v17

				if v16 then
					v17 = parent2.Name:sub(9) or nil
				end

				if v17 and v17:sub(1, 6) ~= "Relics" then
					v16 = false
					v17 = nil
				end

				local v18 = nil
				local giftProductId = nil
				local v19

				if metadata then
					local v20

					if type(metadata) == "table" then
						v20 = HttpService:JSONEncode(metadata)
					elseif type(metadata) == "buffer" then
						v20 = buffer.tostring(metadata)
					else
						v20 = tostring(metadata)
					end

					v19 = EncodingService:ComputeStringHash(v20, Enum.HashAlgorithm.Blake2b)

					if parent2:GetAttribute("ContentHash") ~= v19 then
						local v21, v22 = xpcall(loadContentFromMetadata, function(p)
							warn("FAILED TO LOAD MODEL FROM METADATA", p, debug.traceback())
						end, metadata, v16 and parent2 or nil)

						if v21 and v22 then
							v18 = v22
						end
					end
				end

				if v18 then
					if v16 and v17 then
						v18:AddTag(v17)
						continue
					end

					if v18:HasTag("RelicsGamePassContent") then
						v18:SetAttribute("RelicsGamePassId", nil)
						v18:RemoveTag("RelicsGamePassContent")
					end

					local v20 = parent2:FindFirstChild("ContentRef")

					if not (v20 and v20:IsA("ObjectValue")) then
						v20 = Instance.new("ObjectValue")
						v20.Name = "ContentRef"
						v20.Parent = parent2
					end

					local productId = tonumber(v18:GetAttribute("ProductId"))
					giftProductId = tonumber(v18:GetAttribute("GiftProductId"))
					local productType = v18:GetAttribute("ProductType")
					local legacyIds = v18:GetAttribute("LegacyIds")
					local v21 = productType ~= nil

					if typeof(productType) ~= "EnumItem" or not productType:IsA("InfoType") then
						if type(productType) == "string" then
							productType = Enum.InfoType:FromName(productType) or Enum.InfoType.Asset
						else
							productType = Enum.InfoType.Asset
						end
					end

					if productId and productId > 0 then
						if productType == Enum.InfoType.Asset then
							if v15 ~= v13 then
								v18:SetAttribute("GamePass", v13)
							end

							resolved = productId
							v15 = v13
						elseif productType == Enum.InfoType.GamePass then
							v15 = productId
						end
					elseif v21 then
						if productType == Enum.InfoType.Asset then
							resolved = v13
							v15 = 0
						elseif productType == Enum.InfoType.GamePass then
							v15 = v13
							resolved = 0
						end
					end

					local accessoryId = tonumber(v18:GetAttribute("AccessoryId"))

					if accessoryId and accessoryId > 0 and accessoryId ~= v13 then
						if v13 > 0 and v15 == 0 then
							v15 = v13
						end

						resolved = accessoryId
					end

					if type(legacyIds) == "string" or type(legacyIds) == "number" then
						parent2:SetAttribute("LegacyIds", legacyIds)
					elseif resolved > 0 and v15 > 0 and resolved ~= v15 then
						parent2:SetAttribute("LegacyIds", (`{v15}:GamePass`))
					else
						parent2:SetAttribute("LegacyIds", nil)
					end

					v20.Value = v18
					parent2:SetAttribute("ContentHash", v19)
					v18:SetAttribute("RelicsGamePassId", v11.id)
					task.defer(function()
						v18:AddTag("RelicsGamePassContent")
					end)
					v18.Name = v11.name
					v18.Parent = parent2
				end

				if resolved then
					parent2:SetAttribute("AssetId", resolved)
				end

				if v15 then
					parent2:SetAttribute("GamePass", v15)
				end

				if giftProductId then
					parent2:SetAttribute("GiftProductId", giftProductId)
					Marketplace.SetReceiptHandler(giftProductId, handleGiftTransaction)
				end

				parent2:SetAttribute("Id", v11.id)
				parent2:SetAttribute("ProductId", resolved > 0 and resolved or v15 or v13)
				parent2:SetAttribute("ProductType", resolved > 0 and Enum.InfoType.Asset or Enum.InfoType.GamePass)
				parent2:SetAttribute("RawMetadata", v14)
				parent2:SetAttribute("IsActive", v11.isActive)
				parent2:SetAttribute("IsFeatured", v11.isFeatured)
				parent2:SetAttribute("Description", v11.description)
				parent2:SetAttribute("RelicsAssetType", relicsAssetType)
				parent2:SetAttribute("ItemImageAssetId", v11.itemImageAssetId)
				parent2:SetAttribute("BrandImageAssetId", v11.brandImageAssetId)
				parent2:SetAttribute("BackgroundImageAssetId", v11.backgroundImageAssetId)
				parent2:SetAttribute("StartDate", v11.startDate)
				parent2:SetAttribute("EndDate", v11.endDate)
				parent2:SetAttribute("SortOrder", v11.sort)

				if v11.endDate and v11.endDate < endDate then
					endDate = v11.endDate
				end

				parent2:AddTag("RelicsGamePass")
			end

			for _, v11 in Players:GetPlayers() do
				task.spawn(registerSecret, v11)
			end

			for k, v11 in pairs(v8) do
				if not v10[k] then
					v11:Destroy()
				end
			end

			v7 = endDate
		end):catch(function(p)
			warn("Failed to update game passes:", p, p.StatusCode, p.StatusMessage, debug.traceback())
		end):finally(function()
			if shared._relicsGamePassThread ~= thread then
				return
			end

			local v10 = not (v7 < 1e999) and 3600 or math.clamp(v7 - os.time(), 300, 3600)
			shared._relicsGamePassUpdateThread = task.delay(v10, function()
				v3:Fire()
			end)
		end)
	end

	Players.PlayerAdded:Connect(registerSecret)
	v3:Connect(updateGamepasses)
	v3:Fire()
	local server = reliableEvent:Server()
	local server2 = reliableEvent4:Server()
	local server3 = reliableEvent2:Server()
	local server4 = reliableEvent3:Server()
	server:On(function(p)
		if Backend.IsRelicsDev(p) then
			PlayerData.Patch(p.UserId, function(p2)
				table.clear(p2.Receipts)
			end)
		end
	end)
	server2:On(function(p)
		if Backend.IsRelicsDev(p) then
			table.clear(v8)
			script:ClearAllChildren()
			updateGamepasses(true)
		end
	end)
	server3:On(function(p, gamePassId: string, recipient)
		local v10, v11 = performGiftTransactionImpl(p, gamePassId, recipient)
		server4:Fire(p, v10, v11)
	end)
end

if RunContext.IsClient or RunContext.IsEdit then
	reliableEvent3:Client():On(function(p: string, p2, flag: boolean, p3: string?)
		v6:Fire(p, p2, flag, p3)
	end)
end

local function guardAttribute(instance, attributeName: string, callback)
	return callback((instance:GetAttribute(attributeName)))
end

local function guardRelicsAssetType(instance)
	local string = Guard.String((instance:GetAttribute("RelicsAssetType")))

	if string == "AURA" or string == "SKIN" or string == "EMOTE" or string == "PLAYLIST" then
		return string
	end

	error("Invalid RelicsAssetType: " .. tostring(string))
end

local function guardProductType(instance)
	local productType = instance:GetAttribute("ProductType")

	if typeof(productType) == "EnumItem" then
		if productType:IsA("InfoType") then
			return productType
		else
			error("Invalid ProductType: " .. tostring(productType))
		end
	end

	return Enum.InfoType.Asset
end

local function getGamePassData(instance)
	local v7 = Guard.Optional(Guard.Number)((instance:GetAttribute("StartDate")))
	local v8 = Guard.Optional(Guard.Number)((instance:GetAttribute("EndDate")))
	local contentRef = instance:FindFirstChild("ContentRef")
	local content

	if contentRef and contentRef:IsA("ObjectValue") then
		content = contentRef.Value
	end

	local legacyIds = instance:GetAttribute("LegacyIds")
	local legacyIds3 = nil

	if type(legacyIds) == "string" or type(legacyIds) == "number" then
		local legacyIds2 = Migration.ParseLegacyIds(legacyIds)

		if #legacyIds2 > 0 then
			legacyIds3 = legacyIds2
		end
	end

	local v10 = Guard.Optional(Guard.Number)((instance:GetAttribute("GamePass")))
	local asset = Guard.Optional(Guard.Number)((instance:GetAttribute("AssetId")))

	if asset and asset > 0 and v10 and v10 > 0 and asset ~= v10 then
		local v12 = legacyIds3 or {}
		local v13 = false

		for _, v15 in v12 do
			if not (v15.Id == v10 and v15.InfoType == Enum.InfoType.GamePass) then
				continue
			end

			v13 = true
			break
		end

		if not v13 then
			table.insert(v12, {
				Id = v10,
				InfoType = Enum.InfoType.GamePass
			})
			legacyIds3 = v12
		end
	end

	local string = Guard.String((instance:GetAttribute("Id")))
	local giftProductId = Guard.Optional(Guard.Number)((instance:GetAttribute("GiftProductId")))

	if giftProductId then
		Marketplace.SetProductOwnershipChecker(giftProductId, function(p)
			local v13 = PlayerData.Read(p.UserId)

			if v13 then
				return v13.Receipts[string] ~= nil
			end

			return false
		end)
	end

	local v13 = {
		Name = instance.Name,
		Content = content,
		Id = string,
		ProductId = Guard.Number((instance:GetAttribute("ProductId"))),
		ProductType = 0,
		GiftProductId = 0,
		IsActive = 0,
		IsFeatured = 0,
		Description = 0,
		ItemImageAssetId = 0,
		BackgroundImageAssetId = 0,
		BrandImageAssetId = 0,
		RawMetadata = 0,
		RelicsAssetType = 0,
		StartDate = 0,
		EndDate = 0,
		SortOrder = 0,
		SourceIds = 0,
		LegacyIds = 0
	}
	local productType = instance:GetAttribute("ProductType")

	if typeof(productType) == "EnumItem" then
		if not productType:IsA("InfoType") then
			error("Invalid ProductType: " .. tostring(productType))
			productType = Enum.InfoType.Asset
		end
	else
		productType = Enum.InfoType.Asset
	end

	v13.ProductType = productType
	v13.GiftProductId = giftProductId
	v13.IsActive = Guard.Boolean((instance:GetAttribute("IsActive")))
	v13.IsFeatured = Guard.Optional(Guard.Boolean)((instance:GetAttribute("IsFeatured")))
	v13.Description = Guard.Optional(Guard.String)((instance:GetAttribute("Description")))
	v13.ItemImageAssetId = Guard.Optional(Guard.String)((instance:GetAttribute("ItemImageAssetId")))
	v13.BackgroundImageAssetId = Guard.Optional(Guard.String)((instance:GetAttribute("BackgroundImageAssetId")))
	v13.BrandImageAssetId = Guard.Optional(Guard.String)((instance:GetAttribute("BrandImageAssetId")))
	v13.RawMetadata = Guard.Optional(Guard.String)((instance:GetAttribute("RawMetadata"))) or "{}"
	local string2 = Guard.String((instance:GetAttribute("RelicsAssetType")))

	if string2 ~= "AURA" and string2 ~= "SKIN" and string2 ~= "EMOTE" and string2 ~= "PLAYLIST" then
		error("Invalid RelicsAssetType: " .. tostring(string2))
		string2 = nil
	end

	v13.RelicsAssetType = string2
	v13.StartDate = v7 and DateTime.fromUnixTimestamp(v7) or nil
	v13.EndDate = v8 and DateTime.fromUnixTimestamp(v8) or nil
	v13.SortOrder = Guard.Optional(Guard.Number)((instance:GetAttribute("SortOrder")))
	v13.SourceIds = {
		Asset = asset,
		GamePass = v10
	}
	v13.LegacyIds = legacyIds3
	return v13
end

Tags.BindWithMaid("RelicsGamePass", function(p, maid)
	local v7, v8 = xpcall(getGamePassData, function(p2)
		warn("[RelicsXYZ.GamePasses] Failed to get game pass data for node:", p.Name, "Error:", p2, debug.traceback())
	end, p)

	if v7 then
		v[v8.Id] = v8
		gamePassAdded:FireDeferred(v8)
		maid:Add(function()
			v[v8.Id] = nil
			gamePassRemoved:FireDeferred(v8)
		end)
	end
end)

local function tryGetGamePassData(p)
	local success, result = pcall(getGamePassData, p)

	if success then
		return result
	end

	return nil
end

local function findGamePass(p: string)
	return v[p]
end

local function findGamePassFromContent(instance)
	if not instance:IsDescendantOf(script) then
		return nil
	end

	local relicsGamePassId = instance:GetAttribute("RelicsGamePassId")

	if type(relicsGamePassId) == "string" then
		return v[relicsGamePassId]
	end

	return nil
end

local function findGamePassFromProductId(p: number, p2)
	local v7 = p2 or Enum.InfoType.GamePass

	for _, v8 in v do
		if v8.ProductId == p and v8.ProductType == v7 then
			return v8
		end
	end

	return nil
end

local function getGamePasses()
	return table.clone(v)
end

local function getFilteredGamePasses(data)
	local now = os.time()
	local includeInactive = data and data.IncludeInactive
	local includeExpired = data and data.IncludeExpired
	local assetType = data and data.AssetType
	local featured = data and data.Featured
	local nextRefreshTime = 1e999
	local gamePasses = {}

	for k, v9 in v do
		if not ((not assetType or v9.RelicsAssetType == assetType) and (featured == nil or v9.IsFeatured == featured) and (includeInactive or v9.IsActive)) then
			continue
		end

		if not includeExpired then
			local startDate = v9.StartDate
			local endDate = v9.EndDate

			if startDate and now < startDate.UnixTimestamp then
				nextRefreshTime = math.min(nextRefreshTime, startDate.UnixTimestamp)
				continue
			end

			if endDate then
				if endDate.UnixTimestamp < now then
					continue
				else
					nextRefreshTime = math.min(nextRefreshTime, endDate.UnixTimestamp)
				end
			end
		end

		gamePasses[k] = v9
	end

	return {
		GamePasses = gamePasses,
		NextRefreshTime = nextRefreshTime,
		SystemTimestamp = os.clock()
	}
end

local function performGiftTransaction(gamePassId: string, recipient, p3)
	if not RunContext.IsClient then
		assert(p3, "Sender must be provided on the server.")
		return performGiftTransactionImpl(p3, gamePassId, recipient)
	end

	reliableEvent2:Client():Fire(gamePassId, recipient)
	local v7, v8

	repeat
		local v9, v10
		v9, v10, v7, v8 = v6:Wait()
	until v9 == gamePassId and v10 == recipient

	return v7, v8
end

return table.freeze({
	ContentTag = "RelicsGamePassContent",
	GetGamePasses = getGamePasses,
	GamePassAdded = gamePassAdded,
	GamePassRemoved = gamePassRemoved,
	GetFilteredGamePasses = getFilteredGamePasses,
	FindGamePass = findGamePass,
	FindGamePassFromContent = findGamePassFromContent,
	FindGamePassFromProductId = findGamePassFromProductId,
	GetGamePassData = getGamePassData,
	TryGetGamePassData = tryGetGamePassData,
	PerformGiftTransaction = performGiftTransaction,
	_internal = table.freeze({
		ClearGifts = reliableEvent,
		GamePassRefresh = reliableEvent4
	})
})