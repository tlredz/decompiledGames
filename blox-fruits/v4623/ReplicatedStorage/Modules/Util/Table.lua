local Table = {
	shuffle = function(list)
		for i = #list, 2, -1 do
			local v = math.random(i)
			local v2 = list[v]
			local v3 = list[i]
			list[i] = v2
			list[v] = v3
		end

		return list
	end,
	append = function(list, items)
		for _, item in pairs(items) do
			list[#list + 1] = item
		end

		return list
	end,
	merge = function(items, items2)
		local result = {}

		for k, item in pairs(items) do
			result[k] = item
		end

		for k, item in pairs(items2) do
			result[k] = item
		end

		return result
	end,
	reverse = function(list)
		local result = {}

		for i = #list, 1, -1 do
			table.insert(result, list[i])
		end

		return result
	end,
	values = function(items)
		local result = {}

		for _, item in pairs(items) do
			table.insert(result, item)
		end

		return result
	end,
	keys = function(items)
		local result = {}

		for k, _ in pairs(items) do
			table.insert(result, k)
		end

		return result
	end,
	mergeLists = function(items, items2)
		local result = {}

		for _, item in pairs(items) do
			table.insert(result, item)
		end

		for _, item in pairs(items2) do
			table.insert(result, item)
		end

		return result
	end,
	swapKeyValue = function(items)
		local result = {}

		for k, item in pairs(items) do
			result[item] = k
		end

		return result
	end,
	toList = function(items)
		local result = {}

		for _, item in pairs(items) do
			table.insert(result, item)
		end

		return result
	end,
	count = function(items)
		local count = 0

		for _, _ in pairs(items) do
			count += 1
		end

		return count
	end,
	copy = table.clone
}

function Table.deepCopy(items, options)
	local v = options or {}

	if v[items] then
		return v[items]
	end

	if type(items) ~= "table" then
		return items
	end

	local copiesByCopy = {}
	v[items] = copiesByCopy

	for k, item in pairs(items) do
		copiesByCopy[Table.deepCopy(k, v)] = Table.deepCopy(item, v)
	end

	return (setmetatable(copiesByCopy, Table.deepCopy(getmetatable(items), v)))
end

function Table:deepOverwrite(items)
	for k, item in pairs(items) do
		if type(self[k]) == "table" and type(item) == "table" then
			self[k] = Table.deepOverwrite(self[k], item)
		else
			self[k] = item
		end
	end

	return self
end

function Table.getIndex(items, p)
	assert(p ~= nil, "Needle cannot be nil")

	for k, item in pairs(items) do
		if p == item then
			return k
		end
	end

	return nil
end

function Table.stringify(items, count, p)
	local v = p or tostring(items)
	local v2 = count or 0

	for k, item in pairs(items) do
		local v3 = "\n" .. string.rep("  ", v2) .. tostring(k) .. ": "

		if type(item) == "table" then
			local v4 = v .. v3
			v = Table.stringify(item, v2 + 1, v4)
		else
			v ..= v3 .. tostring(item)
		end
	end

	return v
end

function Table.contains(items, p)
	for _, item in pairs(items) do
		if item == p then
			return true
		end
	end

	return false
end

function Table:overwrite(items)
	for k, item in pairs(items) do
		self[k] = item
	end

	return self
end

function Table.take(list, p)
	local result = {}

	for i = 1, math.min(#list, p) do
		result[i] = list[i]
	end

	return result
end

local function errorOnIndex(_, p)
	error(("Bad index %q"):format((tostring(p))), 2)
end

local v = {
	__index = errorOnIndex,
	__newindex = errorOnIndex
}

function Table.readonly(p)
	return (setmetatable(p, v))
end

function Table.deepReadonly(items)
	for _, item in pairs(items) do
		if type(item) == "table" then
			Table.deepReadonly(item)
		end
	end

	return Table.readonly(items)
end

return Table