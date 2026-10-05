local SimpleTest = require(game.ReplicatedStorage.Packages.SimpleTest)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Legacy = require(script.Parent.Legacy)
local query = ItemConfig.Query
local v = ItemConfig.dumpItems()

local function idsOf(items)
	local itemIds = {}

	for k, item in items do
		itemIds[k] = item.Index.ItemId
	end

	return itemIds
end

-- equivalent calls inferred from this helper; original call sites unknown
local function describeIds(list)
	if #list > 12 then
		return (`[{table.concat(list, ",", 1, 12)}, ... {#list} total]`)
	end

	return (`[{table.concat(list, ",")}]`)
end

local function assertSameIds(p: string, list, list2)
	local v2 = #list == #list2
	local v4 = #list
	local v5 = #list2
	local v6 = describeIds(list) -- equivalent call inferred; original call site unknown
	local v7 = describeIds(list2) -- equivalent call inferred; original call site unknown
	assert(v2, (`{p}: expected {v4} items, got {v5}\n expected {v6}\n actual   {v7}`))

	for k, v8 in list do
		assert(list2[k] == v8, (`{p}: item #{k} expected {v8}, got {list2[k]}`))
	end
end

local function legacyUnion(queries)
	local v2 = {}

	for _, item in queries do
		for _, v3 in Legacy.select(v, item) do
			v2[v3.Index.ItemId] = true
		end
	end

	local itemIds = {}

	for _, v3 in v do
		if v2[v3.Index.ItemId] then
			table.insert(itemIds, v3.Index.ItemId)
		end
	end

	return itemIds
end

local function legacyIntersection(queries)
	local itemIds = {}

	for _, v2 in v do
		local flag = true

		for _, item in queries do
			if Legacy.checkQuery(v2, item) then
				continue
			end

			flag = false
			break
		end

		if flag then
			table.insert(itemIds, v2.Index.ItemId)
		end
	end

	return itemIds
end

local function firstItem(callback)
	for _, v2 in v do
		if callback(v2) then
			return v2
		end
	end

	return nil
end

