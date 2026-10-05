local v = {
	[48] = 0,
	[49] = 1,
	[50] = 2,
	[51] = 3,
	[52] = 4,
	[53] = 5,
	[54] = 6,
	[55] = 7,
	[56] = 8,
	[57] = 9,
	[65] = 10,
	[66] = 11,
	[67] = 12,
	[68] = 13,
	[69] = 14,
	[70] = 15,
	[97] = 10,
	[98] = 11,
	[99] = 12,
	[100] = 13,
	[101] = 14,
	[102] = 15
}

local function HexToBuffer(value: string)
	local count = #value
	assert(count % 2 == 0, "hex length must be even")
	local buf = buffer.create(count // 2)
	local count2 = 0

	for i = 1, count, 2 do
		local v2, v3 = string.byte(value, i, i + 1)
		local v4 = v[v2]

		if not v4 then
			error((`invalid hex at {i}`))
		end

		local v5 = v[v3]

		if not v5 then
			error((`invalid hex at {i + 1}`))
		end

		buffer.writeu8(buf, count2, v4 * 16 + v5)
		count2 += 1
	end

	return buf
end

return HexToBuffer