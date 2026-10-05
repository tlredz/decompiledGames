local function slice(list, value: number?, p: number?)
	local count = #list
	local v = not (value and value < 0) and (value or 1) or count + (value + 1)
	local v2

	if p and p < 0 then
		v2 = count + p
	else
		v2 = p or count
	end

	if v == 1 and v2 == #list then
		return list
	end

	local result = {}
	local v3 = 1

	for i = v, v2 do
		result[v3] = list[i]
		v3 += 1
	end

	return result
end

return slice