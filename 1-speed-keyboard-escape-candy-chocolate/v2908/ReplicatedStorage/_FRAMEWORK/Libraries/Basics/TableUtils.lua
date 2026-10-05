local TableUtils = {}
local HttpService = game:GetService("HttpService")
local random = Random.new()
local Sync

Sync = function(p, item)
	assert(type(p) == "table", "First argument must be a table")
	assert(type(item) == "table", "Second argument must be a table")
	local clone = table.clone(p)

	for k, v in pairs(clone) do
		local item2 = item[k]

		if item2 == nil then
			clone[k] = nil
		elseif type(v) == type(item2) then
			if type(v) == "table" then
				clone[k] = Sync(v, item2)
			end
		elseif type(item2) == "table" then
			local DeepCopy
			local DeepCopy2 = DeepCopy

			DeepCopy = function(item3)
				local clone2 = table.clone(item3)

				for k2, v2 in clone2 do
					if type(v2) == "table" then
						clone2[k2] = DeepCopy2(v2)
					end
				end

				return clone2
			end

			clone[k] = DeepCopy(item2)
		else
			clone[k] = item2
		end
	end

	for k, item2 in pairs(item) do
		if clone[k] ~= nil then
			continue
		end

		if type(item2) == "table" then
			local DeepCopy
			local DeepCopy2 = DeepCopy

			DeepCopy = function(item3)
				local clone2 = table.clone(item3)

				for k2, v in clone2 do
					if type(v) == "table" then
						clone2[k2] = DeepCopy2(v)
					end
				end

				return clone2
			end

			clone[k] = DeepCopy(item2)
		else
			clone[k] = item2
		end
	end

	return clone
end

local Reconcile

Reconcile = function(p, item)
	assert(type(p) == "table", "First argument must be a table")
	assert(type(item) == "table", "Second argument must be a table")
	local clone = table.clone(p)

	for k, item2 in item do
		local v = p[k]

		if v == nil then
			if type(item2) == "table" then
				local DeepCopy
				local DeepCopy2 = DeepCopy

				DeepCopy = function(item3)
					local clone2 = table.clone(item3)

					for k2, v2 in clone2 do
						if type(v2) == "table" then
							clone2[k2] = DeepCopy2(v2)
						end
					end

					return clone2
				end

				clone[k] = DeepCopy(item2)
			else
				clone[k] = item2
			end
		elseif type(v) == "table" then
			if type(item2) == "table" then
				clone[k] = Reconcile(v, item2)
			else
				local DeepCopy
				local DeepCopy2 = DeepCopy

				DeepCopy = function(p2)
					local clone2 = table.clone(p2)

					for k2, v2 in clone2 do
						if type(v2) == "table" then
							clone2[k2] = DeepCopy2(v2)
						end
					end

					return clone2
				end

				clone[k] = DeepCopy(v)
			end
		end
	end

	return clone
end

