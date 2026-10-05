local SimpleTest = require(game.ReplicatedStorage.Packages.SimpleTest)
local Result = require(game.ReplicatedStorage.Packages.Result)
local Bake = require(script.Parent.Bake)
local Index = require(script.Parent.Data.Index)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local v = {
	{ "Display", "Sprite" },
	{ "Display", "OutlineSprite" },
	{ "Display", "CornerIcon" },
	{ "Display", "CategoryIcon" },
	{ "Inventory", "StackCategoryIcon" },
	{ "Skin", "EquippedAdorneeSprite" }
}
local v2 = {
	{
		Method = "parseCollectsPositionalItems"
	},
	{
		Method = "roundTripMatchesParse"
	},
	{
		Method = "serializeDeterministic"
	},
	{
		Method = "serializeIdempotent"
	},
	{
		Method = "bakedHeaderAndCounts"
	},
	{
		Method = "isFreshAcceptsCurrentData"
	},
	{
		Method = "isFreshRejectsIndexCount"
	},
	{
		Method = "isFreshRejectsStorageKey"
	},
	{
		Method = "isFreshRejectsIdType"
	},
	{
		Method = "isFreshRejectsRetiredOrUnknownItem"
	},
	{
		Method = "loadFillsMissingResults"
	},
	{
		Method = "swapSpritesResolvesEveryField"
	},
	{
		Method = "swapSpritesRejectsBadKeys"
	},
	{
		Method = "scalarFormattingRoundTrip"
	},
	{
		Method = "keyOrderIsCanonical"
	},
	{
		Method = "spriteIdentitySurvivesRoundTrip"
	},
	{
		Method = "errorsSurviveRoundTrip"
	},
	{
		Method = "serializeRejectsUnsupportedValues"
	}
}
local count = 0
local parsed = nil
local serialized = nil

local function compile(source: string)
	count += 1
	local moduleScript = Instance.new("ModuleScript")
	moduleScript.Name = `BakeSpecBaked{count}`
	moduleScript.Source = source
	moduleScript.Parent = script
	local module = require(moduleScript)
	moduleScript:Destroy()
	return module
end

local function parsed2()
	if not parsed then
		parsed = Bake.parse()
	end

	return parsed
end

local function bakedSource()
	if serialized then
		return serialized
	end

	local serialize = Bake.serialize

	if not parsed then
		parsed = Bake.parse()
	end

	serialized = serialize(parsed)
	return serialized
end

local function isSpritePath(list)
	for _, v3 in v do
		if #list == 2 and list[1] == v3[1] and list[2] == v3[2] then
			return true
		end
	end

	return false
end

local deepCompare

deepCompare = function(list, list2, list3, flag: boolean)
	if isSpritePath(list3) then
		if rawequal(list, list2) then
			return nil
		end

		return (`sprite at {table.concat(list3, ".")} is not the same reference`)
	else
		if typeof(list) ~= typeof(list2) then
			return (`type mismatch at {table.concat(list3, ".")}: {typeof(list)} vs {typeof(list2)}`)
		end

		if type(list) == "table" then
			if flag then
				if (getmetatable(list) ~= nil or getmetatable(list2) ~= nil) and tostring(list) ~= tostring(list2) then
					return (`tostring mismatch at {table.concat(list3, ".")}: {tostring(list)} vs {tostring(list2)}`)
				end

				if table.isfrozen(list) ~= table.isfrozen(list2) then
					return (`frozen mismatch at {table.concat(list3, ".")}`)
				end
			end

			local v3 = {}

			for k in list do
				v3[k] = true
			end

			for k in list2 do
				v3[k] = true
			end

			for k in v3 do
				table.insert(list3, (tostring(k)))
				local v4 = deepCompare(list[k], list2[k], list3, flag)
				table.remove(list3)

				if v4 then
					return v4
				end
			end

			return nil
		elseif list == list2 then
			return nil
		else
			return (`value mismatch at {table.concat(list3, ".")}: {tostring(list)} vs {tostring(list2)}`)
		end
	end
end