local function buildCases()
	local v2 = {}

	local function add(label: string, ...)
		table.insert(v2, {
			Label = label,
			Queries = { ... }
		})
	end

	add("empty query", {})
	local v3 = {}

	for _, v4 in v do
		v3[v4.Index.IdType] = true
	end

	local v4 = {}

	for k in v3 do
		table.insert(v4, k)
	end

	table.sort(v4)

	for _, idType in v4 do
		add(`IdType {idType}`, {
			Index = {
				IdType = idType
			}
		})
	end

	add("IdType OR", {
		Index = {
			IdType = {
				Operation = "OR",
				Values = { "Rod", "Tool" }
			}
		}
	})
	add("IdType OR duplicates", {
		Index = {
			IdType = {
				Operation = "OR",
				Values = { "Skin", "Skin", "Mutation" }
			}
		}
	})
	add("IdType NOR", {
		Index = {
			IdType = {
				Operation = "NOR",
				Values = { "Skin", "Mutation" }
			}
		}
	})
	add("IdType NEQ", {
		Index = {
			IdType = {
				Operation = "NEQ",
				Value = "Moveset"
			}
		}
	})
	add("IdType unknown", {
		Index = {
			IdType = "NotAnIdType"
		}
	})
	add("Skin Aura", {
		Skin = {
			Type = "Aura"
		}
	})
	add("Skin Fruit", {
		Skin = {
			Type = "Fruit"
		}
	})
	add("Skin Type NEQ nil", {
		Skin = {
			Type = {
				Operation = "NEQ",
				Value = nil
			}
		}
	})
	add("Skin section EQ nil", {
		Skin = {
			Operation = "EQ",
			Value = nil
		}
	})
	add("Skin section NEQ nil", {
		Skin = {
			Operation = "NEQ",
			Value = nil
		}
	})
	add("Skin IsDefault false", {
		Skin = {
			IsDefault = false
		}
	})
	add("Skin IsDefault NEQ true", {
		Skin = {
			IsDefault = {
				Operation = "NEQ",
				Value = true
			}
		}
	})
	add("Skin Physical NEQ nil", {
		Skin = {
			Physical = {
				Operation = "NEQ",
				Value = nil
			}
		}
	})
	add("Skin Fruit no physical", {
		Index = {
			IdType = "Skin"
		},
		Skin = {
			Type = "Fruit",
			Physical = {
				Operation = "EQ",
				Value = nil
			}
		}
	})
	add("State StorageMethod NEQ nil", {
		State = {
			StorageMethod = {
				Operation = "NEQ",
				Value = nil
			}
		}
	})
	add("State EquipMethod EQ nil", {
		State = {
			EquipMethod = {
				Operation = "EQ",
				Value = nil
			}
		}
	})
	add("foundation fruits", {
		Index = {
			IdType = "Moveset"
		},
		Moveset = {
			Type = "Fruit"
		},
		Variant = {
			IsFoundation = true
		}
	})
	add("fruit movesets", {
		Index = {
			IdType = "Moveset"
		},
		Moveset = {
			Type = "Fruit"
		}
	})
	add("Inventory Groups Backpack", {
		Inventory = {
			Groups = "Backpack"
		}
	})
	add("Inventory Groups NEQ Backpack", {
		Inventory = {
			Groups = {
				Operation = "NEQ",
				Value = "Backpack"
			}
		}
	})
	add("Inventory Groups OR", {
		Inventory = {
			Groups = {
				Operation = "OR",
				Values = { "Backpack", "Stash" }
			}
		}
	})
	add("Inventory Groups NOR", {
		Inventory = {
			Groups = {
				Operation = "NOR",
				Values = { "Backpack", "Stash" }
			}
		}
	})
	add("Inventory Groups EQ nil", {
		Inventory = {
			Groups = {
				Operation = "EQ",
				Value = nil
			}
		}
	})
	add("Inventory Groups NEQ nil", {
		Inventory = {
			Groups = {
				Operation = "NEQ",
				Value = nil
			}
		}
	})
	add("Inventory Tags", {
		Inventory = {
			Tags = "DynamicDescription"
		}
	})
	add("Inventory MaxStack NEQ nil", {
		Inventory = {
			MaxStack = {
				Operation = "NEQ",
				Value = nil
			}
		}
	})
	add("Inventory TileAppearance", {
		Inventory = {
			TileAppearance = v[1].Inventory.TileAppearance
		}
	})
	add("Quality RarityValue 5", {
		Quality = {
			RarityValue = 5
		}
	})
	add("Quality Rarity Legendary", {
		Quality = {
			Rarity = "Legendary"
		}
	})
	add("Quality Rarity OR", {
		Quality = {
			Rarity = {
				Operation = "OR",
				Values = { "Common", "Uncommon" }
			}
		}
	})
	add("Economy premium random", {
		Economy = {
			IsPremiumRandomItem = true
		}
	})
	add("Economy PurchaseWith NEQ nil", {
		Economy = {
			PurchaseWith = {
				Operation = "NEQ",
				Value = nil
			}
		}
	})
	add("Economy section EQ nil", {
		Economy = {
			Operation = "EQ",
			Value = nil
		}
	})
	add("Gacha BaseWeight NEQ nil", {
		Gacha = {
			BaseWeight = {
				Operation = "NEQ",
				Value = nil
			}
		}
	})
	add("Equipment IsAuraBound", {
		Equipment = {
			IsAuraBound = true
		}
	})
	add("Display Name EQ nil", {
		Display = {
			Name = {
				Operation = "EQ",
				Value = nil
			}
		}
	})
	add("Display unknown key EQ nil", {
		Display = {
			NotARealField = {
				Operation = "EQ",
				Value = nil
			}
		}
	})
	add("Display unknown key EQ value", {
		Display = {
			NotARealField = "x"
		}
	})
	add("Display unknown key NEQ value", {
		Display = {
			NotARealField = {
				Operation = "NEQ",
				Value = "x"
			}
		}
	})
	add("unknown section nested", {
		NotASection = {
			Foo = 1
		}
	})
	add("unknown section EQ nil", {
		NotASection = {
			Operation = "EQ",
			Value = nil
		}
	})
	add("unknown section NEQ nil", {
		NotASection = {
			Operation = "NEQ",
			Value = nil
		}
	})
	add("unknown section nested NEQ", {
		NotASection = {
			Foo = {
				Operation = "NEQ",
				Value = 1
			}
		}
	})
	add("unknown section nested EQ nil", {
		NotASection = {
			Foo = {
				Operation = "EQ",
				Value = nil
			}
		}
	})
	add("DebugLabel miss", {
		Index = {
			DebugLabel = "definitely not a label"
		}
	})
	add("Skin empty filter", {
		Skin = {}
	})
	add("Mutation empty filter", {
		Mutation = {}
	})
	add("unknown section empty filter", {
		NotASection = {}
	})
	add("empty filters combined", {
		Skin = {},
		Moveset = {}
	})
	add("Mutation Physical NEQ nil", {
		Mutation = {
			Physical = {
				Operation = "NEQ",
				Value = nil
			}
		}
	})
	add("Mutation Physical EQ nil", {
		Mutation = {
			Physical = {
				Operation = "EQ",
				Value = nil
			}
		}
	})
	add("Mutation Adornee NEQ nil", {
		Mutation = {
			Adornee = {
				Operation = "NEQ",
				Value = nil
			}
		}
	})
	add("Variant VariantOf EQ nil", {
		Variant = {
			VariantOf = {
				Operation = "EQ",
				Value = nil
			}
		}
	})
	add("Variant Mutation NEQ nil", {
		Variant = {
			Mutation = {
				Operation = "NEQ",
				Value = nil
			}
		}
	})
	add("Variant IsFoundation NEQ true", {
		Variant = {
			IsFoundation = {
				Operation = "NEQ",
				Value = true
			}
		}
	})
	add("Quality RarityValue EQ nil", {
		Quality = {
			RarityValue = {
				Operation = "EQ",
				Value = nil
			}
		}
	})
	add("Quality Rarity NOR", {
		Quality = {
			Rarity = {
				Operation = "NOR",
				Values = { "Common", "Legendary" }
			}
		}
	})
	local v5 = math.max(1, (math.floor(#v / 12)))

	for i = 1, #v, v5 do
		local index = v[i].Index
		add(`StorageKey {index.DebugLabel}`, {
			Index = {
				StorageKey = index.StorageKey
			}
		})
		add(`exact {index.DebugLabel}`, {
			Index = {
				StorageKey = index.StorageKey,
				IdType = index.IdType
			}
		})
		add(`ItemId {index.ItemId}`, {
			Index = {
				ItemId = index.ItemId
			}
		})
	end

	local v6 = nil

	for _, v8 in v do
		if v8.Variant.VariantOf == nil then
			continue
		end

		v6 = v8
		break
	end

	if v6 then
		local variantOf = v6.Variant.VariantOf
		add("Variant VariantOf", {
			Variant = {
				VariantOf = variantOf
			}
		})
		add("Variant VariantOf no mutation", {
			Variant = {
				VariantOf = variantOf,
				Mutation = {
					Operation = "EQ",
					Value = nil
				}
			}
		})
		add("Variant VariantOf with mutation", {
			Variant = {
				VariantOf = variantOf,
				Mutation = {
					Operation = "NEQ",
					Value = nil
				}
			}
		})
	end

	local v8 = nil

	for _, v10 in v do
		if v10.Variant.Mutation == nil then
			continue
		end

		v8 = v10
		break
	end

	if v8 then
		add("moveset by mutation", {
			Index = {
				IdType = "Moveset"
			},
			Variant = {
				Mutation = v8.Variant.Mutation
			}
		})
	end

	local v10 = nil

	for _, v12 in v do
		local v13

		if v12.Moveset == nil then
			v13 = false
		else
			v13 = v12.Moveset.SkillRedirect ~= nil
		end

		if not v13 then
			continue
		end

		v10 = v12
		break
	end

	if v10 and v10.Moveset then
		add("Moveset SkillRedirect", {
			Moveset = {
				SkillRedirect = v10.Moveset.SkillRedirect
			}
		})
	end

	local v12 = nil

	for _, v14 in v do
		local v15

		if v14.Moveset == nil then
			v15 = false
		else
			v15 = v14.Moveset.Physical ~= nil
		end

		if not v15 then
			continue
		end

		v12 = v14
		break
	end

	if v12 and v12.Moveset then
		add("Moveset Physical", {
			Index = {
				IdType = "Moveset"
			},
			Moveset = {
				Physical = v12.Moveset.Physical
			}
		})
	end

	local v14 = nil

	for _, v16 in v do
		local v17

		if v16.Skin == nil then
			v17 = false
		else
			v17 = v16.Skin.Physical ~= nil
		end

		if not v17 then
			continue
		end

		v14 = v16
		break
	end

	if v14 and v14.Skin then
		add("Skin Adornee with physical", {
			Skin = {
				Adornee = v14.Skin.Adornee,
				Physical = {
					Operation = "NEQ",
					Value = nil
				}
			}
		})
		add("Skin Physical", {
			Skin = {
				Physical = v14.Skin.Physical
			}
		})
		add("Skin by adornee", {
			Index = {
				IdType = "Skin"
			},
			Skin = {
				Type = v14.Skin.Type,
				Adornee = v14.Skin.Adornee
			}
		})
	end

	local v16 = nil

	for _, v18 in v do
		local v19

		if v18.Economy == nil then
			v19 = false
		else
			v19 = v18.Economy.PurchaseWith ~= nil
		end

		if not v19 then
			continue
		end

		v16 = v18
		break
	end

	if v16 and v16.Economy then
		add("Economy PurchaseWith", {
			Economy = {
				PurchaseWith = v16.Economy.PurchaseWith
			}
		})
		add("Skin PurchaseWith", {
			Index = {
				IdType = "Skin"
			},
			Skin = {
				Type = "Fruit"
			},
			Economy = {
				PurchaseWith = v16.Economy.PurchaseWith
			}
		})
	end

	local v18 = nil

	for _, v20 in v do
		local v21

		if v20.Equipment == nil then
			v21 = false
		else
			v21 = #v20.Equipment.Slots > 0
		end

		if not v21 then
			continue
		end

		v18 = v20
		break
	end

	if v18 and v18.Equipment then
		add("Equipment Slots", {
			Equipment = {
				Slots = v18.Equipment.Slots[1]
			}
		})
	end

	local v20 = nil

	for _, v22 in v do
		if v22.Display.OutlineColor == nil then
			continue
		end

		v20 = v22
		break
	end

	if v20 then
		add("Display OutlineColor", {
			Display = {
				OutlineColor = v20.Display.OutlineColor
			}
		})
		add("Display OutlineColor NEQ", {
			Display = {
				OutlineColor = {
					Operation = "NEQ",
					Value = v20.Display.OutlineColor
				}
			}
		})
	end

	local v22 = nil

	for _, v24 in v do
		if v24.Display.Sprite == nil then
			continue
		end

		v22 = v24
		break
	end

	if v22 and v22.Display.Sprite then
		local sprite = v22.Display.Sprite
		add("Display Sprite Image", {
			Display = {
				Sprite = {
					Image = sprite.Image
				}
			}
		})
		add("Display Sprite offset", {
			Display = {
				Sprite = {
					ImageRectOffset = sprite.ImageRectOffset
				}
			}
		})
		add("Display Sprite table", {
			Display = {
				Sprite = {
					Image = sprite.Image,
					ImageRectOffset = sprite.ImageRectOffset,
					ImageRectSize = sprite.ImageRectSize
				}
			}
		})
		add("Display Sprite EQ nil", {
			Display = {
				Sprite = {
					Operation = "EQ",
					Value = nil
				}
			}
		})
	end

	add("join skins and mutations", {
		Index = {
			IdType = "Skin"
		}
	}, {
		Index = {
			IdType = "Mutation"
		}
	})
	add("join duplicate", {
		Skin = {
			Type = "Aura"
		}
	}, {
		Skin = {
			Type = "Aura"
		}
	})
	add("join physical skins and mutations", {
		Skin = {
			Physical = {
				Operation = "NEQ",
				Value = nil
			}
		}
	}, {
		Mutation = {
			Physical = {
				Operation = "NEQ",
				Value = nil
			}
		}
	})
	add("join three", {
		Index = {
			IdType = "Rod"
		}
	}, {
		Index = {
			IdType = "Tool"
		}
	}, {
		Skin = {
			Type = "Aura"
		}
	})
	add("join with empty", {
		Index = {
			IdType = "Race"
		}
	}, {
		Index = {
			IdType = "NotAnIdType"
		}
	})
	add("overlap fruit movesets", {
		Index = {
			IdType = "Moveset"
		}
	}, {
		Moveset = {
			Type = "Fruit"
		}
	})
	add("overlap contradiction", {
		Index = {
			IdType = "Skin"
		}
	}, {
		Index = {
			IdType = "Mutation"
		}
	})
	add("overlap with all", {}, {
		Skin = {
			Type = "Aura"
		}
	})
	return v2
end

local function checkSingle(p)
	local query2 = p.Queries[1]
	local v2 = Legacy.select(v, query2)
	local itemIds = {}

	for k, v3 in v2 do
		itemIds[k] = v3.Index.ItemId
	end

	local v3 = query.select(query2)
	local formatted = `{p.Label} select`
	local itemIds2 = {}

	for k, v6 in v3 do
		itemIds2[k] = v6.Index.ItemId
	end

	assertSameIds(formatted, itemIds, itemIds2)
	table.insert(v3, v[1])
	local v6 = query.select(query2)
	local formatted2 = `{p.Label} cached select`
	local itemIds3 = {}

	for k, v9 in v6 do
		itemIds3[k] = v9.Index.ItemId
	end

	assertSameIds(formatted2, itemIds, itemIds3)
	local one = query.selectOne(query2)
	assert(one:isOk() == (#itemIds == 1), (`{p.Label} selectOne ok mismatch for {#itemIds} matches`))

	if one:isOk() then
		assert(one:unwrap().Index.ItemId == itemIds[1], (`{p.Label} selectOne returned the wrong item`))
	end

	local first = query.selectFirst(query2)
	assert(first:isOk() == (#itemIds > 0), (`{p.Label} selectFirst ok mismatch for {#itemIds} matches`))

	if first:isOk() then
		assert(first:unwrap().Index.ItemId == itemIds[1], (`{p.Label} selectFirst returned the wrong item`))
	end

	local v9 = {}

	for _, v10 in itemIds do
		v9[v10] = true
	end

	for k, v10 in v do
		if not (k % 7 == 1 or v9[v10.Index.ItemId]) then
			continue
		end

		local itemId = v10.Index.ItemId
		local v11 = Legacy.checkQuery(v10, query2)
		assert(
			query.check(itemId, query2) == v11,
			(`{p.Label} check({itemId}) expected {v11} for {v10.Index.DebugLabel}`)
		)
		local unwrapped = ItemConfig.match(v10.Index.StorageKey, v10.Index.IdType):unwrap()
		assert(
			query.check(v10.Index.StorageKey, v10.Index.IdType, query2) == Legacy.checkQuery(unwrapped, query2),
			(`{p.Label} check(storageKey) mismatch for {v10.Index.DebugLabel}`)
		)
	end

	assert(query.check(#v + 100000, query2) == false, (`{p.Label} check on an unknown id should be false`))
end

local function checkMulti(p)
	local queries = p.Queries
	local v2 = legacyUnion(queries)
	local v3 = legacyIntersection(queries)
	local formatted = `{p.Label} join`
	local joined = query.join(table.unpack(queries))
	local itemIds = {}

	for k, v6 in joined do
		itemIds[k] = v6.Index.ItemId
	end

	assertSameIds(formatted, v2, itemIds)
	local formatted2 = `{p.Label} cached join`
	local joined2 = query.join(table.unpack(queries))
	local itemIds2 = {}

	for k, v8 in joined2 do
		itemIds2[k] = v8.Index.ItemId
	end

	assertSameIds(formatted2, v2, itemIds2)
	local formatted3 = `{p.Label} overlap`
	local overlap = query.overlap(table.unpack(queries))
	local itemIds3 = {}

	for k, v10 in overlap do
		itemIds3[k] = v10.Index.ItemId
	end

	assertSameIds(formatted3, v3, itemIds3)
	local formatted4 = `{p.Label} cached overlap`
	local overlap2 = query.overlap(table.unpack(queries))
	local itemIds4 = {}

	for k, v12 in overlap2 do
		itemIds4[k] = v12.Index.ItemId
	end

	assertSameIds(formatted4, v3, itemIds4)
	assert(
		query.joinOne(table.unpack(queries)):isOk() == (#v2 == 1),
		(`{p.Label} joinOne ok mismatch for {#v2} matches`)
	)
	local joinFirst = query.joinFirst(table.unpack(queries))
	assert(joinFirst:isOk() == (#v2 > 0), (`{p.Label} joinFirst ok mismatch for {#v2} matches`))

	if joinFirst:isOk() then
		assert(joinFirst:unwrap().Index.ItemId == v2[1], (`{p.Label} joinFirst returned the wrong item`))
	end

	local overlapOne = query.overlapOne(table.unpack(queries))
	assert(overlapOne:isOk() == (#v3 == 1), (`{p.Label} overlapOne ok mismatch for {#v3} matches`))

	if overlapOne:isOk() then
		assert(overlapOne:unwrap().Index.ItemId == v3[1], (`{p.Label} overlapOne returned the wrong item`))
	end
end

local cases = buildCases()
return SimpleTest.Test.new({ SimpleTest.Parameter.Choose.new("Case", cases, function(p)
		return p.Label
	end) }, function(p)
	assert(#v > 0, "no item configs were loaded")

	if #p.Queries == 1 then
		checkSingle(p)
	else
		checkMulti(p)
	end

	return true
end, #cases + 1)