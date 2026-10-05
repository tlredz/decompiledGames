local function GetCountryFlagEmoji(value: string)
	local v = string.upper(value)
	local v2 = {}

	for i = 1, #v do
		table.insert(v2, 127397 + utf8.codepoint(v, i, i))
	end

	return utf8.char(table.unpack(v2))
end

return GetCountryFlagEmoji