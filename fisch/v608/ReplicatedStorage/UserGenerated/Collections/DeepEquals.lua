local DeepEquals

DeepEquals = function(item, items, options)
	if rawequal(item, items) then
		return true
	end

	if type(item) ~= "table" or type(items) ~= "table" then
		return item ~= item and items ~= items
	end

	if rawlen(item) ~= rawlen(items) then
		return false
	end

	local metatable = getmetatable(item)

	if metatable ~= getmetatable(items) then
		return false
	end

	if metatable ~= nil and metatable.__eq then
		return item == items
	end

	local v = options or {}
	v[item] = v[item] or {}
	v[items] = v[items] or {}

	if v[item][items] then
		return true
	end

	v[item][items] = true
	v[items][item] = true

	for k, item2 in next, item, nil do
		local v2 = rawget(items, k)

		if v2 == nil or not DeepEquals(item2, v2, v) then
			return false
		end
	end

	for k, _ in next, items, nil do
		if rawget(item, k) == nil then
			return false
		end
	end

	return true
end

return DeepEquals