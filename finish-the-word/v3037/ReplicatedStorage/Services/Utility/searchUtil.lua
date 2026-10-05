local function calculateLevenshteinDistance(string, string2)
	local count = #string
	local count2 = #string2
	local v = {}

	for i = 0, count do
		v[i] = {
			[0] = i
		}
	end

	for i = 0, count2 do
		v[0][i] = i
	end

	for i = 1, count do
		for i2 = 1, count2 do
			local v2 = string:sub(i, i) == string2:sub(i2, i2) and 0 or 1
			v[i][i2] = math.min(v[i - 1][i2] + 1, v[i][i2 - 1] + 1, v[i - 1][i2 - 1] + v2)
		end
	end

	return v[count][count2]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizeString(value)
	return value:lower():gsub("%s+", "")
end

return {
	fuzzySearch = function(list, value, options)
		local v = options or {}
		local threshold = v.threshold or 0.6
		local getSearchableText = v.getSearchableText or function(p)
			return p.name or tostring(p)
		end

		if not value or value == "" then
			return list
		end

		local string = normalizeString(value) -- equivalent call inferred; original call site unknown
		local v2 = {}

		for _, v3 in ipairs(list) do
			local string2 = normalizeString(getSearchableText(v3)) -- equivalent call inferred; original call site unknown
			local score = 1 - calculateLevenshteinDistance(string, string2) / math.max(#string, #string2)
			local v5 = string2:find(string, 1, true) ~= nil

			if not (threshold <= score or v5) then
				continue
			end

			if v5 then
				score = score + 0.5 or score
			end

			table.insert(v2, {
				item = v3,
				score = score
			})
		end

		table.sort(v2, function(a, b)
			return a.score > b.score
		end)
		local result = {}

		for _, v3 in ipairs(v2) do
			table.insert(result, v3.item)
		end

		return result
	end
}