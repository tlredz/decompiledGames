local v = {}
local object = setmetatable({}, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function getInternalMap(p)
	local v2 = object[p]
	assert(v2 ~= nil, "Invalid Map")
	return v2
end

function v.size(p)
	local internalMap = getInternalMap(p) -- equivalent call inferred; original call site unknown
	return #internalMap.orderedKeys
end

function v.set(p, p2, p3)
	assert(p2 ~= nil, "Map does not support nil keys")
	assert(p3 ~= nil, "Map does not support nil values")
	local internalMap = getInternalMap(p) -- equivalent call inferred; original call site unknown

	if internalMap.indexByKey[p2] == nil then
		table.insert(internalMap.orderedKeys, p2)
		internalMap.indexByKey[p2] = #internalMap.orderedKeys
	end

	internalMap.valueByKey[p2] = p3
	return p
end

function v.get(p, p2)
	local internalMap = getInternalMap(p) -- equivalent call inferred; original call site unknown
	return internalMap.valueByKey[p2]
end

function v.has(p, p2)
	local internalMap = getInternalMap(p) -- equivalent call inferred; original call site unknown
	return internalMap.indexByKey[p2] ~= nil
end

function v.delete(p, p2)
	local internalMap = getInternalMap(p) -- equivalent call inferred; original call site unknown
	local v2 = internalMap.indexByKey[p2]

	if v2 == nil then
		return false
	end

	internalMap.indexByKey[p2] = nil
	internalMap.valueByKey[p2] = nil
	table.remove(internalMap.orderedKeys, v2)

	for i = v2, #internalMap.orderedKeys do
		internalMap.indexByKey[internalMap.orderedKeys[i]] = i
	end

	return true
end

function v.clear(p)
	local internalMap = getInternalMap(p) -- equivalent call inferred; original call site unknown
	table.clear(internalMap.orderedKeys)
	table.clear(internalMap.indexByKey)
	table.clear(internalMap.valueByKey)
end

function v.keys(p)
	return table.clone((getInternalMap(p)).orderedKeys)
end

function v.values(p)
	local internalMap = getInternalMap(p) -- equivalent call inferred; original call site unknown
	local result = table.create(#internalMap.orderedKeys)

	for _, orderedKey in internalMap.orderedKeys do
		table.insert(result, internalMap.valueByKey[orderedKey])
	end

	return result
end

function v.entries(p)
	local internalMap = getInternalMap(p) -- equivalent call inferred; original call site unknown
	local result = table.create(#internalMap.orderedKeys)

	for _, orderedKey in internalMap.orderedKeys do
		table.insert(result, {
			key = orderedKey,
			value = internalMap.valueByKey[orderedKey]
		})
	end

	return result
end

function v.forEach(p, callback)
	assert(type(callback) == "function", "Map.forEach requires a callback")
	local internalMap = getInternalMap(p) -- equivalent call inferred; original call site unknown
	local clone = table.clone(internalMap.orderedKeys)

	for _, v2 in clone do
		if internalMap.indexByKey[v2] ~= nil then
			callback(internalMap.valueByKey[v2], v2, p)
		end
	end
end

local function readMapField(_, p: string)
	local v2 = v[p]

	if v2 ~= nil then
		return v2
	end

	error(`Cannot directly read Map field '{p}'`, 2)
end

local function rejectMapWrite(_, p: string, _)
	error(`Cannot directly write Map field '{p}'`, 2)
end

local v2 = {
	__index = readMapField,
	__newindex = rejectMapWrite
}
table.freeze(v2)
return {
	new = function(items)
		local self = setmetatable({}, v2)
		object[self] = {
			orderedKeys = {},
			indexByKey = {},
			valueByKey = {}
		}
		table.freeze(self)

		if items ~= nil then
			for _, item in items do
				v.set(self, item.key, item.value)
			end
		end

		return self
	end
}