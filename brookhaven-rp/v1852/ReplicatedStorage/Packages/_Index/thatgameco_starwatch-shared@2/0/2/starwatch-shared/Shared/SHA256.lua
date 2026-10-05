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
	local v = buffer.len(buf2)
	local v2 = (64 - (v + 9) % 64) % 64
	local v3 = v + 1 + v2 + 8
	local buf3 = buffer.create(v3)
	buffer.copy(buf3, 0, buf2)
	buffer.writeu8(buf3, v, 128)
	local v4 = v * 8

	for i = 7, 0, -1 do
		local v5 = v4 % 256
		buffer.writeu8(buf3, i + v + 1 + v2, v5)
		v4 = (v4 - v5) / 256
	end

	return buf3, v3
end

local buf2 = buffer.create(256)

local function DigestBlock(buf3: buffer, i: number, p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number)
	for i2 = 0, 60, 4 do
		local v = bit32.byteswap((buffer.readu32(buf3, i + i2)))
		buffer.writeu32(buf2, i2, v)
	end

	for i2 = 64, 252, 4 do
		local v = buffer.readu32(buf2, i2 - 60)
		local v2 = buffer.readu32(buf2, i2 - 8)
		local v3 = buffer.readu32(buf2, i2 - 64)
		local v4 = buffer.readu32(buf2, i2 - 28)
		local v5 = bit32.bxor(bit32.rrotate(v, 7), bit32.rrotate(v, 18), (bit32.rshift(v, 3)))
		local v6 = bit32.bxor(bit32.rrotate(v2, 17), bit32.rrotate(v2, 19), (bit32.rshift(v2, 10)))
		buffer.writeu32(buf2, i2, v3 + v5 + v4 + v6)
	end

	local v = p8
	local v2 = p7
	local v3 = p6
	local v4 = p5
	local v5 = p4
	local v6 = p3
	local v7 = p2
	local v8 = p

	for i2 = 0, 252, 4 do
		local v9 = bit32.bxor(bit32.rrotate(p5, 6), bit32.rrotate(p5, 11), (bit32.rrotate(p5, 25)))
		local v10 = bit32.bxor(bit32.band(p5, p6), (bit32.band(bit32.bnot(p5), p7)))
		local v11 = p8 + v9 + v10 + buffer.readu32(buf, i2) + buffer.readu32(buf2, i2)
		local v12 = bit32.bxor(bit32.rrotate(p, 2), bit32.rrotate(p, 13), (bit32.rrotate(p, 22))) + bit32.bxor(
			bit32.band(p, p2),
			bit32.band(p, p3),
			(bit32.band(p2, p3))
		)
		local v13 = p4 + v11
		p4 = p3
		p3 = p2
		p2 = p
		p = v11 + v12
		p8 = p7
		p7 = p6
		p6 = p5
		p5 = v13
	end

	return
		(p + v8) % 4294967296,
		(p2 + v7) % 4294967296,
		(p3 + v6) % 4294967296,
		(p4 + v5) % 4294967296,
		(p5 + v4) % 4294967296,
		(p6 + v3) % 4294967296,
		(p7 + v2) % 4294967296,
		(p8 + v) % 4294967296
end

local v = string.rep("%08x", 8)

local function SHA256(buf3: buffer, buf4: buffer?)
	if buf4 and buffer.len(buf4) > 0 then
		local buf5 = buffer.create(buffer.len(buf3) + buffer.len(buf4))
		buffer.copy(buf5, 0, buf3)
		buffer.copy(buf5, buffer.len(buf3), buf4)
		buf3 = buf5
	end

	local buf5, v2 = PreProcess(buf3)
	local v3 = 1779033703
	local v4 = 3144134277
	local v5 = 1013904242
	local v6 = 2773480762
	local v7 = 1359893119
	local v8 = 2600822924
	local v9 = 528734635
	local v10 = 1541459225

	for i = 0, v2 - 1, 64 do
		v3, v4, v5, v6, v7, v8, v9, v10 = DigestBlock(buf5, i, v3, v4, v5, v6, v7, v8, v9, v10)
	end

	return string.format(v, v3, v4, v5, v6, v7, v8, v9, v10)
end

return SHA256