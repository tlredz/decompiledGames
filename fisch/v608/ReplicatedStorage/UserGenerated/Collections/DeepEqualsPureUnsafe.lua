function DeepEqualsPureUnsafe(items, items2)
	if rawequal(items, items2) then
		return true
	end

	if type(items) ~= "table" or type(items2) ~= "table" then
		return items ~= items and items2 ~= items2
	end

	if not (rawlen(items) == rawlen(items2) and getmetatable(items) == getmetatable(items2)) then
		return false
	end

	for k, item in next, items, nil do
		local v = rawget(items2, k)

		if v == nil or not DeepEqualsPureUnsafe(item, v) then
			return false
		end
	end

	for k, _ in next, items2, nil do
		if rawget(items, k) == nil then
			return false
		end
	end

	return true
end

return DeepEqualsPureUnsafe