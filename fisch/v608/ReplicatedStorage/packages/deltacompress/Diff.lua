local TypeId = require(script.Parent.TypeId)
local Vlq = require(script.Parent.Vlq)
local isArray = require(script.Parent.isArray)
local Writer = require(script.Parent.Buffer.Writer)
local Serialization = require(script.Parent.Serde.Serialization)
local diffDictionary
local diffArray
local writeDictionaryDiff
local copyDeep

copyDeep = function(items)
	if type(items) ~= "table" then
		return items
	end

	local clone = table.clone(items)

	for k, item in items do
		if type(item) == "table" then
			clone[k] = copyDeep(item)
		end
	end

	return clone
end

local function diffValue(p, p2, p3, p4, p5, p6, flag: boolean)
	if typeof(p) == "table" and typeof(p2) == "table" then
		if isArray(p) and isArray(p2) then
			local v = diffArray(p, p2, flag)

			if not v then
				return false
			end

			p4[p3] = v
			return true
		else
			if isArray(p) or isArray(p2) then
				p6[p3] = p2
				return true
			end

			local v = diffDictionary(p, p2, flag)

			if not v then
				return false
			end

			p5[p3] = v
			return true
		end
	else
		if p == p2 then
			return false
		end

		p6[p3] = p2
		return true
	end
end

