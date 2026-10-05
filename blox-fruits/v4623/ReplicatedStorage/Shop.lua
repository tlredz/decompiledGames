local Result = require(game.ReplicatedStorage.Packages.Result)
require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
require(game.ReplicatedStorage.Economy.EconomyItem)
local FunctionCache = require(game.ReplicatedStorage.Util.FunctionCache)
local LEGACY_BELI_ITEMS = require(script.LEGACY_BELI_ITEMS)
local LIBRARY = require(script.LIBRARY)
local v = FunctionCache.new(function(items)
	local result = {}

	for _, item in items do
		local unwrapped = ItemConfig.match(item.ItemId):unwrap()
		local unwrapped2 = item:ToLegacy():unwrap()

		if result[unwrapped.Index.StorageKey] then
			error((`duplicate definition found for "{unwrapped.Index.StorageKey}"`))
		end

		if unwrapped2.subtype ~= "FruitMutation" and unwrapped2.subtype ~= "FruitSkin" and unwrapped2.subtype ~= "Skin Bundle" and unwrapped2.subtype ~= "AuraSkin" then
			local v2 = result[unwrapped.Display.Name or unwrapped.Index.StorageKey]

			if v2 then
				error((`duplicate definition found for "{unwrapped.Display.Name or unwrapped.Index.StorageKey}": {v2.StorageName} & {unwrapped2.StorageName}`))
			end

			local v3 = unwrapped.Index.StorageKey:gsub("Permanent ", "")

			if v3 ~= unwrapped.Index.StorageKey then
				if result[v3] then
					error((`duplicate definition found for "{v3}", a shortening of "{unwrapped.Index.DebugLabel}"`))
				end

				result[v3] = unwrapped2
			end

			result[unwrapped.Display.Name or unwrapped.Index.StorageKey] = unwrapped2
		end

		result[unwrapped.Index.StorageKey] = unwrapped2
	end

	table.freeze(result)
	return result
end, function(items)
	local itemIds = {}

	for _, item in items do
		table.insert(itemIds, item.ItemId)
	end

	return table.concat(itemIds)
end)
local Shop = {
	LIBRARY = LIBRARY,
	LEGACY_BELI_ITEMS = LEGACY_BELI_ITEMS,
	mapToLegacy = function(p)
		return table.clone(v:call(p))
	end
}
local mapToLegacy = Shop.mapToLegacy(LIBRARY.ALL)
local v2 = {}

for _, v3 in LIBRARY.ALL do
	v2[v3.ItemId] = v3
end

table.freeze(v2)
local v3 = FunctionCache.new(function(value)
	local v4

	if type(value) == "number" then
		v4 = ItemConfig.match(value):asNullable()
	else
		v4 = ItemConfig.match(value, "Redeemable"):asNullable()
	end

	if not v4 then
		local v5 = mapToLegacy[value]

		if v5 then
			local itemId = v5.ItemId

			if itemId then
				v4 = ItemConfig.match(itemId):asNullable()
			else
				v4 = nil
			end
		end
	end

	if not v4 then
		return Result.err((`no item id found for "{value}"`))
	end

	local v5 = v2[v4.Index.ItemId]

	if v5 then
		return Result.ok(v5)
	end

	return Result.err((`no economy item defined for "{v4.Index.DebugLabel}"`))
end, function(p)
	return (`{p}`)
end)

function Shop.match(p)
	return v3:call(p)
end

return Shop