local Ownership = {}
local parent = script.Parent
local Bundles = require(parent.Bundles)
require(parent.Migration)
local GamePasses = require(parent.GamePasses)

function Ownership.KeyOf(p: number, p2)
	return (`{p2.Name}:{p}`)
end

function Ownership.Get(value, options, callback)
	if type(value) == "string" then
		value = GamePasses.FindGamePass(value)
	end

	local result = options or {}

	if not value then
		return result
	end

	local productId = value.ProductId
	local productType = value.ProductType

	if productId == nil or productType == nil then
		return result
	end

	local v

	if type(callback) == "function" then
		v = callback(value)
	else
		v = callback or Ownership.KeyOf(productId, productType)
	end

	local legacyIds = value.LegacyIds
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

return Ownership