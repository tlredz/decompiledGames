return function(items)
	local result = {}

	for _, item in items do
		result[item] = true
	end

	return result
end