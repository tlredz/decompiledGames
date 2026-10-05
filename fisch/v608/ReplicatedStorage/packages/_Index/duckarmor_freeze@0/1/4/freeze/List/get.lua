local function get(list, value: number, p)
	if type(value) == "number" and value < 0 then
		value = #list + (value + 1)
	end

	return list[value] or p
end

return get