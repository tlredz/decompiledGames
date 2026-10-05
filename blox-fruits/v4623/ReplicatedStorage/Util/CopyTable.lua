function deepcopy(items)
	if type(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in next, items, nil do
		result[deepcopy(k)] = deepcopy(item)
	end

	setmetatable(result, deepcopy((getmetatable(items))))
	return result
end

function shallowcopy(items)
	if type(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

return {
	Deep = deepcopy,
	Shallow = shallowcopy
}