function DeepEqualsPure(items, items2, options)
	if type(items) == "table" and type(items2) == "table" then
		local v = options or {}

		if v[items] or v[items2] then
			return false
		end

		if rawequal(items, items2) then
			return true
		end

		if not (rawlen(items) == rawlen(items2) and getmetatable(items) == getmetatable(items2)) then
			return false
		end

		v[items] = true
		v[items2] = true

		for k, item in next, items, nil do
			local v2 = rawget(items2, k)

			if v2 == nil or not DeepEqualsPure(item, v2, v) then
				return false
			end
		end

		for k, _ in next, items2, nil do
			if rawget(items, k) == nil then
				return false
			end
		end

		v[items] = nil
		v[items2] = nil
		return true
	elseif rawequal(items, items2) then
		return true
	else
		return items ~= items and items2 ~= items2
	end
end

return DeepEqualsPure