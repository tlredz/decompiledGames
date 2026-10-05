local function Keys(items)
	local result = {}

	for k, _ in pairs(items) do
		table.insert(result, k)
	end

	return result
end

return Keys