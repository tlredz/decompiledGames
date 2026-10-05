local function new_matrix(p, p2)
	local result = {}

	for i = 0, p do
		result[i] = {}

		for i2 = 0, p2 do
			result[i][i2] = 0
		end
	end

	return result
end

local function levenshtein_distance(value: string, value2: string)
	local v = string.len(value)
	local v2 = string.len(value2)

	if v == 0 then
		return v2
	end

	if v2 == 0 then
		return v
	end

	if value == value2 then
		return 0
	end

	local v3 = new_matrix(v, v2)

	for i = 1, v do
		v3[i][0] = i
	end

	for i = 1, v2 do
		v3[0][i] = i
	end

	for i = 1, v do
		for i2 = 1, v2 do
			local v4 = string.byte(value, i) == string.byte(value2, i) and 0 or 1
			local v5 = v3[i - 1][i2] + 1
			local v6 = v3[i][i2 - 1] + 1
			local v7 = v3[i - 1][i2 - 1] + v4
			v3[i][i2] = math.min(v6, v5, v7)
		end
	end

	return v3[v][v2], v3
end

return levenshtein_distance