local function Map(list, callback)
	assert(type(list) == "table", "First argument must be a table")
	assert(type(callback) == "function", "Second argument must be a function")
	local result = table.create(#list)

	for k, v in list do
		result[k] = callback(v, k, list)
	end

	return result
end

function TableUtils.Copy(p, flag: boolean?)
	if not flag then
		return (table.clone(p))
	end

	local DeepCopy

	DeepCopy = function(p2)
		local clone = table.clone(p2)

		for k, v in clone do
			if type(v) == "table" then
				clone[k] = DeepCopy(v)
			end
		end

		return clone
	end

	return (DeepCopy(p))
end

TableUtils.Sync = Sync
TableUtils.Reconcile = Reconcile

function TableUtils:SwapRemove(p: number)
	local count = #self
	self[p] = self[count]
	self[count] = nil
end

function TableUtils:SwapRemoveFirstValue(p)
	local index = table.find(self, p)

	if index then
		local count = #self
		self[index] = self[count]
		self[count] = nil
	end

	return index
end

TableUtils.Map = Map

function TableUtils.Filter(list, callback)
	assert(type(list) == "table", "First argument must be a table")
	assert(type(callback) == "function", "Second argument must be a function")
	local result = table.create(#list)

	if #list > 0 then
		local count = 0

		for k, v in list do
			if not callback(v, k, list) then
				continue
			end

			count += 1
			result[count] = v
		end

		return result
	else
		for k, v in list do
			if callback(v, k, list) then
				result[k] = v
			end
		end

		return result
	end
end

function TableUtils.Reduce(list, callback, p)
	assert(type(list) == "table", "First argument must be a table")
	assert(type(callback) == "function", "Second argument must be a function")

	if #list > 0 then
		local v

		if p == nil then
			p = list[1]
			v = 2
		else
			v = 1
		end

		for i = v, #list do
			p = callback(p, list[i], i, list)
		end

		return p
	else
		local v

		if p == nil then
			v = next(list)
			p = v
		end

		for k, v2 in next, list, v do
			p = callback(p, v2, k, list)
		end

		return p
	end
end

function TableUtils.Assign(p, ...)
	local clone = table.clone(p)

	for _, v in { ... } do
		for k, v2 in v do
			clone[k] = v2
		end
	end

	return clone
end

function TableUtils.Extend(p, items)
	local clone = table.clone(p)

	for _, item in items do
		table.insert(clone, item)
	end

	return clone
end

function TableUtils.Reverse(list)
	local count = #list
	local result = table.create(count)

	for i = 1, count do
		result[i] = list[count - i + 1]
	end

	return result
end

function TableUtils.Shuffle(list, object)
	assert(type(list) == "table", "First argument must be a table")
	local clone = table.clone(list)

	if typeof(object) ~= "Random" then
		object = random
	end

	for i = #list, 2, -1 do
		local integer = object:NextInteger(1, i)
		local v = clone[integer]
		local v2 = clone[i]
		clone[i] = v
		clone[integer] = v2
	end

	return clone
end

function TableUtils.Sample(list, value: number, object)
	assert(type(list) == "table", "First argument must be a table")
	assert(type(value) == "number", "Second argument must be a number")
	local count = #list

	if count == 0 then
		return {}
	end

	local clone = table.clone(list)
	local v = table.create(value)

	if typeof(object) ~= "Random" then
		object = random
	end

	local v2 = math.clamp(value, 1, count)

	for i = 1, v2 do
		local integer = object:NextInteger(i, count)
		local v3 = clone[integer]
		local v4 = clone[i]
		clone[i] = v3
		clone[integer] = v4
	end

	table.move(clone, 1, v2, 1, v)
	return v
end

function TableUtils.Flat(list, value: number?)
	local v = type(value) ~= "number" and 1 or value
	local result = table.create(#list)
	local Scan

	Scan = function(items, p: number)
		for _, item in items do
			if type(item) == "table" and p < v then
				Scan(item, p + 1)
			else
				table.insert(result, item)
			end
		end
	end

	Scan(list, 0)
	return result
end

function TableUtils.FlatMap(p, callback)
	local map = Map(p, callback)
	local result = table.create(#map)
	local v2 = 1
	local Scan

	Scan = function(items, p2: number)
		for _, item in items do
			if type(item) == "table" and p2 < v2 then
				Scan(item, p2 + 1)
			else
				table.insert(result, item)
			end
		end
	end

	Scan(map, 0)
	return result
end

function TableUtils.Keys(list)
	local result = table.create(#list)

	for k in list do
		table.insert(result, k)
	end

	return result
end

function TableUtils.Values(list)
	local result = table.create(#list)

	for _, v in list do
		table.insert(result, v)
	end

	return result
end

function TableUtils.Find(items, callback)
	for k, item in items do
		if callback(item, k, items) then
			return item, k
		end
	end

	return nil, nil
end

function TableUtils.Every(items, callback)
	for k, item in items do
		if not callback(item, k, items) then
			return false
		end
	end

	return true
end

function TableUtils.Some(items, callback)
	for k, item in items do
		if callback(item, k, items) then
			return true
		end
	end

	return false
end

function TableUtils.Truncate(list, value: number)
	local count = #list
	local v = math.clamp(value, 1, count)

	if v == count then
		return (table.clone(list))
	end

	return (table.move(list, 1, v, 1, table.create(v)))
end

function TableUtils.Zip(...)
	assert(select("#", ...) > 0, "Must supply at least 1 table")

	local function ZipIteratorArray(items, p: number)
		local v = p + 1
		local result = {}

		for k, item in items do
			local v2 = item[v]

			if v2 == nil then
				return nil, nil
			else
				result[k] = v2
			end
		end

		return v, result
	end

	local function ZipIteratorMap(items, p)
		local result = {}

		for k, item in items do
			local v = next(item, p)

			if v == nil then
				return nil, nil
			else
				result[k] = v
			end
		end

		return p, result
	end

	local v = { ... }

	if #v[1] > 0 then
		return ZipIteratorArray, v, 0
	end

	return ZipIteratorMap, v, nil
end

function TableUtils.Lock(p)
	local Freeze

	Freeze = function(list)
		for k, v in pairs(list) do
			if type(v) == "table" then
				list[k] = Freeze(v)
			end
		end

		return table.freeze(list)
	end

	return Freeze(p)
end

function TableUtils.IsEmpty(items)
	return next(items) == nil
end

function TableUtils.EncodeJSON(p)
	local DeepCopy

	DeepCopy = function(p2)
		local clone = table.clone(p2)

		for k, v in clone do
			if type(v) == "table" then
				clone[k] = DeepCopy(v)
			end
		end

		return clone
	end

	local deepCopy = DeepCopy(p)
	local Explore

	Explore = function(items)
		for k, item in pairs(items) do
			if typeof(item) == "Color3" then
				items[k] = {
					___SerializedType = "ColorHex",
					Hex = item:ToHex()
				}
			elseif typeof(item) == "Vector3" then
				items[k] = {
					___SerializedType = "Vector3",
					X = item.X,
					Y = item.Y,
					Z = item.Z
				}
			elseif typeof(item) == "Vector2" then
				items[k] = {
					___SerializedType = "Vector2",
					X = item.X,
					Y = item.Y
				}
			elseif typeof(item) == "NumberRange" then
				items[k] = {
					___SerializedType = "NumberRange",
					Min = item.Min,
					Max = item.Max
				}
			elseif typeof(item) == "CFrame" then
				local components = {}
				local v4 = #components
				local v5 = { item:GetComponents() }
				table.move(v5, 1, #v5, v4 + 1, components)
				items[k] = {
					___SerializedType = "CFrame",
					Components = components
				}
			elseif typeof(item) == "NumberSequence" then
				local keypoints = {}

				for k2, keypoint in item.Keypoints do
					local _ = k2 - 1
					table.insert(keypoints, { keypoint.Time, keypoint.Value, keypoint.Envelope })
					local _ = #keypoints
				end

				items[k] = {
					___SerializedType = "NumberSequence",
					Keypoints = keypoints
				}
			elseif typeof(item) == "EnumItem" then
				items[k] = {
					___SerializedType = "EnumItem",
					EnumTypeName = tostring(item.EnumType),
					EnumName = item.Name
				}
			elseif type(item) == "table" and getmetatable(item) ~= nil then
				error("SerializeTable: Unsupported type encountered during serialization.")
			elseif typeof(item) == "table" then
				Explore(item)
			end
		end
	end

	if type(deepCopy) == "table" then
		Explore(deepCopy)
	end

	return HttpService:JSONEncode(deepCopy)
end

function TableUtils.DecodeJSON(json: string)
	local jSONDecode = HttpService:JSONDecode(json)
	local Explore

	Explore = function(items)
		for k, item in pairs(items) do
			if type(item) ~= "table" then
				continue
			end

			local ___SerializedType = item.___SerializedType

			if ___SerializedType == "" or not ___SerializedType then
				Explore(item)
			end

			if item.___SerializedType == "Color3" then
				items[k] = Color3.new(item.R, item.G, item.B)
			elseif item.___SerializedType == "ColorHex" then
				items[k] = Color3.fromHex(item.Hex)
			elseif item.___SerializedType == "Vector3" then
				items[k] = Vector3.new(item.X, item.Y, item.Z)
			elseif item.___SerializedType == "Vector2" then
				items[k] = Vector2.new(item.X, item.Y)
			elseif item.___SerializedType == "NumberRange" then
				items[k] = NumberRange.new(item.Min, item.Max)
			elseif item.___SerializedType == "CFrame" then
				items[k] = CFrame.new(unpack(item.Components))
			elseif item.___SerializedType == "NumberSequence" then
				local keypoints = item.Keypoints
				local numberSequenceKeypoints = table.create(#keypoints)

				for k2, keypoint in keypoints do
					local _ = k2 - 1
					numberSequenceKeypoints[k2] = NumberSequenceKeypoint.new(keypoint[1], keypoint[2], keypoint[3])
				end

				items[k] = NumberSequence.new(numberSequenceKeypoints)
			elseif item.___SerializedType == "EnumItem" then
				items[k] = Enum[item.EnumTypeName][item.EnumName]
			end
		end
	end

	Explore(jSONDecode)
	return jSONDecode
end

return TableUtils