local v = {}

local function foldByte(p: number, p2: number)
	local v2 = bit32.bxor(p, p2)

	for _ = 1, 8 do
		local v3 = bit32.band(v2, 1)
		v2 = bit32.rshift(v2, 1)

		if v3 == 1 then
			v2 = bit32.bxor(v2, 3988292384)
		end
	end

	return v2
end

function v.CRC32(str: string)
	local buffer2 = buffer.fromstring(str)
	local v2 = 4294967295

	for i = 0, buffer.len(buffer2) - 1 do
		v2 = foldByte(v2, buffer.readu8(buffer2, i))
	end

	return (bit32.bnot(v2))
end

function v.PathSeed(...)
	local v2 = table.pack(...)

	for i = 1, v2.n do
		v2[i] = tostring(v2[i])
	end

	return v.CRC32(table.concat(v2, "/", 1, v2.n))
end

return table.freeze(v)