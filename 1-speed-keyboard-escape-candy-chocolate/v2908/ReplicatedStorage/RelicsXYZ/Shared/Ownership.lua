local Ownership = {}
local parent = script.Parent
require(parent.Promise)
local Bundles = require(parent.Bundles)
require(parent.Migration)
local Marketplace = require(parent.Marketplace)

function Ownership.KeyOf(p: number, p2)
	return (`{p2.Name}:{p}`)
end

function Ownership.Get(data, options, callback)
	local result = options or {}

	if not data then
		return result
	end

	local productId = data.ProductId
	local productType = data.ProductType

	if productId == nil or productType == nil then
		return result
	end

	local v

	if type(callback) == "function" then
		v = callback(data)
	else
		v = callback or Ownership.KeyOf(productId, productType)
	end

	local legacyIds = data.LegacyIds
	local giftProductId = data.GiftProductId
	local purchaseBundleProducts = Bundles.GetPurchaseBundleProducts(productId, productType)
	table.insert(result, {
		Id = productId,
		InfoType = productType,
		Key = v
	})

	if legacyIds then
		for _, legacyId in ipairs(legacyIds) do
			table.insert(result, {
				Id = legacyId.Id,
				InfoType = legacyId.InfoType,
				Key = v
			})
		end
	end

	if giftProductId then
		table.insert(result, {
			Id = giftProductId,
			InfoType = Enum.InfoType.Product,
			Key = v
		})
	end

	if purchaseBundleProducts then
		for _, purchaseBundleProduct in ipairs(purchaseBundleProducts) do
			table.insert(result, {
				Id = purchaseBundleProduct.Id,
				InfoType = purchaseBundleProduct.InfoType,
				Key = v
			})
		end
	end

	return result
end

function Ownership.BulkGet(items, callback)
	local v = {}

	for k, item in items do
		Ownership.Get(item, v, callback or k)
	end

	return v
end

function Ownership.PromisePlayerOwns(p, p2)
	local v = Ownership.Get(p2)
	return Marketplace.BulkResolveOwnership(p, v):andThen(function(items)
		for _, item in pairs(items) do
			if item then
				return true
			end
		end

		return false
	end)
end

function Ownership.PlayerOwnsAsync(p, p2)
	local v, v2 = Ownership.PromisePlayerOwns(p, p2):await()
	return v and v2 or false
end

return Ownership