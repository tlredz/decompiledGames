function DeepFreezeUnsafe(list)
	if type(list) ~= "table" then
		return list
	end

	if not table.isfrozen(list) then
		table.freeze(list)
	end

	for k, v in next, list, nil do
		DeepFreezeUnsafe(k)
		DeepFreezeUnsafe(v)
	end

	return list
end

return DeepFreezeUnsafe