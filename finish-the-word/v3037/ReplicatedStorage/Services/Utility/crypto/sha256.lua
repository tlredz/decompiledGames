local v = string.rep("%08x", 8)
local buf = buffer.create(256)

for i, value in ipairs({
	1116352408,
	1899447441,
	3049323471,
	3921009573,
	961987163,
	1508970993,
	2453635748,
	2870763221,
	3624381080,
	310598401,
	607225278,
	1426881987,
	1925078388,
	2162078206,
	2614888103,
	3248222580,
	3835390401,
	4022224774,
	264347078,
	604807628,
	770255983,
	1249150122,
	1555081692,
	1996064986,
	2554220882,
	2821834349,
	2952996808,
	3210313671,
	3336571891,
	3584528711,
	113926993,
	338241895,
	666307205,
	773529912,
	1294757372,
	1396182291,
	1695183700,
	1986661051,
	2177026350,
	2456956037,
	2730485921,
	2820302411,
	3259730800,
	3345764771,
	3516065817,
	3600352804,
	4094571909,
	275423344,
	430227734,
	506948616,
	659060556,
	883997877,
	958139571,
	1322822218,
	1537002063,
	1747873779,
	1955562222,
	2024104815,
	2227730452,
	2361852424,
	2428436474,
	2756734187,
	3204031479,
	3329325298
}) do
	buffer.writeu32(buf, (i - 1) * 4, value)
end

local function PreProcess(buf2: buffer)
	local v2 = buffer.len(buf2)
	local v3 = -(v2 + 9) % 64
	local v4 = v2 + 1 + v3 + 8
	local buf3 = buffer.create(v4)
	buffer.copy(buf3, 0, buf2)
	buffer.writeu8(buf3, v2, 128)
	local v5 = v2 * 8

	for i = 7, 0, -1 do
		local v6 = v5 % 256
		buffer.writeu8(buf3, i + v2 + 1 + v3, v6)
		v5 = (v5 - v6) / 256
	end

	return buf3, v4
end

local buf2 = buffer.create(256)

local function DigestBlocks(buf3: buffer, p: number)
	local v2 = buf2
	local v3 = buf
	local v4 = 1779033703
	local v5 = 3144134277
	local v6 = 1013904242
	local v7 = 2773480762
	local v8 = 1359893119
	local v9 = 2600822924
	local v10 = 528734635
	local v11 = 1541459225

	for i = 0, p - 1, 64 do
		for i2 = 0, 60, 4 do
			buffer.writeu32(v2, i2, (bit32.byteswap((buffer.readu32(buf3, i + i2)))))
		end

		for i2 = 64, 252, 4 do
			local v12 = buffer.readu32(v2, i2 - 60)
			local v13 = bit32.bxor(bit32.rrotate(v12, 7), bit32.rrotate(v12, 18), (bit32.rshift(v12, 3)))
			local v14 = buffer.readu32(v2, i2 - 8)
			local v15 = bit32.bxor(bit32.rrotate(v14, 17), bit32.rrotate(v14, 19), (bit32.rshift(v14, 10)))
			local v16 = buffer.readu32(v2, i2 - 28)
			buffer.writeu32(v2, i2, buffer.readu32(v2, i2 - 64) + v13 + v16 + v15)
		end

		local v12 = v11
		local v13 = v10
		local v14 = v9
		local v15 = v8
		local v16 = v7
		local v17 = v6
		local v18 = v5
		local v19 = v4

		for i2 = 0, 252, 4 do
			local v20 = bit32.bxor(bit32.rrotate(v8, 6), bit32.rrotate(v8, 11), (bit32.rrotate(v8, 25)))
			local v21 = bit32.bxor(bit32.band(v8, v9), (bit32.band(bit32.bnot(v8), v10)))
			local v22 = v11 + v20 + v21 + buffer.readu32(v3, i2) + buffer.readu32(v2, i2)
			local v23 = v7 + v22
			local v24 = bit32.bxor(bit32.rrotate(v4, 2), bit32.rrotate(v4, 13), (bit32.rrotate(v4, 22)))
			local v25 = bit32.bxor(bit32.band(v4, v5), bit32.band(v4, v6), (bit32.band(v5, v6)))
			v7 = v6
			v6 = v5
			v5 = v4
			v4 = v22 + v24 + v25
			v11 = v10
			v10 = v9
			v9 = v8
			v8 = v23
		end

		v4 = bit32.bor(v4 + v19, 0)
		v5 = bit32.bor(v5 + v18, 0)
		v6 = bit32.bor(v6 + v17, 0)
		v7 = bit32.bor(v7 + v16, 0)
		v8 = bit32.bor(v8 + v15, 0)
		v9 = bit32.bor(v9 + v14, 0)
		v10 = bit32.bor(v10 + v13, 0)
		v11 = bit32.bor(v11 + v12, 0)
	end

	return v4, v5, v6, v7, v8, v9, v10, v11
end

local function SHA256(buf3: buffer, buf4: buffer?)
	if buf4 and buffer.len(buf4) > 0 then
		local buf5 = buffer.create(buffer.len(buf3) + buffer.len(buf4))
		buffer.copy(buf5, 0, buf3)
		buffer.copy(buf5, buffer.len(buf3), buf4)
		buf3 = buf5
	end

	local buf5, v2 = PreProcess(buf3)
	local v3, v4, v5, v6, v7, v8, v9, v10 = DigestBlocks(buf5, v2)
	local buf6 = buffer.create(32)
	buffer.writeu32(buf6, 0, v3)
	buffer.writeu32(buf6, 4, v4)
	buffer.writeu32(buf6, 8, v5)
	buffer.writeu32(buf6, 12, v6)
	buffer.writeu32(buf6, 16, v7)
	buffer.writeu32(buf6, 20, v8)
	buffer.writeu32(buf6, 24, v9)
	buffer.writeu32(buf6, 28, v10)
	return string.format(v, v3, v4, v5, v6, v7, v8, v9, v10), buf6
end

return SHA256