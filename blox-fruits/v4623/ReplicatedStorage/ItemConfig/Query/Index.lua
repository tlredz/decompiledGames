require(script.Parent.Parent.Types)
local v = newproxy(false)
local Index = {}

local function formatNumber(p: number)
	assert(p == p, "cannot bake nan")

	if p == 1e999 then
		return "math.huge"
	elseif p == -1e999 then
		return "-math.huge"
	end

	if p == math.floor(p) and math.abs(p) < 1000000000000000 then
		return string.format("%d", p)
	end

	return string.format("%.17g", p)
end

local function formatValue(p)
	if p == v then
		return string.format("%q", "\0nil\0")
	end

	local typeName = type(p)

	if typeName == "string" then
		return string.format("%q", p)
	elseif typeName == "number" then
		return formatNumber(p)
	elseif typeName == "boolean" then
		return (tostring(p))
	end

	error((`cannot bake query index value of type "{typeName}"`))
end

local function formatKey(p)
	return (`[{formatValue(p)}]`)
end

local function sortedKeys(items)
	local result = {}

	for k in items do
		table.insert(result, k)
	end

	table.sort(result, function(a, b)
		local typeName = type(a)
		local typeName2 = type(b)

		if typeName == typeName2 then
			if typeName == "boolean" then
				return a == false
			end

			return typeName ~= "userdata" and a < b
		else
			return typeName == "number" or typeName2 ~= "number" and typeName < typeName2
		end
	end)
	return result
end

local function resize(state, bitCount: number)
	local wordCount = math.max(1, (math.ceil(bitCount / 32)))

	if state.WordCount < wordCount then
		for _, atomBitset in state.AtomBitsets do
			for i = #atomBitset + 1, wordCount do
				atomBitset[i] = 0
			end
		end

		for _, pathExist in state.PathExists do
			for i = #pathExist + 1, wordCount do
				pathExist[i] = 0
			end
		end
	end

	state.BitCount = bitCount
	state.WordCount = wordCount
	local allItems = table.create(wordCount, 0)
	local v4 = math.floor(bitCount / 32)

	for i = 1, v4 do
		allItems[i] = 4294967295
	end

	local v5 = bitCount - v4 * 32

	if v5 > 0 then
		allItems[v4 + 1] = bit32.lshift(1, v5) - 1
	end

	state.AllItems = allItems
	state.Empty = table.create(wordCount, 0)
end

local function isArray(list)
	if type(list) ~= "table" then
		return false
	end

	local count = #list

	if count == 0 then
		return next(list) == nil
	end

	for k in list do
		if type(k) ~= "number" or k < 1 or count < k or k % 1 ~= 0 then
			return false
		end
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function indexAtom(data, p: number, p2, p3: number)
	local internAtom = Index.internAtom(data, p, p2)
	Index.setBit(data.AtomBitsets[internAtom], p3)
end

local discoverKeys

discoverKeys = function(p, items, path: number, list)
	if type(items) ~= "table" or isArray(items) then
		return
	end

	local pathKey = p.PathKeys[path]

	if not pathKey then
		pathKey = {}
		p.PathKeys[path] = pathKey
	end

	for k, item in items do
		if pathKey[k] == nil then
			pathKey[k] = true

			if list then
				table.insert(list, {
					Path = path,
					Key = k
				})
			end
		end

		discoverKeys(p, item, Index.internPath(p, path, k), list)
	end
end

local indexItem

indexItem = function(data, items, p: number, p2: number)
	data.PathHydrated[p] = true

	if type(items) == "table" then
		local pathExist = data.PathExists[p]

		if not pathExist then
			pathExist = Index.newEmpty(data)
			data.PathExists[p] = pathExist
		end

		Index.setBit(pathExist, p2)

		if next(items) == nil or not isArray(items) then
			local pathKey = data.PathKeys[p]

			if not pathKey then
				return
			end

			for k in pathKey do
				local item = items[k]
				local internPath = Index.internPath(data, p, k)

				if item == nil then
					data.PathHydrated[internPath] = true
					indexAtom(data, internPath, nil, p2) -- equivalent call inferred; original call site unknown
				else
					indexItem(data, item, internPath, p2)
				end
			end
		else
			for _, item in items do
				if type(item) == "table" then
					continue
				end

				indexAtom(data, p, item, p2) -- equivalent call inferred; original call site unknown
			end
		end
	else
		indexAtom(data, p, items, p2) -- equivalent call inferred; original call site unknown
	end
end

local function readBitset(p, items, items2)
	local result = Index.newEmpty(p)

	if items2 then
		for k, item in items2 do
			result[k] = item
		end
	elseif items then
		for _, item in items do
			Index.setBit(result, item)
		end
	end

	return result
