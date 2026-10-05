local v = {
	0,
	2,
	2,
	2
}

local function FormatDuration(value: number)
	assert(type(value) == "number")

	if value == 1e999 then
		return "Infinity"
	end

	if value ~= value then
		return "NaN"
	end

	local v2 = math.ceil((math.max(0, value)))
	local v3 = v2 % 60
	local v4 = v2 // 60
	local v5 = v4 % 60
	local v6 = v4 // 60
	local v7 = v6 % 24
	local v8 = {
		v6 // 24,
		v7,
		v5,
		v3
	}
	local count = #v8

	for i, v10 in ipairs(v8) do
		if not (v10 > 0) then
			continue
		end

		count = i
		break
	end

	if count == #v8 then
		return tostring(v3) .. "s"
	end

	local v10 = { (tostring(v8[count])) }

	for i = count + 1, #v8 do
		local v11 = tostring(v8[i])
		local v12 = v[i]

		while #v11 < v12 do
			v11 = "0" .. v11
		end

		table.insert(v10, ":" .. v11)
	end

	return table.concat(v10)
end

return FormatDuration