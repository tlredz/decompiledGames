local v = {}
local object = setmetatable({}, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function getInternalSet(p)
	local v2 = object[p]
	assert(v2 ~= nil, "Invalid Set")
	return v2
end

function v.add(p, p2)
	assert(p2 ~= nil, "Set does not support nil values")
	local internalSet = getInternalSet(p) -- equivalent call inferred; original call site unknown

	if internalSet.indexByValue[p2] ~= nil then
		return p
	end

	table.insert(internalSet.orderedValues, p2)
	internalSet.indexByValue[p2] = #internalSet.orderedValues
	return p
end

function v.delete(p, p2)
	local internalSet = getInternalSet(p) -- equivalent call inferred; original call site unknown
	local v2 = internalSet.indexByValue[p2]

	if v2 == nil then
		return false
	end

	internalSet.indexByValue[p2] = nil
	table.remove(internalSet.orderedValues, v2)

	for i = v2, #internalSet.orderedValues do
		internalSet.indexByValue[internalSet.orderedValues[i]] = i
	end

	return true
end

function v.has(p, p2)
	local internalSet = getInternalSet(p) -- equivalent call inferred; original call site unknown
	return internalSet.indexByValue[p2] ~= nil
end

function v.clear(p)
	local internalSet = getInternalSet(p) -- equivalent call inferred; original call site unknown
	table.clear(internalSet.orderedValues)
	table.clear(internalSet.indexByValue)
end

function v.values(p)
	local internalSet = getInternalSet(p) -- equivalent call inferred; original call site unknown
	local count = 0
	return function()
		count += 1
		return internalSet.orderedValues[count]
	end
end

v.keys = v.values

function v.entries(p)
	local values = v.values(p)
	return function()
		local v2 = values()
		return v2, v2
	end
end

function v.forEach(p, callback)
	assert(type(callback) == "function", "Set.forEach requires a callback")
	local internalSet = getInternalSet(p) -- equivalent call inferred; original call site unknown
	local clone = table.clone(internalSet.orderedValues)

	for _, v2 in clone do
		if internalSet.indexByValue[v2] ~= nil then
			callback(v2, v2, p)
		end
	end
end

local function readSetField(p, p2: string)
	if p2 == "size" then
		return #(getInternalSet(p)).orderedValues
	else
		local v2 = v[p2]

		if v2 ~= nil then
			return v2
		end

		error(`Cannot directly read Set field '{p2}'`, 2)
	end
end

local function rejectSetWrite(_, p: string, _)
	error(`Cannot directly write Set field '{p}'`, 2)
end

local v2 = {
	__index = readSetField,
	__newindex = rejectSetWrite
}
table.freeze(v2)
return {
	new = function(items)
		local self = setmetatable({}, v2)
		object[self] = {
			orderedValues = {},
			indexByValue = {}
		}
		table.freeze(self)

		if items ~= nil then
			for _, item in items do
				v.add(self, item)
			end
		end

		return self
	end
}