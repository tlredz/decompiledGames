local Table = {}
local HttpService = game:GetService("HttpService")
local find = table.find
local CopyDictionary

CopyDictionary = function(item)
	assert(type(item) == "table", "First argument must be a table")
	local result = {}

	for k, item2 in pairs(item) do
		if type(item2) == "table" then
			result[k] = CopyDictionary(item2)
		else
			result[k] = item2
		end
	end

	return result
end

local CopyTable

CopyTable = function(list)
	assert(type(list) == "table", "First argument must be a table")
	local result = table.create(#list)

	for k, v in pairs(list) do
		if type(v) == "table" then
			result[k] = CopyTable(v)
		else
			result[k] = v
		end
	end

	return result
end

local function CopyTableShallow(list)
	local result = table.create(#list)

	for k, v in pairs(list) do
		result[k] = v
	end

	return result
end

local Sync

Sync = function(item, item2)
	assert(type(item) == "table", "First argument must be a table")
	assert(type(item2) == "table", "Second argument must be a table")

	for k, item3 in pairs(item) do
		local item4 = item2[k]

		if item4 == nil then
			item[k] = nil
		elseif type(item3) == type(item4) then
			if type(item3) == "table" then
				Sync(item3, item4)
			end
		elseif type(item4) == "table" then
			item[k] = CopyTable(item4)
		else
			item[k] = item4
		end
	end

	for k, item3 in pairs(item2) do
		if item[k] ~= nil then
			continue
		end

		if type(item3) == "table" then
			item[k] = CopyTable(item3)
		else
			item[k] = item3
		end
	end
end

local random = Random.new(os.time())

local function TablePick(value)
	local integer = random:NextInteger(1, #value)
	return value[integer], integer
end

local function TablePickAndRemove(list)
	local integer = random:NextInteger(1, #list)
	local v = list[integer]
	table.remove(list, integer)
	return v
end

local function DictionaryPick(items)
	if not items then
		return
	end

	local v = {}

	for k in pairs(items) do
		v[#v + 1] = k
	end

	local v2 = v[random:NextInteger(1, #v)]
	return items[v2], v2
end

local function GetGictionarySize(items)
	local count = 0

	for _ in pairs(items) do
		count += 1
	end

	return count
end

local function Emtpy(items)
	while next(items) do
		items[next(items)] = nil
	end
end

function Table.PickItemFromList(_, list, value)
	table.sort(list, function(a, b)
		return (a:GetAttribute("Probability") or 1) > (b:GetAttribute("Probability") or 1)
	end)
	local v = {}
	local total = 0
	local v2 = {}

	for _, v3 in pairs(list) do
		local rawProbability = math.max(0, (math.ceil(v3:GetAttribute("Probability") or 1)))

		if v[rawProbability] then
			table.insert(v[rawProbability], v3)
		else
			v[rawProbability] = { v3 }
		end

		local v5 = {
			Value = v[rawProbability],
			RawProbability = rawProbability,
			Probability = rawProbability + total
		}
		v[rawProbability] = v5.Value
		v2[#v2 + 1] = v5
		total += rawProbability
	end

	table.sort(v2, function(a, b)
		return a.Probability < b.Probability
	end)
	local v3 = 0

	for _ = 1, value or 1 do
		local v4 = math.random(0, total)

		if v3 < v4 then
			v3 = v4
		end
	end

	for _, v4 in pairs(v2) do
		if v3 <= v4.Probability then
			return TablePick(v4.Value)
		end
	end
end

function Table.IsDictionary(items)
	if type(items) ~= "table" then
		return false
	end

	local v = nil

	for k in pairs(items) do
		if type(k) ~= "number" then
			return true
		end

		v = k
	end

	return false, v
end

function Table.GetChildrenNames(instance)
	local names = {}

	for _, child in pairs(instance:GetChildren()) do
		names[#names + 1] = child.Name
	end

	return names
end

function Table.FindChildrenSubstring(instance, childName: string)
	local child = instance:FindFirstChild(childName)

	if child then
		return child
	end

	local lower = childName:lower()

	for _, child2 in pairs(instance:GetChildren()) do
		if child2.Name:lower() ~= lower then
			continue
		end

		child = child2
		break
	end

	if not child then
		for _, child2 in pairs(instance:GetChildren()) do
			if child2.Name:sub(1, lower:len()):lower() == lower then
				return child2
			end
		end
	end

	return child
end

function Table.FindDescendantSubstring(folder, childName: string)
	local child = folder:FindFirstChild(childName, true)

	if child then
		return child
	end

	local lower = childName:lower()

	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant.Name:lower() ~= lower then
			continue
		end

		child = descendant
		break
	end

	if not child then
		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant.Name:sub(1, lower:len()):lower() == lower then
				return descendant
			end
		end
	end

	return child
end

function Table.FindSubstring(items, value: string)
	local v = nil

	for _, item in pairs(items) do
		if item ~= value then
			continue
		end

		v = item
		break
	end

	if v then
		return v
	end

	local lower = value:lower()

	for _, item in pairs(items) do
		if item:lower() ~= lower then
			continue
		end

		v = item
		break
	end

	if not v then
		for _, item in pairs(items) do
			if item:sub(1, lower:len()):lower() == lower then
				return item
			end
		end
	end

	return v
end

function Table.CreateDisappearingTable(value: number)
	local v = value or 1
	local v2 = {}
	local v3 = {}
	return (setmetatable({}, {
		__newindex = function(_, p, p2)
			v2[p] = p2
			local now = os.clock()
			v3[p] = now
			task.delay(v, function()
				if v3[p] == now then
					v3[p] = nil
					v2[p] = nil
				end
			end)
		end,
		__index = v2
	}))
end

Table.GetTableRealSize = GetGictionarySize

function Table:DictionaryPickAndRemove()
	local v, v2 = DictionaryPick(self)
	self[v2] = nil
	return v, v2
end

Table.DictionaryPick = DictionaryPick
Table.Empty = Emtpy
Table.Clear = Emtpy
Table.PickAndRemove = TablePickAndRemove
Table.Pick = TablePick
Table.CopyDictionary = CopyDictionary
Table.Copy = CopyTable
Table.CopyShallow = CopyTableShallow
Table.Sync = Sync

function Table:FastRemove(p)
	local count = #self
	self[p] = self[count]
	self[count] = nil
end

function Table:FastRemoveFirstValue(p)
	local index = find(self, p)

	if not index then
		return false, nil
	end

	local count = #self
	self[index] = self[count]
	self[count] = nil
	return true, index
end

function Table.Print(p, value, p2)
	assert(type(p) == "table", "First argument must be a table")
	assert(value == nil or type(value) == "string", "Second argument must be a string or nil")
	local v = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Insert(p3, count)
		v[#v + 1] = (" - "):rep(count) .. p3 .. "\n"
	end

	local function AlphaKeySort(p3, p4)
		return tostring(p3.k) < tostring(p4.k)
	end

	local PrintTable

	PrintTable = function(items, count, p3)
		Insert(p3 .. ":", count - 1) -- equivalent call inferred; original call site unknown
		local v4 = {}
		local v5 = 0
		local v6 = {}

		for k, item in pairs(items) do
			if type(item) == "table" then
				table.insert(v6, {
					k = k,
					v = item
				})
			else
				table.insert(v4, {
					k = k,
					v = "[" .. typeof(item) .. "] " .. tostring(item)
				})
			end

			local v7 = #tostring(k) + 1

			if v5 < v7 then
				v5 = v7
			end
		end

		table.sort(v4, AlphaKeySort)
		table.sort(v6, AlphaKeySort)

		for _, v7 in ipairs(v4) do
			Insert(tostring(v7.k) .. ":" .. (" "):rep(v5 - #tostring(v7.k)) .. v7.v, count) -- equivalent call inferred; original call site unknown
		end

		if p2 then
			for _, v7 in ipairs(v6) do
				PrintTable(v7.v, count + 1, tostring(v7.k) .. (" "):rep(v5 - #tostring(v7.k)) .. " [Table]")
			end
		else
			for _, v7 in ipairs(v6) do
				Insert(tostring(v7.k) .. ":" .. (" "):rep(v5 - #tostring(v7.k)) .. "[Table]", count) -- equivalent call inferred; original call site unknown
			end
		end
	end

	PrintTable(p, 1, value or "TABLE")
	print(table.concat(v, ""))
end

function Table.Map(list, callback)
	assert(type(list) == "table", "First argument must be a table")
	assert(type(callback) == "function", "Second argument must be an array")
	local result = table.create(#list)

	for k, v in pairs(list) do
		result[k] = callback(v, k, list)
	end

	return result
end

function Table.Filter(list, callback)
	assert(type(list) == "table", "First argument must be a table")
	assert(type(callback) == "function", "Second argument must be an array")
	local result = table.create(#list)

	if #list > 0 then
		local count = 0

		for i = 1, #list do
			local v = list[i]

			if not callback(v, i, list) then
				continue
			end

			count += 1
			result[count] = v
		end

		return result
	else
		for k, v in pairs(list) do
			if callback(v, k, list) then
				result[k] = v
			end
		end

		return result
	end
end

function Table.Reduce(items, callback, value)
	assert(type(items) == "table", "First argument must be a table")
	assert(type(callback) == "function", "Second argument must be an array")
	assert(value == nil or type(value) == "number", "Third argument must be a number or nil")
	local v = value or 0

	for k, item in pairs(items) do
		v = callback(v, item, k, items)
	end

	return v
end

function Table:Assign(...)
	for _, v in ipairs({ ... }) do
		for k, v2 in pairs(v) do
			self[k] = v2
		end
	end

	return self
end

Table.IndexOf = find

function Table.Reverse(list)
	local count = #list
	local result = table.create(count)

	for i = 1, count do
		result[i] = list[count - i + 1]
	end

	return result
end

function Table:Shuffle()
	assert(type(self) == "table", "First argument must be a table")
	local random2 = Random.new()

	for i = #self, 2, -1 do
		local integer = random2:NextInteger(1, i)
		local v = self[integer]
		local v2 = self[i]
		self[i] = v
		self[integer] = v2
	end
end

function Table.IsEmpty(items)
	return next(items) == nil
end

function Table.EncodeJSON(p)
	return HttpService:JSONEncode(p)
end

function Table.DecodeJSON(json)
	return HttpService:JSONDecode(json)
end

return Table