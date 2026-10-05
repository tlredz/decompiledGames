local RunService = game:GetService("RunService")
local Result = require(game.ReplicatedStorage.Packages.Result)
local Option = require(game.ReplicatedStorage.Packages.Option)
require(game.ReplicatedStorage.Packages.Future)
require(game.ReplicatedStorage.Economy.EconomyItem.Product)
require(game.ReplicatedStorage.Economy.EconomyItem.LegacyInfo)
local RobuxItem = require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
require(game.ReplicatedStorage.Economy.EconomyItem.Qualification)
require(game.ReplicatedStorage.Economy.EconomyItem.Product.Settlement)
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
require(game.ReplicatedStorage.Economy.EconomyItem.Types)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local REVERSE_LOOK_UP_FIELD = RobuxItem.REVERSE_LOOK_UP_FIELD
return {
	REVERSE_LOOK_UP_FIELD = REVERSE_LOOK_UP_FIELD,
	toLegacy = function(instance)
		local legacyInfo = instance.LegacyInfo
		local unwrapped = ItemConfig.match(instance.ItemId):unwrap()
		local economy = unwrapped.Economy
		local v = not economy and 0 or economy.ProductId
		local name = unwrapped.Display.Name or unwrapped.Index.StorageKey
		local tradeReducer = economy and economy.TradeReducer
		local seaLevelGiftCheck = false
		local dressrosa = false

		for _, qualification in ipairs(instance.Qualifications) do
			if qualification.Config.Type ~= "SeaLevelLimit" then
				continue
			end

			if qualification.Config.Scope == "Purchaser" then
				dressrosa = true
			elseif qualification.Config.Scope == "Recipient" then
				seaLevelGiftCheck = true
			elseif qualification.Config.Scope == "Both" then
				seaLevelGiftCheck = true
				dressrosa = true
			end

			break
		end

		local hasTag = instance:HasTag("DoNotFeature")
		local hasTag2 = instance:HasTag("IsGiftable")
		local isForSale = not RunService:IsServer() and GlobalUtil.FFlags.IsUnitTest == false or nil
		local storageKey = ItemId.getDataFromId(instance.ItemId):unwrap().StorageKey
		local products = instance.Products
		local robuxItemType = legacyInfo.RobuxItemType

		if robuxItemType == "SkinBundle" then
			local v6 = {}
			local v7 = {}
			local storageKeys = {}

			if #products == 0 then
				return Result.err((`0 products found for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
			end

			for _, product in ipairs(products) do
				local clone = table.clone(product.Tiers)
				table.sort(clone, function(a, b)
					return a.Tier.Min:unwrapOr(0) > b.Tier.Min:unwrapOr(0)
				end)

				for _, v8 in ipairs(clone) do
					local settlement = v8.Settlement

					if settlement.Config.Type == "Currency" then
						table.insert(v6, settlement.Config.BeliAmount)
						table.insert(v7, settlement.Config.FragmentAmount)
					else
						if settlement.Config.Type ~= "Item" and settlement.Config.Type ~= "EconomyItem" then
							return Result.err((`unsupported settlement type: {settlement.Config.Type} for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
						end

						local dataFromId = ItemId.getDataFromId(settlement.Config.ItemId)

						if dataFromId:isErr() then
							return Result.err((tostring(dataFromId:unwrapErr())))
						else
							table.insert(storageKeys, dataFromId:unwrap().StorageKey)
						end
					end
				end
			end

			if not storageKey then
				return Result.err((`no storage name for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
			end

			local v8 = Option.try(function()
				for _, qualification in ipairs(instance.Qualifications) do
					if qualification.Config.Type == "RedeemLimit" then
						return Result.match(ItemId.getDataFromId(qualification.Config.ItemId), function(p)
							return p.StorageKey
						end, function()
							return nil
						end)
					end
				end

				return nil
			end)

			if v8:isNone() then
				return Result.err((`no item for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
			end

			local itemIdsByREVERSE_LOOK_UP_FIELD = {
				Name = name,
				productType = "Product",
				subitem = storageKey
			}

			if robuxItemType == "SkinBundle" then
				storageKey = legacyInfo.Key
			end

			itemIdsByREVERSE_LOOK_UP_FIELD.storageName = storageKey
			itemIdsByREVERSE_LOOK_UP_FIELD.item = v8:unwrap()
			itemIdsByREVERSE_LOOK_UP_FIELD.gift = hasTag2
			itemIdsByREVERSE_LOOK_UP_FIELD.reducer = tradeReducer
			itemIdsByREVERSE_LOOK_UP_FIELD.subtype = robuxItemType == "SkinBundle" and "Skin Bundle" or nil
			itemIdsByREVERSE_LOOK_UP_FIELD.assetId = v
			itemIdsByREVERSE_LOOK_UP_FIELD.doNotFeature = hasTag
			itemIdsByREVERSE_LOOK_UP_FIELD.bundleItems = storageKeys
			itemIdsByREVERSE_LOOK_UP_FIELD.bundletype = robuxItemType == "SkinBundle" and "FruitSkin" or nil
			itemIdsByREVERSE_LOOK_UP_FIELD[REVERSE_LOOK_UP_FIELD] = instance.ItemId
			table.freeze(itemIdsByREVERSE_LOOK_UP_FIELD)
			return Result.ok(itemIdsByREVERSE_LOOK_UP_FIELD)
		elseif robuxItemType == "Bundle" then
			if #instance.Products == 0 then
				return Result.err((`no products found for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
			end

			local beliAmounts = {}
			local fragmentAmounts = {}
			local storageKeys = {}

			if #products == 0 then
				return Result.err((`0 products found for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
			end

			for _, product in ipairs(products) do
				local clone = table.clone(product.Tiers)
				table.sort(clone, function(a, b)
					return a.Tier.Min:unwrapOr(0) > b.Tier.Min:unwrapOr(0)
				end)

				for i, _ in ipairs(clone) do
					local settlement = product.Tiers[i].Settlement

					if settlement.Config.Type == "Currency" then
						table.insert(beliAmounts, settlement.Config.BeliAmount)
						table.insert(fragmentAmounts, settlement.Config.FragmentAmount)
					else
						if settlement.Config.Type ~= "Item" and settlement.Config.Type ~= "EconomyItem" then
							return Result.err((`unsupported settlement type: {settlement.Config.Type} for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
						end

						local dataFromId = ItemId.getDataFromId(settlement.Config.ItemId)

						if dataFromId:isErr() then
							return Result.err((tostring(dataFromId:unwrapErr())))
						else
							table.insert(storageKeys, dataFromId:unwrap().StorageKey)
						end
					end
				end
			end

			local flag = true
			local maxGift

			for _, qualification in ipairs(instance.Qualifications) do
				if not (qualification.Config.Type == "GiftLimit" and qualification.Config.Maximum:isSome()) then
					continue
				end

				maxGift = qualification.Config.Maximum:unwrap()
				flag = false
				break
			end

			if flag then
				maxGift = nil
			end

			local flag2 = true
			local maxPurchase

			for _, qualification in ipairs(instance.Qualifications) do
				if not (qualification.Config.Type == "PurchaseLimit" and qualification.Config.Maximum:isSome()) then
					continue
				end

				maxPurchase = qualification.Config.Maximum:unwrap()
				flag2 = false
				break
			end

			if flag2 then
				maxPurchase = nil
			end

			local flag3 = true
			local minRobuxSpend

			for _, qualification in ipairs(instance.Qualifications) do
				if not (qualification.Config.Type == "RobuxSpentLimit" and qualification.Config.Minimum:isSome()) then
					continue
				end

				minRobuxSpend = qualification.Config.Minimum:unwrap()
				flag3 = false
				break
			end

			if flag3 then
				minRobuxSpend = nil
			end

			local productId

			if economy then
				productId = economy.ProductId
			end

			local v9 = {
				Cash = beliAmounts,
				Fragments = fragmentAmounts,
				Fruits = storageKeys,
				Gift = hasTag2,
				Name = storageKey,
				StorageName = legacyInfo.Key,
				gift = hasTag2,
				productType = "Product",
				storageName = legacyInfo.Key,
				subtype = "Bundle Product",
				seaLevelGiftCheck = seaLevelGiftCheck,
				onSale = nil,
				maxGift = maxGift,
				maxPurchase = maxPurchase,
				PurchaseLimits = maxPurchase and maxGift and {
					MaxGift = maxGift,
					MaxPurchase = maxPurchase
				} or nil,
				MinRobuxSpend = minRobuxSpend,
				AssetId = productId,
				assetId = productId,
				StoreAll = true,
				[REVERSE_LOOK_UP_FIELD] = instance.ItemId
			}
			table.freeze(v9)
			return Result.ok(v9)
		elseif robuxItemType == "FruitBox" then
			if #products == 0 then
				return Result.err((`0 products found for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
			end

			if #products > 1 then
				return Result.err((`too many products found for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
			end

			local product = products[1]
			local none = Option.none()

			for _, tier in pairs(product.Tiers) do
				if not none:isNone() then
					return Result.err((`multi-tier settlements for type {legacyInfo.RobuxItemType}/{legacyInfo.Key} not supported`))
				end

				none = Option.some(tier.Settlement)
			end

			if none:isNone() then
				return Result.err((`no settlement found for type {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
			end

			local unwrapped2 = none:unwrap()

			if unwrapped2.Config.Type ~= "Box" then
				return Result.err((`bad settlement type ({unwrapped2.Config.Type}) for item type {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
			end

			assert(unwrapped2.Config.Type == "Box", "bad settlement")
			local match = Option.match(Option.from(unwrapped.Quality.Rarity), function(p)
				return RarityUtil.tryGetRarity(p)
			end, function()
				return nil
			end)

			if not match then
				return Result.err((`no rarity found matching {unwrapped.Quality.Rarity} for item type {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
			end

			local v6 = {
				gift = hasTag2,
				Name = storageKey,
				redeemedFor = "Random",
				subtype = "Stored Product",
				storageName = legacyInfo.Key,
				productType = "Product",
				Rarity = match,
				IsForSale = isForSale,
				reducer = tradeReducer,
				[REVERSE_LOOK_UP_FIELD] = instance.ItemId
			}
			table.freeze(v6)
			return Result.ok(v6)
		elseif robuxItemType == "FruitMutation" then
			if not storageKey then
				return Result.err((`no storage name for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
			end

			if #products == 0 then
				return Result.err((`#products [{#products}]`))
			end

			local productId

			if economy then
				productId = economy.ProductId
			end

			if not productId then
				return Result.err((`no assetId for {storageKey}`))
			end

			local rarity = unwrapped.Quality.Rarity

			if not rarity then
				return Result.err((`no rarity for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
			end

			local unwrapped2 = RarityUtil.matchRarity(rarity):unwrap()
			local itemIdsByREVERSE_LOOK_UP_FIELD = {
				storageName = storageKey,
				reducer = tradeReducer,
				gift = hasTag2 ~= false and (tradeReducer ~= nil or nil),
				productType = "Product",
				subtype = "FruitMutation",
				assetId = productId,
				Name = storageKey,
				Rarity = unwrapped2.Value,
				[REVERSE_LOOK_UP_FIELD] = instance.ItemId
			}
			table.freeze(itemIdsByREVERSE_LOOK_UP_FIELD)
			return Result.ok(itemIdsByREVERSE_LOOK_UP_FIELD)
		else
			if #products == 0 then
				return Result.err((`0 products found for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
			end

			if #products > 1 then
				return Result.err((`too many products found for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
			end

			local product = products[1]
			local none = Option.none()

			for _, tier in pairs(product.Tiers) do
				if not none:isNone() then
					return Result.err((`multi-tier settlements for type {legacyInfo.RobuxItemType}/{legacyInfo.Key} not supported`))
				end

				none = Option.some(tier.Settlement)
			end

			if none:isNone() then
				return Result.err((`no settlement found for type {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
			end

			local unwrapped2 = none:unwrap()

			if robuxItemType == "NamedProduct" then
				if not storageKey then
					return Result.err((`no storage name for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				local v6 = {
					Name = storageKey,
					productType = "Product",
					assetId = v,
					IsForSale = isForSale,
					storageName = storageKey,
					gift = hasTag2,
					doNotFeature = instance:HasTag("DoNotFeature"),
					subtype = "Named Product",
					onSale = nil,
					reducer = tradeReducer,
					nostore = instance:HasTag("NoStore"),
					[REVERSE_LOOK_UP_FIELD] = instance.ItemId
				}
				table.freeze(v6)
				return Result.ok(v6)
			elseif robuxItemType == "Gamepass" then
				if unwrapped2.Config.Type ~= "SpecialProduct" then
					return Result.err((`bad settlement type "{unwrapped2.Config.Type}" for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				if not storageKey then
					return Result.err((`no storage name for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				local assetId = not economy and 0 or economy.GamepassId

				if not assetId then
					return Result.err((`no gamepassId for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				local v7 = {
					Name = storageKey,
					productType = "GamePass",
					gift = hasTag2,
					assetId = assetId,
					productId = v,
					IsForSale = isForSale,
					storageName = storageKey,
					onSale = nil,
					dressrosa = dressrosa,
					reducer = tradeReducer,
					[REVERSE_LOOK_UP_FIELD] = instance.ItemId
				}
				table.freeze(v7)
				return Result.ok(v7)
			elseif robuxItemType == "Fruit" then
				if unwrapped2.Config.Type == "Item" then
					if not storageKey then
						return Result.err((`no storage name for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
					end

					local v6 = {
						assetId = v,
						onSale = nil,
						doNotFeature = hasTag,
						Name = storageKey,
						IsForSale = isForSale,
						subtype = "Fruit",
						productType = "Product",
						storageName = storageKey,
						gift = hasTag2,
						reducer = tradeReducer,
						[REVERSE_LOOK_UP_FIELD] = instance.ItemId
					}
					table.freeze(v6)
					return Result.ok(v6)
				else
					if unwrapped2.Config.Type ~= "SpecialProduct" then
						return Result.err((`bad settlement type "{unwrapped2.Config.Type}" for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
					end

					local dataFromId = ItemId.getDataFromId(unwrapped2.Config.ItemId)

					if dataFromId:isErr() then
						return Result.err((tostring(dataFromId:unwrapErr())))
					end

					if not storageKey then
						return Result.err((`no storage name for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
					end

					local v6 = {
						assetId = v,
						onSale = nil,
						gift = false,
						doNotFeature = hasTag,
						Name = storageKey,
						IsForSale = isForSale,
						subtype = "Fruit",
						productType = "Product",
						storageName = storageKey,
						reducer = tradeReducer,
						[REVERSE_LOOK_UP_FIELD] = instance.ItemId
					}
					table.freeze(v6)
					return Result.ok(v6)
				end
			elseif robuxItemType == "FruitSkin" or robuxItemType == "AuraSkin" then
				if unwrapped2.Config.Type ~= "Item" then
					return Result.err((`bad settlement type "{unwrapped2.Config.Type}" for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				local dataFromId = ItemId.getDataFromId(unwrapped2.Config.ItemId)

				if dataFromId:isErr() then
					return Result.err((tostring(dataFromId:unwrapErr())))
				end

				local v6 = Option.try(function()
					for _, qualification in ipairs(instance.Qualifications) do
						if qualification.Config.Type == "RedeemLimit" then
							return Result.match(ItemId.getDataFromId(qualification.Config.ItemId), function(p)
								return p.StorageKey
							end, function()
								return nil
							end)
						end
					end

					return nil
				end)
				local v7 = {
					Name = name,
					storageName = storageKey,
					subitem = dataFromId:unwrap().StorageKey,
					subtype = robuxItemType,
					assetId = v,
					gift = hasTag2,
					doNotFeature = hasTag,
					item = v6:asNullable(),
					onSale = nil,
					reducer = tradeReducer,
					productType = "Product",
					[REVERSE_LOOK_UP_FIELD] = instance.ItemId
				}
				table.freeze(v7)
				return Result.ok(v7)
			elseif robuxItemType == "Currency" then
				if unwrapped2.Config.Type ~= "Currency" then
					return Result.err((`bad settlement type "{unwrapped2.Config.Type}" for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				if unwrapped2.Config.ItemId:isNone() then
					return Result.err((`no settlement item id found for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				local dataFromId = ItemId.getDataFromId(unwrapped2.Config.ItemId:unwrap())

				if dataFromId:isErr() then
					return Result.err((tostring(dataFromId:unwrapErr())))
				end

				if not storageKey then
					return Result.err((`no storage name for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				local itemIdsByREVERSE_LOOK_UP_FIELD = {
					Name = storageKey,
					productType = "Product",
					gift = hasTag2,
					assetId = v,
					doNotFeature = hasTag,
					dressrosa = dressrosa,
					seaLevelGiftCheck = seaLevelGiftCheck,
					IsForSale = isForSale,
					storageName = storageKey,
					subtype = unwrapped2.Config.FragmentAmount > 0 and "Fragment Product" or "Cash Product"
				}
				local fragments

				if unwrapped2.Config.FragmentAmount > 0 then
					fragments = unwrapped2.Config.FragmentAmount
				end

				local beli

				if unwrapped2.Config.BeliAmount > 0 then
					beli = unwrapped2.Config.BeliAmount
				end

				itemIdsByREVERSE_LOOK_UP_FIELD.modifiers = {
					Fragments = fragments,
					Beli = beli
				}
				itemIdsByREVERSE_LOOK_UP_FIELD.onSale = nil
				itemIdsByREVERSE_LOOK_UP_FIELD.reducer = tradeReducer
				itemIdsByREVERSE_LOOK_UP_FIELD[REVERSE_LOOK_UP_FIELD] = instance.ItemId
				table.freeze(itemIdsByREVERSE_LOOK_UP_FIELD)
				return Result.ok(itemIdsByREVERSE_LOOK_UP_FIELD)
			elseif robuxItemType == "StoredProduct" then
				if unwrapped2.Config.Type ~= "Item" then
					return Result.err((`bad settlement type "{unwrapped2.Config.Type}" for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				if not storageKey then
					return Result.err((`no storage name for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				local v6 = {
					Name = storageKey,
					productType = "Product",
					gift = hasTag2,
					assetId = v,
					IsForSale = isForSale,
					storageName = storageKey,
					subtype = "Stored Product",
					onSale = nil,
					dressrosa = dressrosa,
					seaLevelGiftCheck = seaLevelGiftCheck,
					reducer = tradeReducer,
					[REVERSE_LOOK_UP_FIELD] = instance.ItemId
				}
				table.freeze(v6)
				return Result.ok(v6)
			elseif robuxItemType == "ExpProduct" then
				if unwrapped2.Config.Type ~= "ExpBoost" then
					return Result.err((`bad settlement type "{unwrapped2.Config.Type}" for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				if not storageKey then
					return Result.err((`no storage name for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				local v6 = {
					Name = storageKey,
					productType = "Product",
					gift = hasTag2,
					assetId = v,
					IsForSale = isForSale,
					storageName = storageKey,
					subtype = "Exp Product",
					onSale = nil,
					reducer = tradeReducer,
					[REVERSE_LOOK_UP_FIELD] = instance.ItemId
				}
				table.freeze(v6)
				return Result.ok(v6)
			elseif robuxItemType == "MasteryProduct" then
				if unwrapped2.Config.Type ~= "MasteryBoost" then
					return Result.err((`bad settlement type "{unwrapped2.Config.Type}" for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				if not storageKey then
					return Result.err((`no storage name for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				local v6 = {
					Name = storageKey,
					productType = "Product",
					gift = hasTag2,
					assetId = v,
					IsForSale = isForSale,
					storageName = storageKey,
					subtype = "Mastery Product",
					onSale = nil,
					reducer = tradeReducer,
					[REVERSE_LOOK_UP_FIELD] = instance.ItemId
				}
				table.freeze(v6)
				return Result.ok(v6)
			elseif robuxItemType == "PhysicalRocketFruit" then
				if not storageKey then
					return Result.err((`no storage name for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				local v6 = {
					assetId = v,
					storageName = storageKey,
					onSale = nil,
					productType = "Product",
					Name = storageKey,
					IsForSale = isForSale,
					[REVERSE_LOOK_UP_FIELD] = instance.ItemId
				}
				table.freeze(v6)
				return Result.ok(v6)
			elseif robuxItemType == "DungeonProduct" then
				if not storageKey then
					return Result.err((`no storage name for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				local match = Result.match(ItemId.getId(storageKey, "Redeemable"), function(p)
					return p
				end, function()
					return nil
				end)

				if unwrapped2.Config.Type ~= "Item" then
					return Result.err((`bad settlement type "{unwrapped2.Config.Type}" for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				assert(unwrapped2.Config.Type == "Item", "bad settlement")
				local v6 = {
					Name = storageKey,
					productType = "Product",
					gift = hasTag2,
					assetId = v,
					IsForSale = isForSale,
					storageName = storageKey,
					subtype = "Dungeon Product",
					onSale = nil,
					reducer = tradeReducer,
					Amount = unwrapped2.Config.Amount:unwrapOr(1),
					[REVERSE_LOOK_UP_FIELD] = match,
					isDungeonProduct = true
				}
				table.freeze(v6)
				return Result.ok(v6)
			else
				if robuxItemType ~= "SwordSkin" and robuxItemType ~= "ProfileItem" and robuxItemType ~= "Sword" then
					return Result.err((`to-legacy doesn't support RobuxItemType {robuxItemType}`))
				end

				if not storageKey then
					return Result.err((`no storage name for {legacyInfo.RobuxItemType}/{legacyInfo.Key}`))
				end

				local v6 = {
					assetId = v,
					storageName = storageKey,
					productType = "Product",
					Name = storageKey,
					[REVERSE_LOOK_UP_FIELD] = instance.ItemId
				}
				table.freeze(v6)
				return Result.ok(v6)
			end
		end
	end
}