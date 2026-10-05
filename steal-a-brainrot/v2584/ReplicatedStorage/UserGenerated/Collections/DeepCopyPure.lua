function DeepCopyPure(items, options)
	if type(items) ~= "table" then
		return items
	end

	assert(not getmetatable(items))
	local v = options or {}
	assert(not v[items])
	v[items] = true
	local result = {}

	for k, item in next, items, nil do
		result[DeepCopyPure(k, v)] = DeepCopyPure(item, v)
	end

	v[items] = nil
	return result
end

return DeepCopyPure