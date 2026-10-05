local v = {}
local v2 = {}

for i = 65, 90 do
	table.insert(v, i)
end

for i = 97, 122 do
	table.insert(v, i)
end

table.insert(v, 48)
table.insert(v, 49)
table.insert(v, 50)
table.insert(v, 51)
table.insert(v, 52)
table.insert(v, 53)
table.insert(v, 54)
table.insert(v, 55)
table.insert(v, 56)
table.insert(v, 57)
table.insert(v, 43)
table.insert(v, 47)

for i, v3 in ipairs(v) do
	v2[v3] = i
end

local rshift = bit32.rshift
local lshift = bit32.lshift
local band = bit32.band
local Base64 = {}

function Base64.Encode(value)
	local v3 = 0
	local v4 = {}

	for i = 1, #value, 3 do
		local v5, v6, v7 = string.byte(value, i, i + 2)
		local v8 = rshift(v5, 2)
		local v10 = lshift(band(v5, 3), 4) + rshift(v6 or 0, 4)
		local v12 = lshift(band(v6 or 0, 15), 2) + rshift(v7 or 0, 6)
		local v13 = band(v7 or 0, 63)
		local v14 = v3 + 1
		v4[v14] = v[v8 + 1]
		local v15 = v14 + 1
		v4[v15] = v[v10 + 1]
		local v16 = v15 + 1
		v4[v16] = v6 and v[v12 + 1] or 61
		v3 = v16 + 1
		v4[v3] = v7 and v[v13 + 1] or 61
	end

	local count = 0
	local v5 = {}

	for i = 1, v3, 4096 do
		count += 1
		local v6 = i + 4096 - 1
		v5[count] = string.char(table.unpack(v4, i, v3 < v6 and v3 or v6))
	end

	return table.concat(v5)
end

function Base64.Decode(value)
	local count = 0
	local v3 = {}

	for i = 1, #value, 4 do
		local v4, v5, v6, v7 = string.byte(value, i, i + 3)
		local v8 = v2[v4] - 1
		local v9 = v2[v5] - 1
		local v10 = (v2[v6] or 1) - 1
		local v11 = (v2[v7] or 1) - 1
		local v12 = lshift(v8, 2) + rshift(v9, 4)
		local v14 = lshift(band(v9, 15), 4) + rshift(v10, 2)
		local v16 = lshift(band(v10, 3), 6) + v11
		count += 1
		v3[count] = v12

		if v6 ~= 61 then
			count += 1
			v3[count] = v14
		end

		if v7 == 61 then
			continue
		end

		count += 1
		v3[count] = v16
	end

	local count2 = 0
	local v4 = {}

	for i = 1, count, 4096 do
		count2 += 1
		local v5 = i + 4096 - 1
		v4[count2] = string.char(table.unpack(v3, i, count < v5 and count or v5))
	end

	return table.concat(v4)
end

return Base64