require(game.ReplicatedStorage.UserGenerated.IO.Crypto.Hash)
local v = {
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
}
local v2 = table.create(64, 0)

function processBlocks(list, value: string, p: number, p2: number)
	local v3 = v2
	local v4 = list[1]
	local v5 = list[2]
	local v6 = list[3]
	local v7 = list[4]
	local v8 = list[5]
	local v9 = list[6]
	local v10 = list[7]
	local v11 = list[8]

	for i = p, p2, 64 do
		local v12 = i

		for i2 = 1, 16 do
			local v13, v14, v15, v16 = string.byte(value, v12, v12 + 3)
			v3[i2] = bit32.bor(bit32.lshift(v13, 24), bit32.lshift(v14, 16), bit32.lshift(v15, 8), v16)
			v12 += 4
		end

		for i2 = 17, 64 do
			local v13 = v3[i2 - 2]
			local v14 = v3[i2 - 15]
			v3[i2] = bit32.bxor(bit32.rrotate(v13, 17), bit32.rrotate(v13, 19), (bit32.rshift(v13, 10))) + v3[i2 - 7] + bit32.bxor(
				bit32.rrotate(v14, 7),
				bit32.rrotate(v14, 18),
				(bit32.rshift(v14, 3))
			) + v3[i2 - 16]
		end

		local v13 = v7
		local v14 = v4
		local v15 = v5
		local v16 = v6
		local v17 = v10
		local v18 = v9
		local v19 = v11
		local v20 = v8

		for i2 = 1, 64 do
			local v21 = v19 + bit32.bxor(bit32.rrotate(v20, 6), bit32.rrotate(v20, 11), (bit32.rrotate(v20, 25))) + bit32.band(
				v20,
				v18
			) + bit32.band(bit32.bnot(v20), v17) + v[i2] + v3[i2]
			local v22 = bit32.band(v16, v15) + bit32.band(v14, (bit32.bxor(v16, v15))) + bit32.bxor(
				bit32.rrotate(v14, 2),
				bit32.rrotate(v14, 13),
				(bit32.rrotate(v14, 22))
			)
			local v23 = v13 + v21
			v13 = v16
			v16 = v15
			v15 = v14
			v14 = v21 + v22
			v19 = v17
			v17 = v18
			v18 = v20
			v20 = v23
		end

		v4 = bit32.bor(v14 + v4, 0)
		v5 = bit32.bor(v15 + v5, 0)
		v6 = bit32.bor(v16 + v6, 0)
		v7 = bit32.bor(v13 + v7, 0)
		v8 = bit32.bor(v20 + v8, 0)
		v9 = bit32.bor(v18 + v9, 0)
		v10 = bit32.bor(v17 + v10, 0)
		v11 = bit32.bor(v19 + v11, 0)
	end

	list[1] = v4
	list[2] = v5
	list[3] = v6
	list[4] = v7
	list[5] = v8
	list[6] = v9
	list[7] = v10
	list[8] = v11
end

function sha256(value: string)
	local v3 = {
		1779033703,
		3144134277,
		1013904242,
		2773480762,
		1359893119,
		2600822924,
		528734635,
		1541459225
	}
	local count = #value
	local v4 = count % 64

	if count >= 64 then
		processBlocks(v3, value, 1, count - v4)
	end

	local v5 = bit32.band(v4 + 32, 4294967232)
	local v6 = {
		v4 == 0 and "" or string.sub(value, -v4),
		"\128",
		string.rep("\0", (v5 - v4 - 9) % 64),
		string.pack(">L", count * 8)
	}
	local joined = table.concat(v6)
	processBlocks(v3, joined, 1, #joined)
	local buf = buffer.create(32)
	buffer.writeu32(buf, 0, (bit32.byteswap(v3[1])))
	buffer.writeu32(buf, 4, (bit32.byteswap(v3[2])))
	buffer.writeu32(buf, 8, (bit32.byteswap(v3[3])))
	buffer.writeu32(buf, 12, (bit32.byteswap(v3[4])))
	buffer.writeu32(buf, 16, (bit32.byteswap(v3[5])))
	buffer.writeu32(buf, 20, (bit32.byteswap(v3[6])))
	buffer.writeu32(buf, 24, (bit32.byteswap(v3[7])))
	buffer.writeu32(buf, 28, (bit32.byteswap(v3[8])))
	return buf
end

local SHA256 = {
	Name = "SHA-256",
	BlockSize = 64,
	OutputSize = 32,
	Digest = function(p)
		return buffer.tostring(sha256(p))
	end,
	DigestBuffer = function(buf)
		return sha256(buffer.tostring(buf))
	end,
	DigestToBuffer = sha256
}
table.freeze(SHA256)
return SHA256