local function assertResultsMatch(p: string, list, loaded, flag: boolean)
	assert(#list == #loaded, (`{p}: expected {#list} results, got {#loaded}`))

	for i = 1, #list do
		local v3 = list[i]
		local v4 = loaded[i]
		assert(v3:isOk() == v4:isOk(), (`{p}: #{i} ok mismatch ({v3:isOk()} vs {v4:isOk()})`))

		if v3:isErr() then
			assert(
				v3:unwrapErr() == v4:unwrapErr(),
				(`{p}: #{i} error mismatch "{v3:unwrapErr()}" vs "{v4:unwrapErr()}"`)
			)
		else
			local v5 = deepCompare(v3:unwrap(), v4:unwrap(), {}, flag)
			assert(v5 == nil, (`{p}: #{i}: {v5}`))
		end
	end
end

local function syntheticConfig(itemId: number, items)
	local result = {
		Index = {
			ItemId = itemId,
			StorageKey = `Synthetic {itemId}`,
			IdType = "Tool",
			DebugLabel = `Synthetic {itemId} [Tool-{itemId}]`
		},
		Display = {},
		Inventory = {
			Groups = { "Backpack" },
			Brackets = {},
			Actions = {},
			Tags = {},
			TileOverlays = {}
		},
		Quality = {
			Rarity = "Common",
			RarityValue = 0
		},
		Variant = {},
		State = {
			StorageMethod = "Items"
		}
	}

	for k, item in items do
		result[k] = item
	end

	return result
end

local function roundTrip(p)
	local serialized2 = Bake.serialize(p)
	count += 1
	local moduleScript = Instance.new("ModuleScript")
	moduleScript.Name = `BakeSpecBaked{count}`
	moduleScript.Source = serialized2
	moduleScript.Parent = script
	local module = require(moduleScript)
	moduleScript:Destroy()
	return module, (Bake.load(module))
end

local function spriteKeys()
	local v3 = nil

	for k in Spritesheets.MAP_WITH_EXT do
		if v3 == nil or k < v3 then
			v3 = k
		end
	end

	assert(v3, "no sprites with extensions are available")
	local v4 = nil

	for k in Spritesheets.MAP do
		if Spritesheets.MAP_WITH_EXT[k] == nil and (v4 == nil or k < v4) then
			v4 = k
		end
	end

	assert(v4, "no extension-less sprite keys are available")
	return v3, v4
end

local function runCase(method: string)
	if method == "parseCollectsPositionalItems" then
		if not parsed then
			parsed = Bake.parse()
		end

		local v3 = parsed
		local items = Bake.collectItems(v3)
		local count2 = 0
		local count3 = 0

		for k, v4 in v3 do
			if not v4:isOk() then
				continue
			end

			local itemId = v4:unwrap().Index.ItemId

			if itemId == k then
				count2 += 1
			else
				count3 += 1
				local v5 = v3[itemId]
				local v6

				if v5 == nil then
					v6 = false
				else
					v6 = v5:isOk() and v5:unwrap().Index.ItemId == itemId
				end

				assert(v6, (`redirected config #{k} points at #{itemId} which is not a positional config`))
			end
		end

		assert(
			#items == count2,
			(`collectItems returned {#items} items for {count2} positional configs ({count3} redirected)`)
		)
		assert(#items > 0, "no items were parsed")

		for i = 2, #items do
			assert(items[i].Index.ItemId > items[i - 1].Index.ItemId, "collected items are not in ascending id order")
		end

		local clone = table.clone(v3)
		table.insert(clone, 1, (Result.err("shift")))
		assert(
			#Bake.collectItems(clone) == 0,
			"collectItems should drop configs whose position no longer matches their id"
		)
	elseif method == "roundTripMatchesParse" then
		if not serialized then
			local serialize = Bake.serialize

			if not parsed then
				parsed = Bake.parse()
			end

			serialized = serialize(parsed)
		end

		local source = serialized
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `BakeSpecBaked{count}`
		moduleScript.Source = source
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		assert(Bake.isFresh(module), "freshly serialized configs should be fresh")

		if not parsed then
			parsed = Bake.parse()
		end

		assertResultsMatch("parse vs load(serialize(parse))", parsed, Bake.load(module), true)
	elseif method == "serializeDeterministic" then
		local serialize = Bake.serialize

		if not parsed then
			parsed = Bake.parse()
		end

		local serialized2 = serialize(parsed)

		if not serialized then
			local serialize2 = Bake.serialize

			if not parsed then
				parsed = Bake.parse()
			end

			serialized = serialize2(parsed)
		end

		assert(serialized2 == serialized, "serializing the same results twice produced different output")
	elseif method == "serializeIdempotent" then
		local load = Bake.load

		if not serialized then
			local serialize = Bake.serialize

			if not parsed then
				parsed = Bake.parse()
			end

			serialized = serialize(parsed)
		end

		local source = serialized
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `BakeSpecBaked{count}`
		moduleScript.Source = source
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		local loaded = load(module)
		local serialized2 = Bake.serialize(loaded)

		if not serialized then
			local serialize = Bake.serialize

			if not parsed then
				parsed = Bake.parse()
			end

			serialized = serialize(parsed)
		end

		assert(serialized2 == serialized, "serialize(load(serialize(x))) differs from serialize(x)")
	elseif method == "bakedHeaderAndCounts" then
		if not serialized then
			local serialize = Bake.serialize

			if not parsed then
				parsed = Bake.parse()
			end

			serialized = serialize(parsed)
		end

		local source = serialized
		local v4

		if source:sub(1, 2) == "--" then
			v4 = source:find("bake%-item%-config%.lune%.luau", 1) ~= nil
		else
			v4 = false
		end

		assert(v4, "generated header is missing")
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `BakeSpecBaked{count}`
		moduleScript.Source = source
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		assert(module.IndexCount == #Index, (`IndexCount {module.IndexCount} vs {#Index}`))
		local count2 = module.Count

		if not parsed then
			parsed = Bake.parse()
		end

		local v5 = count2 == #parsed
		local count3 = module.Count

		if not parsed then
			parsed = Bake.parse()
		end

		assert(v5, (`Count {count3} vs {#parsed}`))
		local count4 = 0
		local count5 = 0

		for _ in module.Configs do
			count4 += 1
		end

		for _ in module.Errors do
			count5 += 1
		end

		assert(
			count4 + count5 == module.Count,
			(`configs ({count4}) + errors ({count5}) should cover every result ({module.Count})`)
		)

		for i = 1, module.Count do
			assert(
				module.Configs[i] ~= nil ~= (module.Errors[i] ~= nil),
				(`result #{i} should be exactly one of config or error`)
			)
		end
	elseif method == "isFreshAcceptsCurrentData" then
		local isFresh = Bake.isFresh

		if not serialized then
			local serialize = Bake.serialize

			if not parsed then
				parsed = Bake.parse()
			end

			serialized = serialize(parsed)
		end

		local source = serialized
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `BakeSpecBaked{count}`
		moduleScript.Source = source
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		assert(isFresh(module), "current bake should be fresh")
	elseif method == "isFreshRejectsIndexCount" then
		if not serialized then
			local serialize = Bake.serialize

			if not parsed then
				parsed = Bake.parse()
			end

			serialized = serialize(parsed)
		end

		local source = serialized
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `BakeSpecBaked{count}`
		moduleScript.Source = source
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		module.IndexCount += 1
		assert(not Bake.isFresh(module), "a changed index count should be stale")
	elseif method == "isFreshRejectsStorageKey" then
		if not serialized then
			local serialize = Bake.serialize

			if not parsed then
				parsed = Bake.parse()
			end

			serialized = serialize(parsed)
		end

		local source = serialized
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `BakeSpecBaked{count}`
		moduleScript.Source = source
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		local _, v4 = next(module.Configs)
		assert(v4, "no baked configs")
		v4.Index.StorageKey ..= " renamed"
		assert(not Bake.isFresh(module), "a renamed storage key should be stale")
	elseif method == "isFreshRejectsIdType" then
		if not serialized then
			local serialize = Bake.serialize

			if not parsed then
				parsed = Bake.parse()
			end

			serialized = serialize(parsed)
		end

		local source = serialized
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `BakeSpecBaked{count}`
		moduleScript.Source = source
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		local _, v4 = next(module.Configs)
		assert(v4, "no baked configs")
		v4.Index.IdType = v4.Index.IdType == "Tool" and "Rod" or "Tool"
		assert(not Bake.isFresh(module), "a changed id type should be stale")
	elseif method == "isFreshRejectsRetiredOrUnknownItem" then
		local itemId = nil

		for k, v5 in Index do
			if v5["Do Not Use"] == "FALSE" then
				continue
			end

			itemId = k
			break
		end

		if not serialized then
			local serialize = Bake.serialize

			if not parsed then
				parsed = Bake.parse()
			end

			serialized = serialize(parsed)
		end

		local source = serialized
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `BakeSpecBaked{count}`
		moduleScript.Source = source
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		local _, v6 = next(module.Configs)
		assert(v6, "no baked configs")
		v6.Index.ItemId = #Index + 1
		assert(not Bake.isFresh(module), "a config outside the index should be stale")

		if itemId then
			local v7 = Index[itemId]

			if not serialized then
				local serialize = Bake.serialize

				if not parsed then
					parsed = Bake.parse()
				end

				serialized = serialize(parsed)
			end

			local source2 = serialized
			count += 1
			local moduleScript2 = Instance.new("ModuleScript")
			moduleScript2.Name = `BakeSpecBaked{count}`
			moduleScript2.Source = source2
			moduleScript2.Parent = script
			local module2 = require(moduleScript2)
			moduleScript2:Destroy()
			local _, v9 = next(module2.Configs)
			assert(v9, "no baked configs")
			v9.Index.ItemId = itemId
			v9.Index.StorageKey = v7["Storage Key"]
			v9.Index.IdType = v7["Id Type"]
			assert(not Bake.isFresh(module2), "a retired item baked as a config should be stale")
		end
	elseif method == "loadFillsMissingResults" then
		local v3 = syntheticConfig(1, {})
		local v4 = {
			IndexCount = #Index,
			Count = 4,
			Configs = {
				[1] = v3,
				[4] = syntheticConfig(4, {})
			},
			Errors = {
				[2] = "boom"
			}
		}
		local loaded = Bake.load(v4)
		assert(#loaded == 4, (`expected 4 results, got {#loaded}`))
		assert(loaded[1]:isOk() and rawequal(loaded[1]:unwrap(), v3), "config #1 should load in place")
		assert(
			table.isfrozen(v3) and table.isfrozen(v3.Index) and tostring(v3) == "ItemConfig(Synthetic 1 [Tool-1])",
			"loaded configs should be finalized"
		)
		assert(loaded[2]:isErr() and loaded[2]:unwrapErr() == "boom", "baked errors should be preserved")
		assert(
			loaded[3]:isErr() and loaded[3]:unwrapErr() == "missing baked config #3",
			"missing results should report an error"
		)
		assert(loaded[4]:isOk() and loaded[4]:unwrap().Index.ItemId == 4, "config #4 should load")
	elseif method == "swapSpritesResolvesEveryField" then
		local sprite, v4 = spriteKeys()
		local v5 = {
			Display = {
				Name = "keep"
			},
			Inventory = {},
			Skin = {},
			Variant = {
				VariantOf = 1
			}
		}

		for k, v6 in v do
			local v7 = v5[v6[1]]
			local v8 = v6[2]
			local v9

			if k % 2 == 0 then
				v9 = sprite
			else
				v9 = v4
			end

			v7[v8] = v9
		end

		Bake.swapSprites(v5)

		for k, v6 in v do
			local v7

			if k % 2 == 0 then
				v7 = sprite
			else
				v7 = v4
			end

			local v8 = Spritesheets.MAP_WITH_EXT[v7] or Spritesheets.MAP[v7]
			assert(rawequal(v5[v6[1]][v6[2]], v8), (`{v6[1]}.{v6[2]} did not resolve to the shared sprite`))
			assert(rawequal(Bake.resolveSprite(v7), v8), (`resolveSprite("{v7}") returned a different table`))
		end

		local v6

		if v5.Display.Name == "keep" then
			v6 = v5.Variant.VariantOf == 1
		else
			v6 = false
		end

		assert(v6, "non-sprite fields were touched")
		local v7 = {
			Display = {
				Sprite = sprite
			},
			Inventory = {}
		}
		Bake.swapSprites(v7)
		assert(
			rawequal(v7.Display.Sprite, Bake.resolveSprite(sprite)) and v7.Skin == nil,
			"missing sections should be skipped"
		)
	elseif method == "swapSpritesRejectsBadKeys" then
		local v3 = spriteKeys()
		assert(not pcall(Bake.swapSprites, {
			Display = {
				Sprite = 5
			}
		}), "numeric sprite keys should be rejected")
		assert(not pcall(Bake.swapSprites, {
			Display = {
				Sprite = {
					Image = "x"
				}
			}
		}), "table sprite values should be rejected")
		assert(not pcall(Bake.swapSprites, {
			Display = {
				Sprite = "definitely-not-a-sprite-key.png"
			}
		}), "unknown sprite keys should be rejected")
		assert(not pcall(Bake.resolveSprite, "definitely-not-a-sprite-key"), "resolveSprite should reject unknown keys")
		assert(
			rawequal(Bake.resolveSprite(v3), Spritesheets.MAP_WITH_EXT[v3]),
			"resolveSprite should prefer the extension map"
		)
	elseif method == "scalarFormattingRoundTrip" then
		local numbers = {
			0,
			1,
			-1,
			7,
			255,
			2147483648,
			2147483647,
			9007199254740992,
			1000000000000000,
			1000000000000001,
			-1000000000000000,
			123456789012,
			0.1,
			0.5,
			-2.5,
			0.3333333333333333,
			0.6666666666666666,
			3.141592653589793,
			1e-7,
			1e-300,
			1.7976931348623157e308,
			5e-324,
			1e999,
			-1e999
		}
		local v4 = {
			Numbers = numbers,
			Strings = {
				"",
				"plain",
				"with \"double\" quotes",
				"with 'single' quotes",
				"new\nline",
				"carriage\rreturn",
				"tab\tseparated",
				"nul\0byte",
				"back\\slash",
				"unicode é 🍎 日本",
				"]]",
				"%d %s %q",
				"[[long",
				"\1\2\3\127",
				"trailing space "
			},
			Booleans = { true, false, true },
			Colors = {
				Color3.fromRGB(255, 128, 0),
				Color3.fromRGB(0, 0, 0),
				Color3.fromRGB(255, 255, 255),
				Color3.new(0.1, 0.2, 0.3),
				Color3.new(0.3333333333333333, 0.6666666666666666, 0.999)
			},
			Mixed = {
				[1] = "one",
				[2] = "two",
				[10] = "ten",
				A = 1,
				Z = 2,
				[true] = "yes",
				[false] = "no",
				[2.5] = "half",
				[-1] = "neg"
			},
			Empty = {},
			Nested = {
				Level = {
					Deeper = {
						Leaf = {
							1,
							{
								2,
								{ 3 }
							}
						}
					}
				}
			},
			Flags = {
				IsOn = true,
				IsOff = false
			}
		}
		local v5 = { (Result.ok((syntheticConfig(1, v4)))) }
		local serialized2 = Bake.serialize(v5)
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `BakeSpecBaked{count}`
		moduleScript.Source = serialized2
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		local loaded = Bake.load(module)
		local v6 = deepCompare(v5[1]:unwrap(), loaded[1]:unwrap(), {}, false)
		assert(v6 == nil, v6 or "")

		for k, v7 in numbers do
			local number = loaded[1]:unwrap().Numbers[k]
			local v8

			if number == v7 then
				v8 = v7 ~= 0 or 1 / number == 1 / v7
			else
				v8 = false
			end

			assert(v8, (`number #{k} ({v7}) came back as {number}`))
		end
	elseif method == "keyOrderIsCanonical" then
		local v3 = syntheticConfig(1, {
			Extra = {
				Z = 1,
				A = 2,
				[3] = "c",
				[1] = "a",
				M = {
					Y = true,
					B = false
				}
			}
		})
		local v4 = syntheticConfig(1, {
			Extra = {
				[1] = "a",
				A = 2,
				M = {
					B = false,
					Y = true
				},
				[3] = "c",
				Z = 1
			}
		})
		local serialized2 = Bake.serialize({ (Result.ok(v3)) })
		assert(serialized2 == Bake.serialize({ (Result.ok(v4)) }), "insertion order changed the serialized output")
		local v5 = serialized2:match("%[\"Extra\"%] = {(.-)\n\t\t\t}") or ""
		assert(
			(v5:find("%[1%]") or 1e999) < (v5:find("%[\"A\"%]") or 1e999),
			"numeric keys should be written before string keys"
		)
		local v6

		if (v5:find("%[\"A\"%]") or 1e999) < (v5:find("%[\"M\"%]") or 1e999) then
			v6 = (v5:find("%[\"M\"%]") or 1e999) < (v5:find("%[\"Z\"%]") or 1e999)
		else
			v6 = false
		end

		assert(v6, "string keys should be sorted")
	elseif method == "spriteIdentitySurvivesRoundTrip" then
		local v3, v4 = spriteKeys()
		local v5 = syntheticConfig(1, {
			Display = {
				Sprite = Bake.resolveSprite(v4),
				OutlineSprite = Bake.resolveSprite(v3),
				CornerIcon = Spritesheets.MAP[v4]
			},
			Inventory = {
				Groups = {},
				Brackets = {},
				Actions = {},
				Tags = {},
				TileOverlays = {},
				StackCategoryIcon = Spritesheets.MAP_WITH_EXT[v3]
			},
			Skin = {
				Type = "Fruit",
				IsDefault = false,
				IsChromatic = false,
				Adornee = 1,
				EquippedAdorneeSprite = Bake.resolveSprite(v3)
			}
		})
		local serialized2 = Bake.serialize({ (Result.ok(v5)) })
		local v6

		if serialized2:find(string.format("%q", v4), 1, true) == nil then
			v6 = false
		else
			v6 = serialized2:find(string.format("%q", v3), 1, true) ~= nil
		end

		assert(v6, "sprite keys should be written as strings")
		assert(serialized2:find("ImageRectOffset", 1, true) == nil, "sprite tables should not be inlined")
		local load = Bake.load
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `BakeSpecBaked{count}`
		moduleScript.Source = serialized2
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		local loaded = load(module)
		local v7 = deepCompare(v5, loaded[1]:unwrap(), {}, false)
		assert(v7 == nil, v7 or "")
		assert(
			rawequal(loaded[1]:unwrap().Display.CornerIcon, Spritesheets.MAP[v4]),
			"extension-less sprites should resolve back to the same table"
		)
	elseif method == "errorsSurviveRoundTrip" then
		local v3 = {
			Result.err("Item #1: skip me"),
			Result.ok((syntheticConfig(2, {}))),
			Result.err("weird \"quoted\"\nmulti-line\terror with \0 nul"),
			Result.ok((syntheticConfig(4, {}))),
			(Result.err("bad id: #5"))
		}
		local serialized2 = Bake.serialize(v3)
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `BakeSpecBaked{count}`
		moduleScript.Source = serialized2
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		local loaded = Bake.load(module)
		local v4

		if module.Count == 5 and module.Configs[1] == nil and module.Configs[3] == nil then
			v4 = module.Configs[5] == nil
		else
			v4 = false
		end

		assert(v4, "error slots should not have configs")
		assertResultsMatch("errors round trip", v3, loaded, false)
	elseif method == "serializeRejectsUnsupportedValues" then
		local function expectError(p: string, p2, p3: string)
			local success, result = pcall(Bake.serialize, { (Result.ok((syntheticConfig(1, p2)))) })
			assert(not success, (`{p} should not serialize`))
			assert(tostring(result):find(p3, 1, true) ~= nil, (`{p} produced an unexpected error: {tostring(result)}`))
		end

		expectError("functions", {
			Bad = {
				Fn = print
			}
		}, "cannot bake value of type \"function\"")
		expectError("nan", {
			Bad = {
				N = (0 / 0)
			}
		}, "cannot bake nan")
		expectError("table keys", {
			Bad = {
				[{}] = 1
			}
		}, "cannot bake key of type \"table\"")
		expectError("vectors", {
			Bad = {
				V = Vector2.new(1, 2)
			}
		}, "cannot bake value of type \"Vector2\"")
		local v3 = spriteKeys()
		expectError("misplaced sprites", {
			Display = {
				Misplaced = Bake.resolveSprite(v3)
			}
		}, "sprite found at unexpected path")
		expectError("deep sprites", {
			Extra = {
				Deep = {
					Sprite = Bake.resolveSprite(v3)
				}
			}
		}, "sprite found at unexpected path")
	else
		error((`unknown case: {method}`))
	end
end

return SimpleTest.Test.new({ SimpleTest.Parameter.Choose.new("TestCase", v2, function(p)
		return p.Method
	end) }, function(p)
	runCase(p.Method)
	return true
end, #v2 + 1)