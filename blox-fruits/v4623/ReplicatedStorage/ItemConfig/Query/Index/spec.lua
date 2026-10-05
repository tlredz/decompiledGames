local createVector = vector.create
local SimpleTest = require(game.ReplicatedStorage.Packages.SimpleTest)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Index = require(script.Parent.Index)
local Legacy = require(script.Parent.Legacy)
local Storage = require(script.Parent.Parent.Storage)
local NIL_SENTINEL = Index.NIL_SENTINEL
local v = {
	{
		Method = "bitOpsAcrossWords"
	},
	{
		Method = "allItemsMask"
	},
	{
		Method = "canonValue"
	},
	{
		Method = "isArray"
	},
	{
		Method = "internPath"
	},
	{
		Method = "internAtom"
	},
	{
		Method = "atomsMatchLegacy"
	},
	{
		Method = "existsMatchesLegacy"
	},
	{
		Method = "incrementalMatchesSinglePass"
	},
	{
		Method = "loadMatchesFresh"
	},
	{
		Method = "loadThenHydrateMatchesSinglePass"
	},
	{
		Method = "serializeDeterministic"
	},
	{
		Method = "serializeIdempotent"
	},
	{
		Method = "bitsetEncodings"
	},
	{
		Method = "nilSentinelRoundTrip"
	},
	{
		Method = "loadRejectsStale"
	},
	{
		Method = "realItemsLoadMatchesFresh"
	},
	{
		Method = "realItemsWithTempsMatchesSinglePass"
	}
}
local v2 = { Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.new(0.1, 0.2, 0.3) }
local v3 = { "Backpack", "Stash", "Wardrobe" }
local count = 0

local function compile(source: string)
	count += 1
	local moduleScript = Instance.new("ModuleScript")
	moduleScript.Name = `IndexSpecBaked{count}`
	moduleScript.Source = source
	moduleScript.Parent = script
	local module = require(moduleScript)
	moduleScript:Destroy()
	return module
end

local function syntheticItems(p: number, value: number?)
	local v4 = value or 0
	local result = {}

	for i = 1, p do
		local v5 = v4 + i
		local v6 = {
			Index = {
				ItemId = v5,
				StorageKey = `Item {v5}`,
				IdType = v5 % 3 == 0 and "Skin" or "Moveset",
				DebugLabel = `Item {v5}`
			},
			Display = 0,
			Inventory = 0,
			Quality = 0,
			Variant = 0,
			State = 0
		}
		local name

		if v5 % 4 ~= 0 then
			name = `Name {v5}`
		end

		v6.Display = {
			Name = name,
			OutlineColor = v2[v5 % 3 + 1]
		}
		local v11 = v3[v5 % 3 + 1]
		local v12

		if v5 % 5 == 0 then
			v12 = v3[(v5 + 1) % 3 + 1]
		end

		local maxStack

		if v5 % 6 == 0 then
			maxStack = v5
		end

		v6.Inventory = {
			Groups = { v11, v12 },
			Tags = {},
			MaxStack = maxStack,
			Nested = {
				Deep = {
					Value = v5 % 2 == 0,
					Count = v5 % 4
				}
			}
		}
		v6.Quality = {
			Rarity = v5 % 2 == 0 and "Common" or "Legendary",
			RarityValue = v5 % 7
		}
		local variantOf

		if v5 % 5 == 0 then
			variantOf = v5 - 1
		end

		v6.Variant = {
			VariantOf = variantOf,
			IsFoundation = v5 % 5 ~= 0
		}
		v6.State = {
			StorageMethod = "Items"
		}

		if v5 % 3 == 0 then
			local skin = {
				Type = v5 % 2 == 0 and "Fruit" or "Aura",
				Adornee = v5 - 1,
				IsDefault = false,
				Physical = 0
			}
			local physical

			if v5 % 9 == 0 then
				physical = v5 - 2
			end

			skin.Physical = physical
			v6.Skin = skin
		end

		if v5 % 4 == 1 then
			local skillRedirect

			if v5 % 8 == 1 then
				skillRedirect = v5 + 1
			end

			v6.Moveset = {
				Type = "Fruit",
				SkillRedirect = skillRedirect
			}
		end

		if v5 % 11 == 0 then
			v6.Economy = {
				PurchaseWith = v5,
				IsPremiumRandomItem = false
			}
		end

		if v5 % 37 == 0 then
			v6.Rare = {
				Flag = true,
				Values = { "a", "b" }
			}
		end

		result[i] = v6
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hydrated(p)
	local v4 = Index.new()
	Index.hydrate(v4, p)
	return v4
