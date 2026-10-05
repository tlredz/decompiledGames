local TableUtil = {}
local random = Random.new()

function TableUtil.iter_backwards(list, _: number?)
	local v = #list + 1
	return function()
		v -= 1

		if v > 0 then
			return v, list[v]
		end

		return nil
	end
end

function TableUtil.pick_random(list, p)
	if #list == 0 then
		return nil
	end

	return list[(p or random):NextInteger(1, #list)]
end

function TableUtil.pick_random_weighted(items, p)
	local total = 0

	for _, item in items do
		total += item
	end

	local v = (p or random):NextNumber() * total

	for k, item in items do
		v -= item

		if v <= 0 then
			return k
		end
	end

	return nil
end

function TableUtil.remove(list, p)
	local index = table.find(list, p)

	if index then
		table.remove(list, index)
	end
end

function TableUtil.count(items)
	local count = 0

	for _, _ in next, items, nil do
		count += 1
	end

	return count
end

function TableUtil:overwrite(items)
	table.clear(self)

	for k, item in next, items, nil do
		self[k] = item
	end
end

function TableUtil.deep_copy(items)
	assert(typeof(items) == "table")
	local result = {}

	for k, item in next, items, nil do
		if typeof(item) == "table" then
			item = TableUtil.deep_copy(item) or item
		end

		result[k] = item
	end

	return result
end

function TableUtil.filter(items, callback)
	local result = {}

	for k, item in next, items, nil do
		if callback(k, item) then
			table.insert(result, item)
		end
	end

	return result
end

function TableUtil.to_dictionary(items)
	local result = {}

	for _, item in next, items, nil do
		result[item] = true
	end

	return result
end

return TableUtil