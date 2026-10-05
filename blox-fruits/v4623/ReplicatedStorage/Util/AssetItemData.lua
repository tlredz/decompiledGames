local Result = require(game.ReplicatedStorage.Packages.Result)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Type = require(game.ReplicatedStorage.Packages.Type)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemData = require(game.ReplicatedStorage.Modules.Asset.ItemData)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local StatDefinition = require(game.ReplicatedStorage.Util.StatDefinition)
local StatTypes = require(game.ReplicatedStorage.Types.StatTypes)
local strictInterface = Type.strictInterface({
	ItemId = Type.integer,
	Quantity = Type.number
})
local strictInterface2 = Type.strictInterface({
	ItemId = Type.integer,
	AccessoryName = Type.optional(Type.string),
	Recipe = Type.optional(Type.array(strictInterface)),
	Stats = Type.optional(Type.array(StatTypes.StatValue))
})
local AssetItemData = {
	solve = StatDefinition.solve
}

function AssetItemData._convertItem(itemId: number, p2)
	if typeof(p2) ~= "table" then
		return Result.err("No data for itemId " .. tostring(itemId))
	end

	local v2 = p2[0] or p2[1]
	local v = {
		ItemId = itemId,
		AccessoryName = p2.Accessory
	}

	if v2 then
		if typeof(v2) ~= "table" then
			return Result.err((`bad legacyValueArray: {typeof(v2)}`))
		end

		assert(typeof(v2) == "table", (`bad legacyValueArray: {typeof(v2)}`))
		local v3 = v2[2]

		if v3 then
			if typeof(v3) ~= "table" then
				return Result.err((`bad legacyStatMap: {typeof(v3)}`))
			end

			assert(typeof(v3) == "table", (`bad legacyStatList: {typeof(v3)}`))
			local copy = TableUtil.deepCopy(v3)
			local stats = {}
			local allCooldown = copy.AllCooldown
			local gunCooldown = copy.GunCooldown
			local swordCooldown = copy.SwordCooldown
			local meleeCooldown = copy.MeleeCooldown
			local fruitCooldown = copy.FruitCooldown
			local flashstepCooldown = copy.FlashstepCooldown

			if flashstepCooldown or allCooldown or gunCooldown or swordCooldown or meleeCooldown or fruitCooldown then
				copy.Cooldown = {
					All = allCooldown,
					Gun = gunCooldown,
					Sword = swordCooldown,
					Melee = meleeCooldown,
					Fruit = fruitCooldown,
					FlashStep = flashstepCooldown
				}
				copy.AllCooldown = nil
				copy.GunCooldown = nil
				copy.SwordCooldown = nil
				copy.MeleeCooldown = nil
				copy.FruitCooldown = nil
				copy.FlashstepCooldown = nil
			end

			local dashLength = copy.DashLength
			local dashLengthGround = copy.DashLengthGround
			local dashLengthAir = copy.DashLengthAir

			if dashLength or dashLengthGround or dashLengthAir then
				copy.DashLength = {
					All = dashLength,
					Ground = dashLengthGround,
					Air = dashLengthAir
				}
				copy.DashLength = nil
				copy.DashLengthGround = nil
				copy.DashLengthAir = nil
			end

			for k, v5 in copy do
				if typeof(v5) == "table" then
					for k2, v6 in v5 do
						local v7 = {
							StatType = "Complex",
							Type = k,
							Variant = k2
						}
						local statIndex, v8 = StatTypes.StatIndex(v7)

						if not statIndex then
							return Result.err((`invalid StatTypes.StatIndex for stat {k} variant {k2}: {v8}`))
						end

						local solve = AssetItemData.solve(v7, v6)

						if not solve:isOk() then
							return Result.err((`failed to convert stat {k} variant {k2}: {solve:unwrapErr()}`))
						end

						table.insert(stats, solve:unwrap())
					end
				else
					local v6 = {
						StatType = "Simple",
						Type = k
					}
					local statIndex, v7 = StatTypes.StatIndex(v6)

					if not statIndex then
						return Result.err((`invalid StatTypes.StatIndex for stat {k}: {v7}`))
					end

					local solve = AssetItemData.solve(v6, v5)

					if not solve:isOk() then
						return Result.err((`failed to convert stat {k}: {solve:unwrapErr()}`))
					end

					table.insert(stats, solve:unwrap())
				end
			end

			if #stats > 0 then
				v.Stats = stats
			end
		end

		local v4 = v2[1]

		if v4 then
			if typeof(v4) ~= "table" then
				return Result.err((`bad legacyIngredientMap: {typeof(v4)}`))
			end

			assert(typeof(v4) == "table", (`bad legacyIngredientMap: {typeof(v4)}`))
			local recipe = {}

			for k, quantity in v4 do
				local id = ItemId.getId(k, "Material")

				if id:isErr() then
					return Result.err((`failed to get itemId for ingredient storageKey {k}: {id:unwrapErr().Type}`))
				else
					table.insert(recipe, {
						ItemId = id:unwrap(),
						Quantity = quantity
					})
				end
			end

			if #recipe > 0 then
				v.Recipe = recipe
			end
		end
	end

	TableUtil.deepFreeze(v)
	local v3, v4 = strictInterface2(v)

	if v3 then
		return Result.ok(v)
	end

	return Result.err((`invalid AssetItemData for itemId {itemId}: {v4}`))
end

AssetItemData.fromLegacyName = StatDefinition.fromLegacyName
AssetItemData.toLegacyName = StatDefinition.toLegacyName
local ALL = {}

for k, itemStat in pairs(ItemData.ItemStats) do
	local first = ItemConfig.Query.selectFirst({
		Index = {
			StorageKey = k,
			IdType = {
				Operation = "OR",
				Values = {
					"PhysicalMoveset",
					"Accessory",
					"Rod",
					"Moveset",
					"Potion",
					"Tool",
					"Accessory",
					"Ability",
					"Consumable",
					"Scroll"
				}
			}
		}
	})

	if first:isErr() then
		warn((`Util.AssetItemData: failed to get itemId for storageKey {k}: {first:unwrapErr()}`))
	else
		ALL[first:unwrap().Index.ItemId] = AssetItemData._convertItem(first:unwrap().Index.ItemId, itemStat)
	end
end

table.freeze(ALL)
AssetItemData.ALL = ALL

function AssetItemData.matchItem(p: number)
	local dataFromId = ItemId.getDataFromId(p)

	if dataFromId:isErr() then
		return Result.err((`bad itemId ({p}): {dataFromId:unwrapErr().Type}`))
	end

	local v2 = AssetItemData.ALL[p]

	if v2 then
		return v2
	end

	return Result.err((`no valid data for itemId: {p}`))
end

return AssetItemData