end

local function reload(p, p2)
	local serialized = Index.serialize(p)
	count += 1
	local moduleScript = Instance.new("ModuleScript")
	moduleScript.Name = `IndexSpecBaked{count}`
	moduleScript.Source = serialized
	moduleScript.Parent = script
	local module = require(moduleScript)
	moduleScript:Destroy()
	local loaded = Index.load(module, p2)
	assert(loaded, "serialized index did not load against the items it was built from")
	return loaded
end

local function assertSnapshotsEqual(p: string, p2, p3)
	local snapshot = Index.snapshot(p2)
	local snapshot2 = Index.snapshot(p3)
	local count2 = 0

	for k, v4 in snapshot do
		count2 += 1
		assert(snapshot2[k] == v4, (`{p}: "{k}" differs: {v4} vs {tostring(snapshot2[k])}`))
	end

	for k in snapshot2 do
		assert(snapshot[k] ~= nil, (`{p}: "{k}" only present in the second index`))
	end

	assert(count2 > 1, (`{p}: snapshot is empty`))
end

local function bitsToList(p, p2)
	local result = {}

	for i = 0, p.BitCount - 1 do
		if Index.testBit(p2, i) then
			table.insert(result, i)
		end
	end

	return result
end

local function pathChain(p)
	local result = {
		[Index.ROOT_PATH_ID] = {}
	}
	local v4 = { Index.ROOT_PATH_ID }

	while #v4 > 0 do
		local v5 = table.remove(v4)
		local v6 = p.PathChildren[v5]

		if not v6 then
			continue
		end

		for k, v7 in v6 do
			local clone = table.clone(result[v5])
			table.insert(clone, k)
			result[v7] = clone
			table.insert(v4, v7)
		end
	end

	return result
end

local function queryFor(list, p)
	for i = #list, 1, -1 do
		p = {
			[list[i]] = p
		}
	end

	return p
end

local function legacyBits(items, p)
	local result = {}

	for k, item in items do
		if Legacy.checkQuery(item, p) then
			table.insert(result, k - 1)
		end
	end

	return result
end

local function assertSameList(p: string, list, list2)
	assert(
		table.concat(list, ",") == table.concat(list2, ","),
		(`{p}: expected [{table.concat(list, ",")}] got [{table.concat(list2, ",")}]`)
	)
end

local function withNewFields(list, p: number)
	local clone = table.clone(list)

	for i = p, #list do
		local copy = TableUtil.deepCopy(list[i])
		copy.Index.ItemId = i + 100000
		copy.Display.BrandNewField = `new-{i}`
		copy.Display.Name = nil
		copy.BrandNewSection = {
			Value = i % 2 == 0,
			List = { i, i + 1 }
		}

		if copy.Skin == nil then
			copy.Skin = {
				Type = "Fruit",
				IsDefault = false,
				Adornee = 1
			}
		end

		table.insert(clone, copy)
	end

	return clone
end

