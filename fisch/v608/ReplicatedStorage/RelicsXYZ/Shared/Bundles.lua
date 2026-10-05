local parent = script.Parent
local Tags = require(parent.Tags)
local Guard = require(parent.Guard)
local Signal = require(parent.Signal)
local Backend = require(parent.Backend)
local MusicData = require(parent.MusicData)
local GamePasses = require(parent.GamePasses)
local RunContext = require(parent.RunContext)
local HttpService = game:GetService("HttpService")
local v = {}
local bundleAdded = Signal.new()
local bundleRemoved = Signal.new()

local function resolveAssetId(p)
	if p.ItemType == "GAME_PASS" then
		local gamePass = GamePasses.FindGamePass(p.Id)

		if gamePass then
			return {
				Id = gamePass.ProductId,
				InfoType = gamePass.ProductType or Enum.InfoType.GamePass
			}
		end
	else
		local v4 = p.ItemType == "PLAYLIST" and MusicData.FindPlaylistById(p.Id)

		if v4 then
			return {
				Id = v4.ProductId,
				InfoType = v4.ProductType
			}
		end
	end

	return nil
end

if RunContext.IsServer or RunContext.IsEdit then
	if shared._relicsBundleUpdateThread then
		task.cancel(shared._relicsBundleUpdateThread)
	end

	local v4 = Signal.new()
	local v5 = {}
	script:ClearAllChildren()

	local function updateBundles()
		for _ = 1, 10 do
			if Tags.FindFirstTagged("RelicsGamePass") then
				break
			else
				task.wait(1)
			end
		end

		Backend.GET("roblox/games/bundles?includeItemData=true"):andThen(function(list)
			local v6 = {}

			for _, v7 in ipairs(list) do
				local v8 = v5[v7.id]

				if not v8 then
					v8 = Instance.new("Configuration")
					v8.Name = v7.name
					v8.Archivable = false
					v8.Parent = script
				end

				v8:SetAttribute("Id", v7.id)
				v8:SetAttribute("Name", v7.name)
				v8:SetAttribute("IsActive", v7.isActive)
				v8:SetAttribute("IsFeatured", v7.isFeatured)
				v8:SetAttribute("Description", v7.description)
				v8:SetAttribute("Sort", v7.sort)
				v8:SetAttribute("CreatedAt", v7.createdAt)
				local gamePasses = GamePasses.GetGamePasses()
				local v9 = tonumber(tostring(v7.assetId or ""):match("%d+$")) or 0
				local v10 = {}
				local v11 = {}

				for i, v12 in ipairs(v7.items or {}) do
					local assetId = tostring(v12.assetId or "")
					local sort = v12.sort or i
					local itemType = v12.itemType
					local id

					if itemType == "UGC" then
						local v13 = tonumber(assetId:match("%d+$")) or -1

						for _, gamePass in gamePasses do
							if not (gamePass.RelicsAssetType == "SKIN" and gamePass.ProductId == v13) then
								continue
							end

							id = gamePass.Id
							itemType = "GAME_PASS"
							break
						end

						if id then
							warn(
								"[RELICSxyz] UGC bundle items are deprecated. Found one with assetId",
								v13,
								", mapping to skin game pass:",
								id
							)
						else
							warn(
								"[RELICSxyz] UGC bundle items are deprecated. Found one with assetId",
								v13,
								", dropping item."
							)
							continue
						end
					else
						id = assetId:gsub("rbxassetid://", "")
					end

					if itemType == "GAME_PASS" then
						local gamePass = GamePasses.FindGamePass(id)

						if not gamePass then
							continue
						end

						local productId = gamePass.ProductId
						local productType = gamePass.ProductType or Enum.InfoType.GamePass

						if productId and productType then
							v10[`{productType.Name}:{productId}`] = true
						end

						if gamePass.LegacyIds then
							for _, legacyId in ipairs(gamePass.LegacyIds) do
								v10[`{legacyId.InfoType.Name}:{legacyId.Id}`] = true
							end
						end
					elseif itemType == "PLAYLIST" then
						local playlist = MusicData.FindPlaylistById(id)

						if not playlist then
							warn("[RELICSxyz] Bundle item references a non-existent playlist:", id, "Dropping item.")
							continue
						end

						local productId = playlist.ProductId
						local productType = playlist.ProductType

						if productId and productType then
							v10[`{productType.Name}:{productId}`] = true
						end
					end

					table.insert(v11, {
						Id = id,
						Sort = sort,
						ItemType = itemType
					})
				end

				local v12 = false

				for _, v14 in Enum.InfoType:GetEnumItems() do
					if not v10[`{v14.Name}:{v9}`] then
						continue
					end

					v12 = true
					break
				end

				local jSONEncode = HttpService:JSONEncode(v11)
				v8:SetAttribute("AssetId", v9)
				v8:SetAttribute("ItemsJson", jSONEncode)
				v8:SetAttribute("Type", v12 and "LastItemLocked" or "PurchaseBundle")
				v5[v7.id] = v8
				v6[v7.id] = true
				v8:AddTag("RelicsBundle")
			end

			for k, v7 in pairs(v5) do
				if v6[k] then
					continue
				end

				v7:Destroy()
				v5[k] = nil
			end
		end):catch(function(p)
			warn("Failed to update bundles:", p, p.StatusCode, p.StatusMessage, debug.traceback())
		end):finally(function()
			shared._relicsBundleUpdateThread = task.delay(900, function()
				v4:Fire()
			end)
		end)
	end

	v4:Connect(updateBundles)
	v4:Fire()
