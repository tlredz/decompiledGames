local function Map(items, ...)
	local v = { ... }
	local result = {}

	for k, item in next, items, nil do
		for _, v2 in next, v, nil do
			item = v2(item)
		end

		result[k] = item
	end

	table.freeze(result)
	return result
end

return Map