local function runCase(method: string)
	if method == "bitOpsAcrossWords" then
		local v4 = syntheticItems(70)
		local v5 = Index.new()
		Index.hydrate(v5, v4)
		local v6

		if v5.BitCount == 70 then
			v6 = v5.WordCount == 3
		else
			v6 = false
		end

		assert(v6, (`expected 70 bits in 3 words, got {v5.BitCount}/{v5.WordCount}`))
		local empty = Index.newEmpty(v5)
		local empty2 = Index.newEmpty(v5)

		for _, v7 in {
			0,
			31,
			32,
			63,
			64,
			69
		} do
			Index.setBit(empty, v7)
		end

		for _, v7 in {
			31,
			32,
			33,
			69
		} do
			Index.setBit(empty2, v7)
		end

		assertSameList("a bits", {
			0,
			31,
			32,
			63,
			64,
			69
		}, bitsToList(v5, empty))
		assert(
			not (Index.testBit(empty, 1) or Index.testBit(empty, 62) or Index.testBit(empty, 65)),
			"unset bits read as set"
		)
		assertSameList("band", { 31, 32, 69 }, bitsToList(v5, Index.band(v5, empty, empty2)))
		assertSameList("bor", {
			0,
			31,
			32,
			33,
			63,
			64,
			69
		}, bitsToList(v5, Index.bor(v5, empty, empty2)))
		local v7

		if Index.popcount(v5, empty) == 6 then
			v7 = Index.popcount(v5, empty2) == 4
		else
			v7 = false
		end

		assert(v7, "popcount mismatch")
		assert(Index.popcount(v5, v5.Empty) == 0, "empty bitset has bits")
		local itemConfigList = Index.toItemConfigList(v5, empty)
		assert(#itemConfigList == 6, (`toItemConfigList returned {#itemConfigList} items`))

		for k, v8 in {
			0,
			31,
			32,
			63,
			64,
			69
		} do
			assert(
				itemConfigList[k].Index.ItemId == v8 + 1,
				(`toItemConfigList item #{k} is {itemConfigList[k].Index.ItemId}`)
			)
		end

		local clone = table.clone(v5.Empty)
		Index.setBit(clone, 70)
		Index.setBit(clone, 95)
		assert(#Index.toItemConfigList(v5, clone) == 0, "bits beyond BitCount produced items")
	elseif method == "allItemsMask" then
		for _, v4 in {
			1,
			31,
			32,
			33,
			64,
			65,
			100
		} do
			local v6 = hydrated(syntheticItems(v4)) -- equivalent call inferred; original call site unknown
			assert(Index.popcount(v6, v6.AllItems) == v4, (`AllItems popcount for {v4} items`))

			for i = 0, v6.WordCount * Index.WORD_BITS - 1 do
				assert(Index.testBit(v6.AllItems, i) == (i < v4), (`AllItems bit {i} for {v4} items`))
			end

			assert(#Index.toItemConfigList(v6, v6.AllItems) == v4, (`AllItems list for {v4} items`))
		end
	elseif method == "canonValue" then
		assert(Index.canonValue(nil) == NIL_SENTINEL, "nil should canonicalize to the sentinel")
		local v4

		if Index.canonValue("a") == "a" and Index.canonValue(3) == 3 then
			v4 = Index.canonValue(true) == true
		else
			v4 = false
		end

		assert(v4, "scalars should pass through")
		assert(
			Index.canonValue(Color3.new(0.1, 0.2, 0.3)) == Index.canonValue(Color3.new(0.1, 0.2, 0.3)),
			"equal colors differ"
		)
		assert(
			Index.canonValue(Color3.new(0.1, 0.2, 0.3)) ~= Index.canonValue(Color3.new(0.3, 0.2, 0.1)),
			"different colors collide"
		)
		assert(type(Index.canonValue(Color3.new(1, 1, 1))) == "string", "Color3 should canonicalize to a string")
		assert(
			Index.canonValue(createVector(1, 2, 3)) == Index.canonValue(createVector(1, 2, 3)),
			"equal Vector3 differ"
		)
		assert(
			Index.canonValue(createVector(1, 2, 3)) ~= Index.canonValue(createVector(3, 2, 1)),
			"different Vector3 collide"
		)
		assert(Index.canonValue(Vector2.new(1, 2)) == Index.canonValue(Vector2.new(1, 2)), "equal Vector2 differ")
		assert(Index.canonValue(Vector2.new(1, 2)) ~= Index.canonValue(Vector2.new(2, 1)), "different Vector2 collide")
		assert(
			Index.canonValue(Vector2.new(1, 2)) ~= Index.canonValue(createVector(1, 2, 0)),
			"Vector2 and Vector3 collide"
		)
	elseif method == "isArray" then
		assert(Index.isArray({}) and Index.isArray({ 1, 2 }) and Index.isArray({ "a" }), "arrays not detected")
		assert(not (Index.isArray({
			a = 1
		}) or Index.isArray({
			1,
			2,
			a = 3
		})), "dictionaries detected as arrays")
		assert(not (Index.isArray({
			[2] = 1
		}) or Index.isArray({
			[1.5] = 1
		}) or Index.isArray({
			[0] = 1
		})), "sparse tables detected as arrays")
		assert(not (Index.isArray("x") or Index.isArray(1) or Index.isArray(nil)), "non-tables detected as arrays")
	elseif method == "internPath" then
		local v4 = Index.new()
		local internPath = Index.internPath(v4, Index.ROOT_PATH_ID, "A")
		local internPath2 = Index.internPath(v4, internPath, "B")
		local internPath3 = Index.internPath(v4, internPath, 1)
		local internPath4 = Index.internPath(v4, internPath, true)
		local v5

		if internPath == internPath2 or internPath2 == internPath3 or internPath3 == internPath4 then
			v5 = false
		else
			v5 = internPath ~= internPath4
		end

		assert(v5, "paths should be distinct")
		local v6

		if Index.internPath(v4, Index.ROOT_PATH_ID, "A") == internPath then
			v6 = Index.internPath(v4, internPath, "B") == internPath2
		else
			v6 = false
		end

		assert(v6, "paths should be stable")
		local v7

		if Index.internPath(v4, internPath, 1) == internPath3 then
			v7 = Index.internPath(v4, internPath, true) == internPath4
		else
			v7 = false
		end

		assert(v7, "numeric and boolean keys should be stable")
		local v8

		if v4.PathParent[internPath] == Index.ROOT_PATH_ID then
			v8 = v4.PathParent[internPath2] == internPath
		else
			v8 = false
		end

		assert(v8, "parents mismatch")
		local v9

		if v4.PathChildren[internPath].B == internPath2 and v4.PathChildren[internPath][1] == internPath3 then
			v9 = v4.PathChildren[internPath][true] == internPath4
		else
			v9 = false
		end

		assert(v9, "children mismatch")
		assert(v4.NextPathId == 4, (`expected 4 paths, got {v4.NextPathId}`))
	elseif method == "internAtom" then
		local v5 = hydrated(syntheticItems(5)) -- equivalent call inferred; original call site unknown
		local internPath = Index.internPath(v5, Index.ROOT_PATH_ID, "Probe")
		local internAtom = Index.internAtom(v5, internPath, "x")
		assert(Index.internAtom(v5, internPath, "x") == internAtom, "atoms should be stable")
		assert(Index.internAtom(v5, internPath, "y") ~= internAtom, "different values should get different atoms")
		assert(
			Index.internAtom(v5, internPath, Color3.new(0.5, 0.5, 0.5)) == Index.internAtom(
				v5,
				internPath,
				Color3.new(0.5, 0.5, 0.5)
			),
			"equal colors should share an atom"
		)
		assert(v5.AtomToPath[internAtom] == internPath, "atom path mismatch")
		assert(Index.popcount(v5, v5.AtomBitsets[internAtom]) == 0, "new atoms should start empty")
		local internAtom2 = Index.internAtom(v5, internPath, nil)
		assert(v5.PathValueToAtom[internPath][NIL_SENTINEL] == internAtom2, "nil atom should be keyed by the sentinel")
		assertSameList("root nil atom covers every item", {
			0,
			1,
			2,
			3,
			4
		}, bitsToList(v5, v5.AtomBitsets[internAtom2]))
		local internPath2 = Index.internPath(v5, Index.ROOT_PATH_ID, "Display")
		local internPath3 = Index.internPath(v5, internPath2, "Unknown")
		local internAtom3 = Index.internAtom(v5, internPath3, nil)
		assertSameList(
			"nested nil atom inherits parent exists",
			bitsToList(v5, v5.PathExists[internPath2]),
			bitsToList(v5, v5.AtomBitsets[internAtom3])
		)
		local internPath4 = Index.internPath(v5, Index.internPath(v5, Index.ROOT_PATH_ID, "Missing"), "Child")
		assert(
			Index.popcount(v5, v5.AtomBitsets[Index.internAtom(v5, internPath4, nil)]) == 0,
			"nil atom under a missing section should be empty"
		)
	elseif method == "atomsMatchLegacy" then
		local v4 = syntheticItems(90)
		local v5 = hydrated(v4) -- equivalent call inferred; original call site unknown
		local v6 = pathChain(v5)
		local v7 = {}

		local function resolvePath(list)
			local ROOT_PATH_ID = Index.ROOT_PATH_ID

			for _, v8 in list do
				ROOT_PATH_ID = v5.PathChildren[ROOT_PATH_ID][v8]
				assert(ROOT_PATH_ID, (`path {table.concat(list, ".")} was not interned`))
			end

			return ROOT_PATH_ID
		end

		local function checkAtom(list, p)
			local path = resolvePath(list)
			local v8 = v5.PathValueToAtom[path][Index.canonValue(p)]
			assert(v8, (`no atom for {table.concat(list, ".")} = {tostring(p)}`))
			local v9 = p == nil and {
				Operation = "EQ",
				Value = nil
			} or p
			assertSameList(
				`atom {table.concat(list, ".")} = {tostring(p)}`,
				legacyBits(v4, queryFor(list, v9)),
				bitsToList(v5, v5.AtomBitsets[v8])
			)
			v7[v8] = true
		end

		local collect

		collect = function(items, p)
			if type(items) ~= "table" then
				checkAtom(p, items)
			elseif Index.isArray(items) then
				for _, item in items do
					if type(item) ~= "table" then
						checkAtom(p, item)
					end
				end
			else
				for k, item in items do
					local clone = table.clone(p)
					table.insert(clone, k)
					collect(item, clone)
				end
			end
		end

		for _, v8 in v4 do
			collect(v8, {})
		end

		for k, v8 in v5.PathValueToAtom do
			if v8[NIL_SENTINEL] then
				checkAtom(v6[k], nil)
			end
		end

		for i = 1, v5.NextAtomId do
			assert(v7[i], (`atom {i} at {table.concat(v6[v5.AtomToPath[i]], ".")} was never reached from an item`))
		end

		assert(v5.NextAtomId > 50, (`only {v5.NextAtomId} atoms were indexed`))
	elseif method == "existsMatchesLegacy" then
		local v4 = syntheticItems(90)
		local v5 = hydrated(v4) -- equivalent call inferred; original call site unknown
		local v6 = pathChain(v5)
		local count2 = 0

		for k, pathExist in v5.PathExists do
			local v7 = {}

			for k2, v8 in v4 do
				for _, v9 in v6[k] do
					if type(v8) == "table" then
						v8 = v8[v9]
					else
						v8 = nil
					end
				end

				if type(v8) == "table" then
					table.insert(v7, k2 - 1)
				end
			end

			assertSameList(`exists {table.concat(v6[k], ".")}`, v7, bitsToList(v5, pathExist))
			count2 += 1
		end

		assert(count2 > 5, (`only {count2} paths were checked`))
	elseif method == "incrementalMatchesSinglePass" then
		local v4 = withNewFields(syntheticItems(40), 34)
		local v5 = hydrated(v4) -- equivalent call inferred; original call site unknown
		local v6 = Index.new()
		Index.hydrate(v6, (table.move(v4, 1, 20, 1, {})))
		Index.hydrate(v6, (table.move(v4, 1, 40, 1, {})))
		Index.hydrate(v6, v4)
		assertSnapshotsEqual("incremental vs single-pass", v5, v6)
		assert(v6.BitCount == #v4, "incremental hydration lost items")
		Index.hydrate(v6, v4)
		assertSnapshotsEqual("re-hydrating the same items", v5, v6)
	elseif method == "loadMatchesFresh" then
		local v4 = withNewFields(syntheticItems(70), 66)
		local v5 = hydrated(v4) -- equivalent call inferred; original call site unknown
		local serialized = Index.serialize(v5)
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `IndexSpecBaked{count}`
		moduleScript.Source = serialized
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		local loaded = Index.load(module, v4)
		assert(loaded, "serialized index did not load against the items it was built from")
		assertSnapshotsEqual("loaded vs fresh", v5, loaded)
		local v6

		if loaded.NextPathId == v5.NextPathId then
			v6 = loaded.NextAtomId == v5.NextAtomId
		else
			v6 = false
		end

		assert(v6, "path/atom counters differ")
		local v7

		if loaded.BitCount == v5.BitCount then
			v7 = loaded.WordCount == v5.WordCount
		else
			v7 = false
		end

		assert(v7, "bit/word counts differ")

		for k, v8 in v4 do
			assert(loaded.BitToItemConfig[k] == v8, (`BitToItemConfig #{k} should reference the live item`))
			assert(loaded.ItemIdToBit[v8.Index.ItemId] == k - 1, (`ItemIdToBit for {v8.Index.ItemId}`))
		end

		Index.hydrate(loaded, v4)
		assertSnapshotsEqual("loaded + no-op hydrate vs fresh", v5, loaded)
	elseif method == "loadThenHydrateMatchesSinglePass" then
		local v4 = withNewFields(syntheticItems(70), 60)
		local v6 = hydrated(table.move(v4, 1, 70, 1, {})) -- equivalent call inferred; original call site unknown
		local serialized = Index.serialize(v6)
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `IndexSpecBaked{count}`
		moduleScript.Source = serialized
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		local loaded = Index.load(module, v4)
		assert(loaded, "serialized index did not load against the items it was built from")
		assert(loaded.BitCount == 70, "load should only cover the baked prefix")
		Index.hydrate(loaded, v4)
		assertSnapshotsEqual("baked prefix + runtime temps vs single-pass", hydrated(v4), loaded)
	elseif method == "serializeDeterministic" then
		local v4 = syntheticItems(50)
		local serialized = Index.serialize(hydrated(v4))
		local serialize2 = Index.serialize
		assert(serialized == serialize2(hydrated(v4)), "serializing the same items twice produced different output")
		local v5

		if serialized:sub(1, 2) == "--" then
			v5 = serialized:find("bake%-item%-config%.lune%.luau") ~= nil
		else
			v5 = false
		end

		assert(v5, "serialized index is missing the generated header")
	elseif method == "serializeIdempotent" then
		local v4 = withNewFields(syntheticItems(50), 45)
		local v5 = hydrated(v4) -- equivalent call inferred; original call site unknown
		local serialized = Index.serialize(v5)
		local serialize = Index.serialize
		local serialized2 = Index.serialize(v5)
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `IndexSpecBaked{count}`
		moduleScript.Source = serialized2
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		local loaded = Index.load(module, v4)
		assert(loaded, "serialized index did not load against the items it was built from")
		assert(serialize(loaded) == serialized, "serialize(load(serialize(x))) differs from serialize(x)")
	elseif method == "bitsetEncodings" then
		local v4 = syntheticItems(40)
		local v5 = hydrated(v4) -- equivalent call inferred; original call site unknown
		local serialized = Index.serialize(v5)
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `IndexSpecBaked{count}`
		moduleScript.Source = serialized
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		local count2 = 0
		local count3 = 0

		for k in module.AtomToPath do
			local atomBit = module.AtomBits[k]
			local atomWord = module.AtomWords[k]
			assert(atomBit ~= nil ~= (atomWord ~= nil), (`atom {k} should be encoded exactly once`))

			if atomWord then
				count2 += 1
				assert(#atomWord == v5.WordCount, (`atom {k} word encoding has {#atomWord} words`))
				assert(Index.popcount(v5, v5.AtomBitsets[k]) > v5.WordCount, (`atom {k} used words while sparse`))
			else
				count3 += 1
				assert(Index.popcount(v5, v5.AtomBitsets[k]) <= v5.WordCount, (`atom {k} used bits while dense`))
			end
		end

		local v6

		if count2 > 0 then
			v6 = count3 > 0
		else
			v6 = false
		end

		assert(v6, (`expected both encodings, got {count2} word / {count3} bit atoms`))
		local count4 = 0
		local count5 = 0

		for _ in module.PathExistsWords do
			count4 += 1
		end

		for _ in module.PathExistsBits do
			count5 += 1
		end

		local v7

		if count4 > 0 then
			v7 = count5 > 0
		else
			v7 = false
		end

		assert(v7, (`expected both exists encodings, got {count4} word / {count5} bit paths`))
		local serialized2 = Index.serialize(v5)
		count += 1
		local moduleScript2 = Instance.new("ModuleScript")
		moduleScript2.Name = `IndexSpecBaked{count}`
		moduleScript2.Source = serialized2
		moduleScript2.Parent = script
		local module2 = require(moduleScript2)
		moduleScript2:Destroy()
		local loaded = Index.load(module2, v4)
		assert(loaded, "serialized index did not load against the items it was built from")
		assertSnapshotsEqual("decoded encodings", v5, loaded)
	elseif method == "nilSentinelRoundTrip" then
		local v4 = syntheticItems(30)
		local v5 = hydrated(v4) -- equivalent call inferred; original call site unknown
		local serialized = Index.serialize(v5)
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `IndexSpecBaked{count}`
		moduleScript.Source = serialized
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		local loaded = Index.load(module, v4)
		assert(loaded, "serialized index did not load against the items it was built from")
		local count2 = 0

		for k, v6 in loaded.PathValueToAtom do
			for k2 in v6 do
				assert(k2 ~= "\0nil\0", (`path {k} kept the baked nil key as a string`))

				if k2 == NIL_SENTINEL then
					count2 += 1
				end
			end
		end

		assert(count2 > 0, "no nil atoms survived the round trip")
		local display = v5.PathChildren[Index.ROOT_PATH_ID].Display
		local name = v5.PathChildren[display].Name
		local v6 = loaded.PathValueToAtom[name][NIL_SENTINEL]
		assert(v6 ~= nil, "Display.Name nil atom missing after load")
		assertSameList("Display.Name nil atom", legacyBits(v4, {
			Display = {
				Name = {
					Operation = "EQ",
					Value = nil
				}
			}
		}), bitsToList(loaded, loaded.AtomBitsets[v6]))
	elseif method == "loadRejectsStale" then
		local v4 = syntheticItems(20)
		local serialized = Index.serialize(hydrated(v4))
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `IndexSpecBaked{count}`
		moduleScript.Source = serialized
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		module.Version += 1
		assert(Index.load(module, v4) == nil, "a different bake version should be rejected")
		count += 1
		local moduleScript2 = Instance.new("ModuleScript")
		moduleScript2.Name = `IndexSpecBaked{count}`
		moduleScript2.Source = serialized
		moduleScript2.Parent = script
		local module2 = require(moduleScript2)
		moduleScript2:Destroy()
		assert(
			Index.load(module2, (table.move(v4, 1, 19, 1, {}))) == nil,
			"more baked ids than items should be rejected"
		)
		count += 1
		local moduleScript3 = Instance.new("ModuleScript")
		moduleScript3.Name = `IndexSpecBaked{count}`
		moduleScript3.Source = serialized
		moduleScript3.Parent = script
		local module3 = require(moduleScript3)
		moduleScript3:Destroy()
		local clone = table.clone(v4)
		local v5 = v4[4]
		local v6 = v4[3]
		clone[3] = v5
		clone[4] = v6
		assert(Index.load(module3, clone) == nil, "an item id mismatch should be rejected")
		count += 1
		local moduleScript4 = Instance.new("ModuleScript")
		moduleScript4.Name = `IndexSpecBaked{count}`
		moduleScript4.Source = serialized
		moduleScript4.Parent = script
		local module4 = require(moduleScript4)
		moduleScript4:Destroy()
		local v7 = withNewFields(v4, 18)
		assert(Index.load(module4, v7) ~= nil, "a baked prefix of the items should load")
	elseif method == "realItemsLoadMatchesFresh" then
		local v4 = Storage.dumpItems()
		assert(#v4 > 0, "no item configs loaded")
		local v5 = hydrated(v4) -- equivalent call inferred; original call site unknown
		local serialized = Index.serialize(v5)
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `IndexSpecBaked{count}`
		moduleScript.Source = serialized
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		local loaded = Index.load(module, v4)
		assert(loaded, "serialized index did not load against the items it was built from")
		assertSnapshotsEqual("real items loaded vs fresh", v5, loaded)
		Index.hydrate(loaded, v4)
		assertSnapshotsEqual("real items loaded + hydrate vs fresh", v5, loaded)
	else
		if method ~= "realItemsWithTempsMatchesSinglePass" then
			error((`unknown case: {method}`))
			return
		end

		local v4 = Storage.dumpItems()
		local v5 = withNewFields(v4, #v4 - 6)
		local v6 = hydrated(v4) -- equivalent call inferred; original call site unknown
		local serialized = Index.serialize(v6)
		count += 1
		local moduleScript = Instance.new("ModuleScript")
		moduleScript.Name = `IndexSpecBaked{count}`
		moduleScript.Source = serialized
		moduleScript.Parent = script
		local module = require(moduleScript)
		moduleScript:Destroy()
		local loaded = Index.load(module, v5)
		assert(loaded, "serialized index did not load against the items it was built from")
		Index.hydrate(loaded, v5)
		assertSnapshotsEqual("real baked + temps vs single-pass", hydrated(v5), loaded)
	end
end

return SimpleTest.Test.new({ SimpleTest.Parameter.Choose.new("TestCase", v, function(p)
		return p.Method
	end) }, function(p)
	runCase(p.Method)
	return true
end, #v + 1)