end

local function writeBitset(data, i: number, list, list2, list3)
	if Index.popcount(data, list) > data.WordCount then
		table.insert(list3, (`\t\t[{i}] = \{ {table.concat(list, ", ")} },\n`))
		return
	end

	local v2 = {}

	for i2 = 0, data.BitCount - 1 do
		if Index.testBit(list, i2) then
			table.insert(v2, i2)
		end
	end

	table.insert(list2, (`\t\t[{i}] = \{ {table.concat(v2, ", ")} },\n`))
end

Index.ROOT_PATH_ID = 0
Index.NIL_SENTINEL = v
Index.WORD_BITS = 32
Index.BAKED_VERSION = 3
Index.isArray = isArray

function Index.new()
	return {
		BitCount = 0,
		WordCount = 1,
		AllItems = { 0 },
		Empty = { 0 },
		BitToItemConfig = {},
		ItemIdToBit = {},
		PathChildren = {
			[0] = {}
		},
		PathParent = {},
		NextPathId = 0,
		PathKeys = {},
		PathExists = {},
		PathHydrated = {},
		PathValueToAtom = {},
		AtomBitsets = {},
		AtomToPath = {},
		NextAtomId = 0
	}
end

function Index.newEmpty(p)
	return table.create(p.WordCount, 0)
end

function Index:setBit(p2: number)
	local v2 = math.floor(p2 / 32) + 1
	local v3 = p2 - (v2 - 1) * 32
	self[v2] = bit32.bor(self[v2], (bit32.lshift(1, v3)))
end

function Index.testBit(p, p2: number)
	local v2 = math.floor(p2 / 32) + 1
	local v3 = p2 - (v2 - 1) * 32
	return (bit32.btest(p[v2], (bit32.lshift(1, v3))))
end

function Index.band(p, list, list2)
	local result = table.create(p.WordCount, 0)

	for i = 1, p.WordCount do
		result[i] = bit32.band(list[i], list2[i])
	end

	return result
end

function Index.bor(p, list, list2)
	local result = table.create(p.WordCount, 0)

	for i = 1, p.WordCount do
		result[i] = bit32.bor(list[i], list2[i])
	end

	return result
end

function Index.popcount(p, list)
	local count = 0

	for i = 1, p.WordCount do
		local v2 = list[i]

		while v2 ~= 0 do
			v2 = bit32.band(v2, v2 - 1)
			count += 1
		end
	end

	return count
end

function Index.toItemConfigList(data, list)
	local result = {}

	for i = 1, data.WordCount do
		local v2 = list[i]

		if v2 == 0 then
			continue
		end

		local v3 = (i - 1) * 32

		for i2 = 0, 31 do
			if not bit32.btest(v2, (bit32.lshift(1, i2))) then
				continue
			end

			local v4 = v3 + i2

			if v4 < data.BitCount then
				table.insert(result, data.BitToItemConfig[v4 + 1])
			end
		end
	end

	return result
end

function Index.canonValue(data)
	if data == nil then
		return v
	end

	local typeName = typeof(data)

	if typeName == "Color3" then
		return string.format("\0C3\0%g\0%g\0%g", data.R, data.G, data.B)
	elseif typeName == "Vector3" then
		return string.format("\0V3\0%g\0%g\0%g", data.X, data.Y, data.Z)
	elseif typeName == "Vector2" then
		return string.format("\0V2\0%g\0%g", data.X, data.Y)
	elseif typeName == "EnumItem" then
		return string.format("\0E\0%s", (tostring(data)))
	end

	return data
end

function Index:internPath(p: number, p2)
	local nextPathIds = self.PathChildren[p]

	if not nextPathIds then
		nextPathIds = {}
		self.PathChildren[p] = nextPathIds
	end

	local v2 = nextPathIds[p2]

	if v2 then
		return v2
	end

	self.NextPathId += 1
	nextPathIds[p2] = self.NextPathId
	self.PathParent[self.NextPathId] = p
	return self.NextPathId
end

