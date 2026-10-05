function DeepFreeze(list, options)
	if type(list) ~= "table" then
		return list
	end

	if not table.isfrozen(list) then
		table.freeze(list)
	end

	local v = options or {}

	if v[list] then
		return list
	end

	v[list] = true

	for k, v2 in next, list, nil do
		DeepFreeze(k, v)
		DeepFreeze(v2, v)
	end

	v[list] = nil
	return list
end

return DeepFreeze