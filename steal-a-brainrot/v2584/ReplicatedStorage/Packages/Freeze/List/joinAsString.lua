local function joinAsString(list, value: string?)
	return table.concat(list, value or ",")
end

return joinAsString