function Index:internAtom(p: number, p2)
	local canonValue = Index.canonValue(p2)
	local nextAtomIdsByCanonValue = self.PathValueToAtom[p]

	if not nextAtomIdsByCanonValue then
		nextAtomIdsByCanonValue = {}
		self.PathValueToAtom[p] = nextAtomIdsByCanonValue
	end

	local v2 = nextAtomIdsByCanonValue[canonValue]

	if v2 then
		return v2
	end

	self.NextAtomId += 1
	local nextAtomId = self.NextAtomId
	nextAtomIdsByCanonValue[canonValue] = nextAtomId
	self.AtomToPath[nextAtomId] = p

	if self.PathHydrated[p] or canonValue ~= v then
		self.AtomBitsets[nextAtomId] = Index.newEmpty(self)
		return nextAtomId
	end

	local v3 = self.PathParent[p]
	local allItems

	if v3 == nil then
		allItems = self.AllItems
	else
		allItems = self.PathExists[v3]
	end

	if allItems then
		self.AtomBitsets[nextAtomId] = table.clone(allItems)
		return nextAtomId
	end

	self.AtomBitsets[nextAtomId] = Index.newEmpty(self)
	return nextAtomId
end

function Index.hydrate(data, list)
	local v2 = data.BitCount + 1
	local v3 = data.BitCount > 0 and {} or nil

	for i = v2, #list do
		discoverKeys(data, list[i], 0, v3)
	end

	resize(data, #list)

	if v3 then
		for _, v4 in v3 do
			local pathExist = data.PathExists[v4.Path]

			if not pathExist then
				continue
			end

			local internPath = Index.internPath(data, v4.Path, v4.Key)
			data.PathHydrated[internPath] = true
			local atomBitset = data.AtomBitsets[Index.internAtom(data, internPath, nil)]

			for i = 1, data.WordCount do
				atomBitset[i] = bit32.bor(atomBitset[i], pathExist[i])
			end
		end
	end

	for i = v2, #list do
		local v4 = i - 1
		data.BitToItemConfig[i] = list[i]
		data.ItemIdToBit[list[i].Index.ItemId] = v4
		indexItem(data, list[i], 0, v4)
	end
end

function Index.load(data, list)
	if data.Version ~= 3 or #data.ItemIds > #list then
		return nil
	end

	for k, itemId in data.ItemIds do
		if list[k].Index.ItemId ~= itemId then
			return nil
		end
	end

	local v2 = Index.new()
	resize(v2, #data.ItemIds)
	v2.NextPathId = data.NextPathId
	v2.NextAtomId = data.NextAtomId
	v2.PathParent = data.PathParent
	v2.PathChildren = data.PathChildren

	if not v2.PathChildren[0] then
		v2.PathChildren[0] = {}
	end

	for k, pathKey in data.PathKeys do
		local v3 = {}

		for _, v4 in pathKey do
			v3[v4] = true
		end

		v2.PathKeys[k] = v3
	end

	for _, v3 in data.PathHydrated do
		v2.PathHydrated[v3] = true
	end

	for k in data.PathExistsBits do
		local pathExists = v2.PathExists
		local pathExistsBit = data.PathExistsBits[k]
		local empty = Index.newEmpty(v2)

		if pathExistsBit then
			for _, v3 in pathExistsBit do
				Index.setBit(empty, v3)
			end
		end

		pathExists[k] = empty
	end

	for k in data.PathExistsWords do
		local pathExists = v2.PathExists
		local pathExistsWord = data.PathExistsWords[k]
		local empty = Index.newEmpty(v2)

		if pathExistsWord then
			for k2, v3 in pathExistsWord do
				empty[k2] = v3
			end
		end

		pathExists[k] = empty
	end

	for k, v3 in data.PathValueToAtom do
		local v4 = v3["\0nil\0"]

		if v4 ~= nil then
			v3["\0nil\0"] = nil
			v3[v] = v4
		end

		v2.PathValueToAtom[k] = v3
	end

	v2.AtomToPath = data.AtomToPath

	for k in data.AtomToPath do
		v2.AtomBitsets[k] = readBitset(v2, data.AtomBits[k], data.AtomWords[k])
	end

	for k, itemId in data.ItemIds do
		v2.BitToItemConfig[k] = list[k]
		v2.ItemIdToBit[itemId] = k - 1
	end

	return v2
end

function Index.snapshot(data)
	local v2 = { 0 }
	local v3 = {
		[0] = ""
	}

	while #v2 > 0 do
		local v4 = table.remove(v2)
		local v5 = data.PathChildren[v4]

		if not v5 then
			continue
		end

		for k, v6 in v5 do
			v3[v6] = `{v3[v4]}.{tostring(k)}`
			table.insert(v2, v6)
		end
	end

	local function bitsOf(p)
		local v4 = {}

		for i = 0, data.BitCount - 1 do
			if Index.testBit(p, i) then
				table.insert(v4, i)
			end
		end

		return table.concat(v4, ",")
	end

	local result = {
		["#bits"] = tostring(data.BitCount)
	}

	for k, v4 in data.PathValueToAtom do
		for k2, v5 in v4 do
			local v6 = k2 == v and "<nil>" or `{typeof(k2)}:{tostring(k2)}`
			result[`atom {v3[k]} = {v6}`] = bitsOf(data.AtomBitsets[v5])
			assert(data.AtomToPath[v5] == k, (`atom {v5} path mismatch`))
		end
	end

	for k, pathExist in data.PathExists do
		result[`exists {v3[k]}`] = bitsOf(pathExist)
	end

	for k in data.PathHydrated do
		result[`hydrated {v3[k]}`] = "true"
	end

	for k, pathKey in data.PathKeys do
		local v4 = {}

		for k2 in pathKey do
			table.insert(v4, (tostring(k2)))
		end

		table.sort(v4)
		result[`keys {v3[k]}`] = table.concat(v4, ",")
	end

	return result
end

function Index.serialize(data)
	local v2 = { "-- DO NOT EDIT, GENERATED DURING BUILD WORKFLOW (scripts/build/data/bake-item-config.lune.luau)", [[

return {
]], (`\tVersion = {3},\n`) }
	local itemIds = {}

	for i = 1, data.BitCount do
		table.insert(itemIds, data.BitToItemConfig[i].Index.ItemId)
	end

	table.insert(v2, (`\tItemIds = \{ {table.concat(itemIds, ", ")} },\n`))
	table.insert(v2, (`\tNextPathId = {data.NextPathId},\n`))
	table.insert(v2, (`\tNextAtomId = {data.NextAtomId},\n`))
	table.insert(v2, "\tPathParent = {\n")

	for i = 1, data.NextPathId do
		table.insert(v2, (`\t\t[{i}] = {data.PathParent[i]},\n`))
	end

	table.insert(v2, [[
	},
	PathChildren = {
]])

	for i = 0, data.NextPathId do
		local v3 = data.PathChildren[i]

		if not (v3 ~= nil and next(v3) ~= nil) then
			continue
		end

		table.insert(v2, (`\t\t[{i}] = \{\n`))

		for _, v4 in sortedKeys(v3) do
			table.insert(v2, (`\t\t\t{`[{formatValue(v4)}]`} = {v3[v4]},\n`))
		end

		table.insert(v2, "\t\t},\n")
	end

	table.insert(v2, [[
	},
	PathKeys = {
]])

	for i = 0, data.NextPathId do
		local pathKey = data.PathKeys[i]

		if pathKey == nil then
			continue
		end

		local v3 = {}

		for _, v4 in sortedKeys(pathKey) do
			table.insert(v3, formatValue(v4))
		end

		table.insert(v2, (`\t\t[{i}] = \{ {table.concat(v3, ", ")} },\n`))
	end

	table.insert(v2, "\t},\n")
	local v3 = {}

	for i = 0, data.NextPathId do
		if data.PathHydrated[i] then
			table.insert(v3, i)
		end
	end

	table.insert(v2, (`\tPathHydrated = \{ {table.concat(v3, ", ")} },\n`))
	local v4 = {}
	local v5 = {}

	for i = 0, data.NextPathId do
		local pathExist = data.PathExists[i]

		if pathExist then
			writeBitset(data, i, pathExist, v4, v5)
		end
	end

	table.insert(v2, (`\tPathExistsBits = \{\n{table.concat(v4)}\t},\n`))
	table.insert(v2, (`\tPathExistsWords = \{\n{table.concat(v5)}\t},\n`))
	table.insert(v2, "\tPathValueToAtom = {\n")

	for i = 0, data.NextPathId do
		local v6 = data.PathValueToAtom[i]

		if v6 == nil then
			continue
		end

		table.insert(v2, (`\t\t[{i}] = \{\n`))

		for _, v7 in sortedKeys(v6) do
			table.insert(v2, (`\t\t\t{`[{formatValue(v7)}]`} = {v6[v7]},\n`))
		end

		table.insert(v2, "\t\t},\n")
	end

	table.insert(v2, "\t},\n")
	table.insert(v2, "\tAtomToPath = {\n")
	local v6 = {}
	local v7 = {}

	for i = 1, data.NextAtomId do
		table.insert(v2, (`\t\t[{i}] = {data.AtomToPath[i]},\n`))
		writeBitset(data, i, data.AtomBitsets[i], v6, v7)
	end

	table.insert(v2, "\t},\n")
	table.insert(v2, (`\tAtomBits = \{\n{table.concat(v6)}\t},\n`))
	table.insert(v2, (`\tAtomWords = \{\n{table.concat(v7)}\t},\n`))
	table.insert(v2, "}\n")
	return table.concat(v2)
end

return Index