end

local function guardAttribute(instance, attributeName: string, callback)
	return callback((instance:GetAttribute(attributeName)))
end

local function guardBundleType(instance)
	local type2 = instance:GetAttribute("Type")

	if type2 == "LastItemLocked" or type2 == "PurchaseBundle" then
		return type2
	end

	warn("[RelicsXYZ.Bundles] Invalid bundle type for node:", instance.Name, "Defaulting to 'LastItemLocked'")
	return "LastItemLocked"
end

local function getBundleData(instance)
	local v4 = Guard.Optional(Guard.String)((instance:GetAttribute("ItemsJson")))
	local items = {}

	if v4 then
		local success, result = pcall(function()
			return (HttpService:JSONDecode(v4))
		end)

		if success and type(result) == "table" then
			for k, v6 in result do
				if v6.Sort == nil then
					v6.Sort = k
				end
			end

			items = result
		end
	end

	local products = {}

	for _, v7 in items do
		local assetId = resolveAssetId(v7)

		if assetId then
			products[`{assetId.InfoType.Name}:{assetId.Id}`] = v7
		end
	end

	local v7 = {
		Id = Guard.String((instance:GetAttribute("Id"))),
		Name = Guard.Optional(Guard.String)((instance:GetAttribute("Name"))) or instance.Name,
		AssetId = Guard.Number((instance:GetAttribute("AssetId"))),
		IsActive = Guard.Boolean((instance:GetAttribute("IsActive"))),
		IsFeatured = Guard.Boolean((instance:GetAttribute("IsFeatured"))),
		Description = Guard.Optional(Guard.String)((instance:GetAttribute("Description"))),
		Sort = Guard.Optional(Guard.Number)((instance:GetAttribute("Sort"))),
		CreatedAt = Guard.Optional(Guard.Number)((instance:GetAttribute("CreatedAt"))),
		Type = 0,
		Items = 0,
		Products = 0
	}
	local type2 = instance:GetAttribute("Type")

	if type2 ~= "LastItemLocked" and type2 ~= "PurchaseBundle" then
		warn("[RelicsXYZ.Bundles] Invalid bundle type for node:", instance.Name, "Defaulting to 'LastItemLocked'")
		type2 = "LastItemLocked"
	end

	v7.Type = type2
	v7.Items = items
	v7.Products = products
	return v7
end

Tags.BindWithMaid("RelicsBundle", function(p, maid)
	local v4, v5 = xpcall(getBundleData, function(p2)
		warn("[RelicsXYZ.Bundles] Failed to get bundle data for node:", p.Name, "Error:", p2, debug.traceback())
	end, p)

	if v4 then
		v[v5.Id] = v5
		bundleAdded:Fire(v5)
		maid:Add(function()
			v[v5.Id] = nil
			bundleRemoved:Fire(v5)
		end)
	end
end)

local function findBundle(p: string)
	return v[p]
end

local function findFeaturedBundle()
	for _, v4 in v do
		if v4.IsActive and v4.IsFeatured then
			return v4
		end
	end

	return nil
end

local function getBundles()
	return table.clone(v)
end

local function getActiveBundles()
	local result = {}

	for _, v4 in v do
		if v4.IsActive then
			table.insert(result, v4)
		end
	end

	table.sort(result, function(a, b)
		local sort = a.Sort or 1e999
		local sort2 = b.Sort or 1e999

		if sort == sort2 then
			return (a.Name or "") < (b.Name or "")
		end

		return sort < sort2
	end)
	return result
end

local function getPurchaseBundleProducts(p: number, p2)
	local formatted = `{p2.Name}:{p}`
	local activeBundles = getActiveBundles()
	local result = {}

	for _, activeBundle in activeBundles do
		if activeBundle.Type == "PurchaseBundle" and activeBundle.Products[formatted] then
			table.insert(result, {
				Id = activeBundle.AssetId,
				InfoType = Enum.InfoType.Asset,
				Key = formatted
			})
		end
	end

	return result
end

local function isUnlockingAssetId(p: number)
	for _, v4 in getActiveBundles() do
		if v4.AssetId == p and v4.Type == "PurchaseBundle" then
			return true
		end
	end

	return false
end

local function getBundleByAssetId(p: number)
	for _, v4 in getActiveBundles() do
		if v4.AssetId == p then
			return v4
		end
	end

	return nil
end

return table.freeze({
	BundleAdded = bundleAdded,
	BundleRemoved = bundleRemoved,
	GetBundles = getBundles,
	GetActiveBundles = getActiveBundles,
	ResolveAssetId = resolveAssetId,
	GetBundleData = getBundleData,
	FindBundle = findBundle,
	FindFeaturedBundle = findFeaturedBundle,
	IsUnlockingAssetId = isUnlockingAssetId,
	GetBundleByAssetId = getBundleByAssetId,
	GetPurchaseBundleProducts = getPurchaseBundleProducts
})