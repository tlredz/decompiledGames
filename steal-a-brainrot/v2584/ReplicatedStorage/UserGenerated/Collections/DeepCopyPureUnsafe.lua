function DeepCopyPureUnsafe(items)
	if type(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in next, items, nil do
		result[DeepCopyPureUnsafe(k)] = DeepCopyPureUnsafe(item)
	end

	return result
end

return DeepCopyPureUnsafe