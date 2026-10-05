local TableUtil = {}

function TableUtil.deepCopy(p, options)
	local clones = options or {}
	assert(clones ~= nil)

	if clones[p] then
		return clones[p]
	end

	local clone = table.clone(p)
	clones[p] = clone

	for k, v in pairs(clone) do
		if typeof(v) == "table" then
			clone[k] = TableUtil.deepCopy(v, clones)
		end
	end

	return clone
end

function TableUtil.deepFreeze(list)
	if not table.isfrozen(list) then
		table.freeze(list)
	end

	for _, v in pairs(list) do
		if typeof(v) == "table" then
			TableUtil.deepFreeze(v)
		end
	end
end

function TableUtil.map(items, callback)
	local result = {}

	for k, item in pairs(items) do
		result[k] = callback(k, item)
	end

	return result
end

function TableUtil.randomize(list, p: number?)
	local random = Random.new(p or tick())
	local v = {}

	for _, v2 in ipairs(list) do
		v[v2] = random:NextNumber()
	end

	table.sort(list, function(a, b)
		return v[a] < v[b]
	end)
end

function TableUtil.deduplicate(list)
	if #list <= 1 then
		return
	end

	local v = 1
	local v2 = {}

	repeat
		local v3 = list[v]

		if v2[v3] then
			table.remove(list, v)
		else
			v2[v3] = true
			v += 1
		end
	until #list < v
end

function TableUtil.keys(items)
	local result = {}

	for k, _ in pairs(items) do
		table.insert(result, k)
	end

	return result
end

function TableUtil.values(items)
	local result = {}

	for _, item in pairs(items) do
		table.insert(result, item)
	end

	return result
end

function TableUtil:reverse()
	local v = {}

	for i = #self, 1, -1 do
		table.insert(v, self[i])
	end

	table.clear(self)

	for i, v2 in ipairs(v) do
		self[i] = v2
	end
end

function TableUtil.merge(p, items)
	local clone = table.clone(p)

	for k, item in pairs(items) do
		clone[k] = item
	end

	return clone
end

function TableUtil.append(list, list2)
	for _, v in ipairs(list2) do
		table.insert(list, v)
	end
end

return TableUtil