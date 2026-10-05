local Reader = require(script.Parent.Buffer.Reader)
local Deserialization = require(script.Parent.Serde.Deserialization)
local TypeId = require(script.Parent.TypeId)
local Vlq = require(script.Parent.Vlq)
local isArray = require(script.Parent.isArray)
local applyDictionary
local applyArray

-- equivalent calls inferred from this helper; original call sites unknown
local function deserialize(p)
	local readu8 = p.readu8()
	return Deserialization[TypeId.toType(readu8)](p)
end

local function applyValue(p, type: string, list, flag: boolean)
	local v = Deserialization[type](p)

	if flag or (typeof(list) ~= "table" or typeof(v) ~= "table") then
		return v
	end

	if isArray(v) then
	end

	table.clear(list)

	for k, v2 in v do
		list[k] = v2
	end

	return list
end

local function applyChange(p, p2, p3, p4, flag: boolean)
	local readu8 = p.readu8()
	local type = TypeId.toType(readu8)

	if TypeId.isArrayDiff(readu8) then
		p3[p4] = applyArray(p, type, p2[p4], flag)
	elseif TypeId.isDictionaryDiff(readu8) then
		p3[p4] = applyDictionary(p, type, p2[p4], flag)
	else
		p3[p4] = applyValue(p, type, p2[p4], flag)
	end
end

applyArray = function(p, type: string, list, flag: boolean)
	local v = type == "arrayRemovals" or type == "arrayChangesRemovals"
	local v2 = type == "arrayAdditions" or type == "arrayChangesAdditions"
	local v3

	if type == "arrayRemovals" then
		v3 = false
	else
		v3 = type ~= "arrayAdditions"
	end

	local v4 = not v and 0 or Vlq.decode(p)
	local v5 = not v2 and 0 or Vlq.decode(p)
	local result

	if flag then
		result = table.create(#list - v4 + v5)
	else
		result = list
	end

	if flag then
		table.move(list, 1, #list - v4, 1, result)
	end

	if v and not flag then
		for _ = 1, v4 do
			table.remove(result, #result)
		end
	end

	if v2 then
		for _ = 1, v5 do
			table.insert(result, deserialize(p))
		end
	end

	if v3 then
		for _ = 1, Vlq.decode(p) do
			applyChange(p, list, result, Vlq.decode(p), flag)
		end
	end

	return result
end

applyDictionary = function(p, type: string, p2, flag: boolean)
	local clone

	if flag then
		clone = table.clone(p2)
	else
		clone = p2
	end

	local v = type ~= "dictionaryChanges"
	local v2 = type ~= "dictionaryRemovals"

	if v then
		for _ = 1, Vlq.decode(p) do
			clone[deserialize(p)] = nil
		end
	end

	if not v2 then
		return clone
	end

	for _ = 1, Vlq.decode(p) do
		local v3 = deserialize(p) -- equivalent call inferred; original call site unknown
		applyChange(p, p2, clone, v3, flag)
	end

	return clone
end

local function apply(p, buf: buffer, flag: boolean)
	local v = Reader.new(buf)
	local readu8 = v.readu8()
	local type = TypeId.toType(readu8)

	if TypeId.isDictionaryDiff(readu8) then
		return applyDictionary(v, type, p, flag)
	end

	if TypeId.isArrayDiff(readu8) then
		return applyArray(v, type, p, flag)
	end

	return (applyValue(v, type, p, flag))
end

local Apply = {}

function Apply.applyImmutable(p, buf: buffer)
	return apply(p, buf, true)
end

function Apply.applyMutable(p, buf: buffer)
	return apply(p, buf, false)
end

return Apply