function DeepCopyWithMetatables(items, options)
	if type(items) ~= "table" then
		return items
	end

	local v = options or {}
	local v2 = v[items]

	if v2 then
		return v2
	end

	local result = {}
	v[items] = result

	for k, item in next, items, nil do
		result[DeepCopyWithMetatables(k, v)] = DeepCopyWithMetatables(item, v)
	end

	local metatable = getmetatable(items)

	if metatable then
		setmetatable(result, metatable)
	end

	return result
end

return DeepCopyWithMetatables