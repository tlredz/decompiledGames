local parent = script.Parent
local Tags = require(parent.Tags)
local Guard = require(parent.Guard)
local Signal = require(parent.Signal)
local Backend = require(parent.Backend)
local Network = require(parent.Network)
require(parent.Promise)
local Secrets = require(parent.Secrets)
local Migration = require(parent.Migration)
local RunContext = require(parent.RunContext)
local ClientReady = require(parent.ClientReady)
local ModelSquash = require(parent.ModelSquash)
local v = {}
local thread = coroutine.running()
shared._relicsGamePassThread = thread
local gamePassAdded = Signal.new()
local gamePassRemoved = Signal.new()
local reliableEvent = Network.ReliableEvent("GamePassRefresh")
local v4 = Signal.new()
local HttpService = game:GetService("HttpService")
local EncodingService = game:GetService("EncodingService")
local Players = game:GetService("Players")

if RunContext.IsServer or RunContext.IsEdit then
	if shared._relicsGamePassUpdateThread then
		task.cancel(shared._relicsGamePassUpdateThread)
	end

	local v5 = 1e999
	local v6 = {}
	local v7 = {}
	script:ClearAllChildren()

	local function registerSecret(p)
		ClientReady.WaitForClient(p)

		for _, v8 in ipairs(v7) do
			Secrets.RegisterSecretForUser(p, `rbxassetid://{v8.id}`, v8.secret, true)
		end
	end

	local function updateGamepasses(flag: boolean?)
		v5 = 1e999
		Backend.GET("roblox/games/game-passes", nil, flag):andThen(function(list)
			local endDate = 1e999
			local v8 = {}

			if list == nil then
				return
			end

			for _, v9 in ipairs(list) do
				local parent2 = v6[v9.id]
				local metadata = v9.metadata

				if not parent2 then
					parent2 = Instance.new("Configuration")
					parent2.Name = v9.name
					parent2.Archivable = false
					parent2.Parent = script
					v6[v9.id] = parent2
				end

				v8[v9.id] = true
				local relicsAssetType = v9.relicsAssetType
				local v11 = tonumber(v9.assetId:match("%d+$")) or 0
				local v12 = not metadata and "{}" or HttpService:JSONEncode(metadata)
				local resolved, v13 = Migration.Resolve(v9.id, v9.name, v11, v12)
				local v14 = parent2.Name:sub(1, 8) == "@CONFIG_"
				local v15

				if v14 then
					v15 = parent2.Name:sub(9) or nil
				else
					v15 = nil
				end

				if v15 and v15:sub(1, 6) ~= "Relics" then
					v14 = false
					v15 = nil
				end

				if metadata then
					local v16

					if type(metadata) == "table" then
						v16 = HttpService:JSONEncode(metadata)
					elseif type(metadata) == "buffer" then
						v16 = buffer.tostring(metadata)
					else
						v16 = tostring(metadata)
					end

					local stringHash = EncodingService:ComputeStringHash(v16, Enum.HashAlgorithm.Blake2b)

					if parent2:GetAttribute("ContentHash") ~= stringHash then
						local metadata2 = metadata
						local v18, v19 = xpcall(function()
							local v20 = nil

							if type(metadata2) == "buffer" then
								v20 = ModelSquash.Deserialize(metadata2)
							elseif type(metadata2) == "table" then
								local model = metadata2.Model

								if type(model) == "buffer" then
									v20 = ModelSquash.Deserialize(model)
									metadata2.Model = nil
								elseif v14 and v15 then
									v20 = parent2
								else
									v20 = Instance.new("Configuration")
									v20.Name = "Metadata"
								end

								for k, item in pairs(metadata2) do
									if not (type(item) == "string" or type(item) == "number" or type(item) == "boolean") then
										continue
									end

									v20:SetAttribute(k, item)
								end
							end

							if not v20 then
								return v20
							end

							for k, v21 in v20:QueryDescendants("StringValue .RelicsModelPtr") do
								local value = v21.Value
								local flag2 = false

								for k2, v23 in Tags.GetTagged("RelicsModel") do
									local aliases = v23:GetAttribute("Aliases")

									if v23.Name == value then
										local clone = v23:Clone()
										clone:RemoveTag("RelicsModel")
										clone.Name = v21.Name
										clone.Parent = v21.Parent
										flag2 = true
										break
									elseif type(aliases) == "string" then
										for k3, v25 in aliases:split(",") do
											if v25 ~= value then
												continue
											end

											local clone = v23:Clone()
											clone:RemoveTag("RelicsModel")
											clone.Name = v21.Name
											clone.Parent = v21.Parent
											flag2 = true
											break
										end
									end
								end

								if flag2 then
									v21:Destroy()
								else
									warn(
										"[RelicsXYZ.GamePasses] Failed to resolve RelicsModelPtr at",
										v21:GetFullName(),
										"to model named",
										value
									)
								end
							end

							return v20
						end, function(p)
							warn("ERROR DESERIALIZING MODEL SQUASH BUFFER:", p, debug.traceback())
						end)

						if v18 and v19 then
							if v14 and v15 then
								v19:AddTag(v15)
								continue
							end

							if v19:HasTag("RelicsGamePassContent") then
								v19:SetAttribute("RelicsGamePassId", nil)
								v19:RemoveTag("RelicsGamePassContent")
							end

							local songId = v19:GetAttribute("SongId")
							local secret = v19:GetAttribute("Secret")
							v19:SetAttribute("Secret", nil)

							if type(songId) == "string" then
								local v20 = type(secret) == "string"
								v19:SetAttribute("SongIsEncrypted", v20)

								if v20 then
									table.insert(v7, {
										id = songId,
										secret = secret
									})

									if RunContext.IsEdit then
										if tonumber(songId) then
											songId = `rbxassetid://{songId}`
										end

										Secrets.RegisterEncryptedAsset(songId, secret)
									end
								end
							end

							local v20 = parent2:FindFirstChild("ContentRef")

							if not (v20 and v20:IsA("ObjectValue")) then
								v20 = Instance.new("ObjectValue")
								v20.Name = "ContentRef"
								v20.Parent = parent2
							end

							local productId = tonumber(v19:GetAttribute("ProductId"))
							local productType = v19:GetAttribute("ProductType")
							local legacyIds = v19:GetAttribute("LegacyIds")
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
									if v13 ~= v11 then
										v19:SetAttribute("GamePass", v11)
									end

									resolved = productId
									v13 = v11
								elseif productType == Enum.InfoType.GamePass then
									v13 = productId
								end
							elseif v21 then
								if productType == Enum.InfoType.Asset then
									resolved = v11
									v13 = 0
								elseif productType == Enum.InfoType.GamePass then
									v13 = v11
									resolved = 0
								end
							end

							local accessoryId = tonumber(v19:GetAttribute("AccessoryId"))

							if accessoryId and accessoryId > 0 and accessoryId ~= v11 then
								if v11 > 0 and v13 == 0 then
									v13 = v11
								end

								resolved = accessoryId
							end

							if type(legacyIds) == "string" or type(legacyIds) == "number" then
								parent2:SetAttribute("LegacyIds", legacyIds)
							elseif resolved > 0 and v13 > 0 and resolved ~= v13 then
								parent2:SetAttribute("LegacyIds", (`{v13}:GamePass`))
							else
								parent2:SetAttribute("LegacyIds", nil)
							end

							v20.Value = v19
							parent2:SetAttribute("ContentHash", stringHash)
							v19:SetAttribute("RelicsGamePassId", v9.id)
							local v22 = v19
							task.defer(function()
								v22:AddTag("RelicsGamePassContent")
							end)
							v19.Name = v9.name
							v19.Parent = parent2
						end
					end
				end

				if resolved then
					parent2:SetAttribute("AssetId", resolved)
				end

				if v13 then
					parent2:SetAttribute("GamePass", v13)
				end

				parent2:SetAttribute("Id", v9.id)
				parent2:SetAttribute("ProductId", resolved > 0 and resolved or v13 or v11)
				local asset = resolved > 0 and Enum.InfoType.Asset or Enum.InfoType.GamePass
				parent2:SetAttribute("ProductType", asset)
				parent2:SetAttribute("RawMetadata", v12)
				parent2:SetAttribute("IsActive", v9.isActive)
				parent2:SetAttribute("IsFeatured", v9.isFeatured)
				parent2:SetAttribute("Description", v9.description)
				parent2:SetAttribute("RelicsAssetType", relicsAssetType)
				parent2:SetAttribute("ItemImageAssetId", v9.itemImageAssetId)
				parent2:SetAttribute("BrandImageAssetId", v9.brandImageAssetId)
				parent2:SetAttribute("BackgroundImageAssetId", v9.backgroundImageAssetId)
				parent2:SetAttribute("StartDate", v9.startDate)
				parent2:SetAttribute("EndDate", v9.endDate)
				parent2:SetAttribute("SortOrder", v9.sort)

				if v9.endDate and v9.endDate < endDate then
					endDate = v9.endDate
				end

				parent2:AddTag("RelicsGamePass")
			end

			for _, v9 in Players:GetPlayers() do
				task.spawn(registerSecret, v9)
			end

			for k, v9 in pairs(v6) do
				if not v8[k] then
					v9:Destroy()
				end
			end

			v5 = endDate
		end):catch(function(p)
			warn("Failed to update game passes:", p, p.StatusCode, p.StatusMessage, debug.traceback())
		end):finally(function()
			if shared._relicsGamePassThread ~= thread then
				return
			end

			local v8 = not (v5 < 1e999) and 3600 or math.clamp(v5 - os.time(), 300, 3600)
			shared._relicsGamePassUpdateThread = task.delay(v8, function()
				v4:Fire()
			end)
		end)
	end

	Players.PlayerAdded:Connect(registerSecret)
	v4:Connect(updateGamepasses)
	v4:Fire()

	if reliableEvent then
		reliableEvent:Server():On(function(p)
			if Backend.IsRelicsDev(p) then
				table.clear(v6)
				script:ClearAllChildren()
				updateGamepasses(true)
			end
		end)
	end
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
	local v5 = Guard.Optional(Guard.Number)((instance:GetAttribute("StartDate")))
	local v6 = Guard.Optional(Guard.Number)((instance:GetAttribute("EndDate")))
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

	local v8 = Guard.Optional(Guard.Number)((instance:GetAttribute("GamePass")))
	local asset = Guard.Optional(Guard.Number)((instance:GetAttribute("AssetId")))

	if asset and asset > 0 and v8 and v8 > 0 and asset ~= v8 then
		local v10 = legacyIds3 or {}
		local v11 = false

		for _, v13 in v10 do
			if not (v13.Id == v8 and v13.InfoType == Enum.InfoType.GamePass) then
				continue
			end

			v11 = true
			break
		end

		if not v11 then
			table.insert(v10, {
				Id = v8,
				InfoType = Enum.InfoType.GamePass
			})
			legacyIds3 = v10
		end
	end

	local v10 = {
		Name = instance.Name,
		Content = content,
		Id = Guard.String((instance:GetAttribute("Id"))),
		ProductId = Guard.Number((instance:GetAttribute("ProductId"))),
		ProductType = 0,
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

	v10.ProductType = productType
	v10.IsActive = Guard.Boolean((instance:GetAttribute("IsActive")))
	v10.IsFeatured = Guard.Optional(Guard.Boolean)((instance:GetAttribute("IsFeatured")))
	v10.Description = Guard.Optional(Guard.String)((instance:GetAttribute("Description")))
	v10.ItemImageAssetId = Guard.Optional(Guard.String)((instance:GetAttribute("ItemImageAssetId")))
	v10.BackgroundImageAssetId = Guard.Optional(Guard.String)((instance:GetAttribute("BackgroundImageAssetId")))
	v10.BrandImageAssetId = Guard.Optional(Guard.String)((instance:GetAttribute("BrandImageAssetId")))
	v10.RawMetadata = Guard.Optional(Guard.String)((instance:GetAttribute("RawMetadata"))) or "{}"
	local string = Guard.String((instance:GetAttribute("RelicsAssetType")))

	if string ~= "AURA" and string ~= "SKIN" and string ~= "EMOTE" and string ~= "PLAYLIST" then
		error("Invalid RelicsAssetType: " .. tostring(string))
		string = nil
	end

	v10.RelicsAssetType = string
	v10.StartDate = v5 and DateTime.fromUnixTimestamp(v5) or nil
	v10.EndDate = v6 and DateTime.fromUnixTimestamp(v6) or nil
	v10.SortOrder = Guard.Optional(Guard.Number)((instance:GetAttribute("SortOrder")))
	v10.SourceIds = {
		Asset = asset,
		GamePass = v8
	}
	v10.LegacyIds = legacyIds3
	return v10
end

Tags.BindWithMaid("RelicsGamePass", function(p, maid)
	local v5, v6 = xpcall(getGamePassData, function(p2)
		warn("[RelicsXYZ.GamePasses] Failed to get game pass data for node:", p.Name, "Error:", p2, debug.traceback())
	end, p)

	if v5 then
		v[v6.Id] = v6
		gamePassAdded:FireDeferred(v6)
		maid:Add(function()
			v[v6.Id] = nil
			gamePassRemoved:FireDeferred(v6)
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
	local v5 = p2 or Enum.InfoType.GamePass

	for _, v6 in v do
		if v6.ProductId == p and v6.ProductType == v5 then
			return v6
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

	for k, v7 in v do
		if not ((not assetType or v7.RelicsAssetType == assetType) and (featured == nil or v7.IsFeatured == featured) and (includeInactive or v7.IsActive)) then
			continue
		end

		if not includeExpired then
			local startDate = v7.StartDate
			local endDate = v7.EndDate

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

		gamePasses[k] = v7
	end

	return {
		GamePasses = gamePasses,
		NextRefreshTime = nextRefreshTime,
		SystemTimestamp = os.clock()
	}
end

return table.freeze({
	ContentTag = "RelicsGamePassContent",
	Refresh = reliableEvent,
	GetGamePasses = getGamePasses,
	GamePassAdded = gamePassAdded,
	GamePassRemoved = gamePassRemoved,
	GetFilteredGamePasses = getFilteredGamePasses,
	FindGamePass = findGamePass,
	FindGamePassFromContent = findGamePassFromContent,
	FindGamePassFromProductId = findGamePassFromProductId,
	GetGamePassData = getGamePassData,
	TryGetGamePassData = tryGetGamePassData
})