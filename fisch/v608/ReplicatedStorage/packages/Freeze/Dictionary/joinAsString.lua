local function joinAsString(items, value: string?)
	local v = {}

	for k, item in items do
		table.insert(v, string.format("%s=%s", tostring(k), (tostring(item))))
	end

	return table.concat(v, value or ",")
end

return joinAsString