-- equivalent calls inferred from this helper; original call sites unknown
local function mult(p: number, p2: number)
	return bit32.band(p, 65535) * p2 + bit32.lshift(bit32.band(bit32.rshift(p, 16) * p2, 65535), 16)
end

local function xxhash32(value: string, p: number?)
	local v = p == nil and 0 or bit32.bor(p, 0)
	local count = #value
	local total = 1
	local total2 = 1
	local v2

	if count >= 16 then
		local v3 = v + 2654435761 + 2246822519
		local v4 = v + 2246822519
		local v5 = v - 2654435761

		for _ = 0, count - 16, 16 do
			local v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21 = string.byte(
				value,
				total2,
				total2 + 15
			)
			local v22 = bit32.bor(bit32.lshift(v9, 24), bit32.lshift(v8, 16), bit32.lshift(v7, 8), v6)
			v3 = mult(bit32.lrotate(v3 + mult(v22, 2246822519), 13), 2654435761)
			local v24 = bit32.bor(bit32.lshift(v13, 24), bit32.lshift(v12, 16), bit32.lshift(v11, 8), v10)
			v4 = mult(bit32.lrotate(v4 + mult(v24, 2246822519), 13), 2654435761)
			local v26 = bit32.bor(bit32.lshift(v17, 24), bit32.lshift(v16, 16), bit32.lshift(v15, 8), v14)
			v = mult(bit32.lrotate(v + mult(v26, 2246822519), 13), 2654435761)
			local v28 = bit32.bor(bit32.lshift(v21, 24), bit32.lshift(v20, 16), bit32.lshift(v19, 8), v18)
			v5 = mult(bit32.lrotate(v5 + mult(v28, 2246822519), 13), 2654435761)
			total += 4
			total2 += 16
		end

		v2 = bit32.lrotate(v3, 1) + bit32.lrotate(v4, 7) + bit32.lrotate(v, 12) + bit32.lrotate(v5, 18)
	else
		v2 = bit32.bor(v + 374761393, 0)
	end

	local v3 = bit32.bor(v2 + count, 0)

	for _ = total, count // 4 do
		local v4, v5, v6, v7 = string.byte(value, total2, total2 + 3)
		local v8 = bit32.bor(bit32.lshift(v7, 24), bit32.lshift(v6, 16), bit32.lshift(v5, 8), v4)
		v3 = mult(bit32.lrotate(v3 + mult(v8, 3266489917), 17), 668265263)
		total += 1
		total2 += 4
	end

	for i = -(count % 4), -1 do
		local v4 = string.byte(value, i)
		v3 = mult(bit32.lrotate(v3 + mult(v4, 374761393), 11), 2654435761)
	end

	local v5 = mult(bit32.bxor(v3, (bit32.rshift(v3, 15))), 2246822519) -- equivalent call inferred; original call site unknown
	local v7 = mult(bit32.bxor(v5, (bit32.rshift(v5, 13))), 3266489917) -- equivalent call inferred; original call site unknown
	return (bit32.bxor(v7, (bit32.rshift(v7, 16))))
end

return xxhash32