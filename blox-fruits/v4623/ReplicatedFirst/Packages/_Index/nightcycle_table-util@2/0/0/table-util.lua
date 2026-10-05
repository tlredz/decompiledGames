local TableUtil = {}

function TableUtil.deepCopy(items, options)
	local v = options or {}
	assert(v ~= nil)

	if v[items] then
		return v[items]
	end

	local result = {}
	v[items] = result

	for k, item in pairs(items) do
		if type(item) == "table" then
			result[k] = TableUtil.deepCopy(item, v)
		else
			result[k] = item
		end
	end

	return result
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
	local v = {}

	for _, v2 in ipairs(list) do
		v[v2] = true
	end

	local result = {}

	for k, _ in pairs(v) do
		table.insert(result, k)
	end

	return result
end

function TableUtil.keys(items)
	local v = {}

	for k, _ in pairs(items) do
		table.insert(v, k)
	end

	return TableUtil.deduplicate(v)
end

function TableUtil.values(items)
	local v = {}

	for _, item in pairs(items) do
		table.insert(v, item)
	end

	return TableUtil.deduplicate(v)
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