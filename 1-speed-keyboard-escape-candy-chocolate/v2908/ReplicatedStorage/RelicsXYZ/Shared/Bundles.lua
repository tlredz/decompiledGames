local parent = script.Parent
local Tags = require(parent.Tags)
local Guard = require(parent.Guard)
local Signal = require(parent.Signal)
local Backend = require(parent.Backend)
local Migration = require(parent.Migration)
local RunContext = require(parent.RunContext)
local Marketplace = require(parent.Marketplace)
local HttpService = game:GetService("HttpService")
local v = {}
local bundleAdded = Signal.new()
local bundleRemoved = Signal.new()

local function findPurchaseableRaw(p: string, p2: string)
	local v4 = game:QueryDescendants((`.{p} [$Id = {p2}]`))[1]
	local productId = v4 and v4:GetAttribute("ProductId")
	local productType = v4 and v4:GetAttribute("ProductType")

	if type(productId) ~= "number" or (typeof(productType) ~= "EnumItem" or not productType:IsA("InfoType")) then
		return nil
	end

	local legacyIds = v4:GetAttribute("LegacyIds")
	local legacyIds2

	if type(legacyIds) == "string" then
		legacyIds2 = Migration.ParseLegacyIds(legacyIds)
	end

	return {
		ProductId = productId,
		ProductType = productType,
		LegacyIds = legacyIds2
	}
end

local function resolveAssetId(p)
	local v4 = nil

	if p.ItemType == "GAME_PASS" then
		v4 = findPurchaseableRaw("RelicsGamePass", p.Id)
	elseif p.ItemType == "PLAYLIST" then
		v4 = findPurchaseableRaw("RelicsPlaylist", p.Id)
	end

	if v4 then
		return {
			Id = v4.ProductId,
			InfoType = v4.ProductType,
			Key = `{v4.ProductType.Name}:{v4.ProductId}`
		}
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
		for i = 1, 10 do
			if Tags.FindFirstTagged("RelicsGamePass") then
				break
			end

			warn((`[RELICSxyz.Bundles] Waiting for gamepasses to load... ({i}/{10})`))
			task.wait(1)
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
				local tagged = Tags.GetTagged("RelicsGamePass")
				local v9 = tonumber(tostring(v7.assetId or ""):match("%d+$")) or 0
				local v10 = {}
				local v11 = {}

				for i, v12 in ipairs(v7.items or {}) do
					local assetId = tostring(v12.assetId or "")
					local sort = v12.sort or i
					local itemType = v12.itemType
					local name

					if itemType == "UGC" then
						local v13 = tonumber(assetId:match("%d+$")) or -1

						for _, v15 in tagged do
							local relicsAssetType = v15:GetAttribute("RelicsAssetType")
							local productId = v15:GetAttribute("ProductId")

							if not (relicsAssetType == "SKIN" and productId == v13) then
								continue
							end

							name = v15.Name
							itemType = "GAME_PASS"
							break
						end

						if name then
							warn(
								"[RELICSxyz] UGC bundle items are deprecated. Found one with assetId",
								v13,
								", mapping to skin game pass:",
								name
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
						name = assetId:gsub("rbxassetid://", "")
					end

					local v13 = {
						Id = name,
						Sort = sort,
						ItemType = itemType
					}
					local v14 = nil

					if itemType == "GAME_PASS" then
						v14 = findPurchaseableRaw("RelicsGamePass", name)
					elseif itemType == "PLAYLIST" then
						v14 = findPurchaseableRaw("RelicsPlaylist", name)
					end

					if v14 then
						local legacyIds = v14.LegacyIds
						local productId = v14.ProductId
						local productType = v14.ProductType

						if legacyIds then
							for _, legacyId in legacyIds do
								v10[`{legacyId.InfoType.Name}:{legacyId.Id}`] = true
							end
						end

						table.insert(v11, v13)
						v10[`{productType.Name}:{productId}`] = true
					else
						warn(
							"[RELICSxyz] Bundle item references a non-existent",
							itemType,
							"with id:",
							name,
							"Dropping item."
						)
					end
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
	local v7 = {
		Id = Guard.String((instance:GetAttribute("Id"))),
		Name = Guard.Optional(Guard.String)((instance:GetAttribute("Name"))) or instance.Name,
		Type = 0,
		AssetId = 0,
		IsActive = 0,
		IsFeatured = 0,
		Sort = 0,
		CreatedAt = 0,
		Description = 0,
		Items = 0,
		Products = 0
	}
	local type2 = instance:GetAttribute("Type")

	if type2 ~= "LastItemLocked" and type2 ~= "PurchaseBundle" then
		warn("[RelicsXYZ.Bundles] Invalid bundle type for node:", instance.Name, "Defaulting to 'LastItemLocked'")
		type2 = "LastItemLocked"
	end

	v7.Type = type2
	v7.AssetId = Guard.Number((instance:GetAttribute("AssetId")))
	v7.IsActive = Guard.Boolean((instance:GetAttribute("IsActive")))
	v7.IsFeatured = Guard.Boolean((instance:GetAttribute("IsFeatured")))
	v7.Sort = Guard.Optional(Guard.Number)((instance:GetAttribute("Sort")))
	v7.CreatedAt = Guard.Optional(Guard.Number)((instance:GetAttribute("CreatedAt")))
	v7.Description = Guard.Optional(Guard.String)((instance:GetAttribute("Description")))
	v7.Items = items
	v7.Products = products

	for _, v8 in items do
		local assetId = resolveAssetId(v8)

		if not assetId then
			continue
		end

		products[`{assetId.InfoType.Name}:{assetId.Id}`] = v8
		Marketplace.GetProductInfo(assetId.Id, assetId.InfoType, true)
	end

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