diffArray = function(list, list2, flag: boolean)
	if list == list2 then
		return nil
	end

	local removals = 0
	local additions = {}

	if #list > #list2 then
		removals = #list - #list2
	elseif #list2 > #list then
		for i = #list + 1, #list2 do
			table.insert(additions, list2[i])
		end
	end

	local arrayDiffs = {}
	local dictionaryDiffs = {}
	local changes = {}
	local count = 0

	for i = 1, math.min(#list, #list2) do
		if diffValue(list[i], list2[i], i, arrayDiffs, dictionaryDiffs, changes, flag) then
			count += 1
		end
	end

	if not (removals > 0 or #additions > 0 or count > 0) then
		return nil
	end

	if flag then
		for _ = 1, removals do
			table.remove(list, #list)
		end

		for _, v6 in additions do
			table.insert(list, (copyDeep(v6)))
		end

		for k, v6 in changes do
			list[k] = copyDeep(v6)
		end
	end

	return {
		removals = removals,
		additions = additions,
		changes = changes,
		arrayDiffs = arrayDiffs,
		dictionaryDiffs = dictionaryDiffs,
		changeCount = count
	}
end

diffDictionary = function(items, items2, flag: boolean)
	if items == items2 then
		return nil
	end

	local removals = {}
	local count = 0

	for k in items do
		if items2[k] ~= nil then
			continue
		end

		removals[k] = true
		count += 1
	end

	local arrayDiffs = {}
	local dictionaryDiffs = {}
	local changes = {}
	local count2 = 0

	for k, item in items2 do
		if diffValue(items[k], item, k, arrayDiffs, dictionaryDiffs, changes, flag) then
			count2 += 1
		end
	end

	if not (count > 0 or count2 > 0) then
		return nil
	end

	if flag then
		for k in removals do
			items[k] = nil
		end

		for k, v5 in changes do
			items[k] = copyDeep(v5)
		end
	end

	return {
		removals = removals,
		removalCount = count,
		changes = changes,
		arrayDiffs = arrayDiffs,
		dictionaryDiffs = dictionaryDiffs,
		changeCount = count2
	}
end

local writeArrayDiff

writeArrayDiff = function(p, data)
	local removals = data.removals
	local additions = data.additions
	local changeCount = data.changeCount

	-- equivalent calls inferred from this helper; original call sites unknown
	local function writeRemovals()
		Vlq.encode(p, removals)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function writeAdditions()
		Vlq.encode(p, #additions)

		for _, addition in additions do
			Serialization.serialize(p, addition)
		end
	end

	local function writeChanges()
		Vlq.encode(p, changeCount)

		for k, change in data.changes do
			Vlq.encode(p, k)
			Serialization.serialize(p, change)
		end

		for k, arrayDiff in data.arrayDiffs do
			Vlq.encode(p, k)
			writeArrayDiff(p, arrayDiff)
		end

		for k, dictionaryDiff in data.dictionaryDiffs do
			Vlq.encode(p, k)
			writeDictionaryDiff(p, dictionaryDiff)
		end
	end

	if changeCount > 0 then
		if removals > 0 then
			p.writeu8(TypeId.fromType("arrayChangesRemovals"))
			writeRemovals() -- equivalent call inferred; original call site unknown
		elseif #additions > 0 then
			p.writeu8(TypeId.fromType("arrayChangesAdditions"))
			writeAdditions() -- equivalent call inferred; original call site unknown
		else
			p.writeu8(TypeId.fromType("arrayChanges"))
		end

		writeChanges()
	elseif removals > 0 then
		p.writeu8(TypeId.fromType("arrayRemovals"))
		writeRemovals() -- equivalent call inferred; original call site unknown
	elseif #additions > 0 then
		p.writeu8(TypeId.fromType("arrayAdditions"))
		writeAdditions() -- equivalent call inferred; original call site unknown
	end
end

writeDictionaryDiff = function(p, data)
	local removalCount = data.removalCount
	local changeCount = data.changeCount
	local v = TypeId.fromType(removalCount > 0 and changeCount > 0 and "dictionaryRemovalsChanges" or removalCount > 0 and "dictionaryRemovals" or "dictionaryChanges")
	p.writeu8(v)

	if removalCount > 0 then
		Vlq.encode(p, removalCount)
	end

	for k in data.removals do
		Serialization.serialize(p, k)
	end

	if changeCount > 0 then
		Vlq.encode(p, changeCount)
	end

	for k, change in data.changes do
		Serialization.serialize(p, k)
		Serialization.serialize(p, change)
	end

	for k, arrayDiff in data.arrayDiffs do
		Serialization.serialize(p, k)
		writeArrayDiff(p, arrayDiff)
	end

	for k, dictionaryDiff in data.dictionaryDiffs do
		Serialization.serialize(p, k)
		writeDictionaryDiff(p, dictionaryDiff)
	end
end

local Diff = {}

function Diff.diffImmutable(p, p2)
	local v = Writer.new()

	if typeof(p) ~= "table" or typeof(p2) ~= "table" then
		Serialization.serialize(v, p2)
		return v.finish()
	end

	if isArray(p) then
		if isArray(p2) then
			local v2 = diffArray(p, p2, false)

			if v2 == nil then
				return nil
			else
				writeArrayDiff(v, v2)
			end
		else
			Serialization.serialize(v, p2)
		end
	elseif isArray(p2) then
		Serialization.serialize(v, p2)
	else
		local v2 = diffDictionary(p, p2, false)

		if v2 == nil then
			return nil
		else
			writeDictionaryDiff(v, v2)
		end
	end

	return v.finish()
end

function Diff.diffMutable(p, p2)
	local v = Writer.new()

	if typeof(p) ~= "table" or typeof(p2) ~= "table" then
		Serialization.serialize(v, p2)
		return v.finish(), (copyDeep(p2))
	end

	if isArray(p) then
		if isArray(p2) then
			local v2 = diffArray(p, p2, true)

			if v2 == nil then
				return nil
			end

			writeArrayDiff(v, v2)
			return v.finish(), p
		else
			Serialization.serialize(v, p2)
			p = copyDeep(p2)
			return v.finish(), p
		end
	elseif isArray(p2) then
		Serialization.serialize(v, p2)
		p = copyDeep(p2)
		return v.finish(), p
	else
		local v2 = diffDictionary(p, p2, true)

		if v2 == nil then
			return nil
		end

		writeDictionaryDiff(v, v2)
		return v.finish(), p
	end
end

return Diff