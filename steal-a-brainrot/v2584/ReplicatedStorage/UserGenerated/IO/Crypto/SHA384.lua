require(game.ReplicatedStorage.UserGenerated.IO.Crypto.Hash)
local v = table.create(80, 0)
local v2 = table.create(80, 0)
local v3 = {
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
	3329325298,
	3391569614,
	3515267271,
	3940187606,
	4118630271,
	116418474,
	174292421,
	289380356,
	460393269,
	685471733,
	852142971,
	1017036298,
	1126000580,
	1288033470,
	1501505948,
	1607167915,
	1816402316
}
local v4 = {
	3609767458,
	602891725,
	3964484399,
	2173295548,
	4081628472,
	3053834265,
	2937671579,
	3664609560,
	2734883394,
	1164996542,
	1323610764,
	3590304994,
	4068182383,
	991336113,
	633803317,
	3479774868,
	2666613458,
	944711139,
	2341262773,
	2007800933,
	1495990901,
	1856431235,
	3175218132,
	2198950837,
	3999719339,
	766784016,
	2566594879,
	3203337956,
	1034457026,
	2466948901,
	3758326383,
	168717936,
	1188179964,
	1546045734,
	1522805485,
	2643833823,
	2343527390,
	1014477480,
	1206759142,
	344077627,
	1290863460,
	3158454273,
	3505952657,
	106217008,
	3606008344,
	1432725776,
	1467031594,
	851169720,
	3100823752,
	1363258195,
	3750685593,
	3785050280,
	3318307427,
	3812723403,
	2003034995,
	3602036899,
	1575990012,
	1125592928,
	2716904306,
	442776044,
	593698344,
	3733110249,
	2999351573,
	3815920427,
	3928383900,
	566280711,
	3454069534,
	4000239992,
	1914138554,
	2731055270,
	3203993006,
	320620315,
	587496836,
	1086792851,
	365543100,
	2618297676,
	3409855158,
	4234509866,
	987167468,
	1246189591
}

function lil_sig0(p: number, p2: number)
	return
		bit32.bxor(
			bit32.rshift(p, 1),
			bit32.lshift(p2, 31),
			bit32.rshift(p, 8),
			bit32.lshift(p2, 24),
			(bit32.rshift(p, 7))
		),
		(bit32.bxor(
			bit32.rshift(p2, 1),
			bit32.lshift(p, 31),
			bit32.rshift(p2, 8),
			bit32.lshift(p, 24),
			bit32.rshift(p2, 7),
			(bit32.lshift(p, 25))
		))
end

function lil_sig1(p: number, p2: number)
	return
		bit32.bxor(
			bit32.rshift(p, 19),
			bit32.lshift(p2, 13),
			bit32.lshift(p, 3),
			bit32.rshift(p2, 29),
			(bit32.rshift(p, 6))
		),
		(bit32.bxor(
			bit32.rshift(p2, 19),
			bit32.lshift(p, 13),
			bit32.lshift(p2, 3),
			bit32.rshift(p, 29),
			bit32.rshift(p2, 6),
			(bit32.lshift(p, 26))
		))
end

function big_sig0(p: number, p2: number)
	return
		bit32.bxor(
			bit32.rshift(p, 28),
			bit32.lshift(p2, 4),
			bit32.lshift(p, 30),
			bit32.rshift(p2, 2),
			bit32.lshift(p, 25),
			(bit32.rshift(p2, 7))
		),
		(bit32.bxor(
			bit32.rshift(p2, 28),
			bit32.lshift(p, 4),
			bit32.lshift(p2, 30),
			bit32.rshift(p, 2),
			bit32.lshift(p2, 25),
			(bit32.rshift(p, 7))
		))
end

function big_sig1(p: number, p2: number)
	return
		bit32.bxor(
			bit32.rshift(p, 14),
			bit32.lshift(p2, 18),
			bit32.rshift(p, 18),
			bit32.lshift(p2, 14),
			bit32.lshift(p, 23),
			(bit32.rshift(p2, 9))
		),
		(bit32.bxor(
			bit32.rshift(p2, 14),
			bit32.lshift(p, 18),
			bit32.rshift(p2, 18),
			bit32.lshift(p, 14),
			bit32.lshift(p2, 23),
			(bit32.rshift(p, 9))
		))
end

function processBlocks(list, list2, value: string, p: number, p2: number)
	local v5 = v
	local v6 = v2
	local v7 = list[1]
	local v8 = list[2]
	local v9 = list[3]
	local v10 = list[4]
	local v11 = list[5]
	local v12 = list[6]
	local v13 = list[7]
	local v14 = list[8]
	local v15 = list2[1]
	local v16 = list2[2]
	local v17 = list2[3]
	local v18 = list2[4]
	local v19 = list2[5]
	local v20 = list2[6]
	local v21 = list2[7]
	local v22 = list2[8]

	for i = p, p2, 128 do
		local v23 = i

		for i2 = 1, 16 do
			local v24, v25, v26, v27, v28, v29, v30, v31 = string.byte(value, v23, v23 + 7)
			v5[i2] = bit32.bor(bit32.lshift(v24, 24), bit32.lshift(v25, 16), bit32.lshift(v26, 8), v27)
			v6[i2] = bit32.bor(bit32.lshift(v28, 24), bit32.lshift(v29, 16), bit32.lshift(v30, 8), v31)
			v23 += 8
		end

		for i2 = 17, 80 do
			local v24, v25 = lil_sig0(v5[i2 - 15], v6[i2 - 15])
			local v26, v27 = lil_sig1(v5[i2 - 2], v6[i2 - 2])
			local v28 = v6[i2 - 16] + v25 + v6[i2 - 7] + v27
			v6[i2] = bit32.bor(v28, 0)
			v5[i2] = v5[i2 - 16] + v24 + v5[i2 - 7] + v26 + v28 // 4294967296
		end

		local v24 = v10
		local v25 = v18
		local v26 = v8
		local v27 = v9
		local v28 = v16
		local v29 = v17
		local v30 = v13
		local v31 = v12
		local v32 = v14
		local v33 = v21
		local v34 = v20
		local v35 = v22
		local v36 = v19
		local v37 = v11
		local v38 = v15
		local v39 = v7

		for i2 = 1, 80 do
			local v40, v41 = big_sig0(v39, v38)
			local v42, v43 = big_sig1(v37, v36)
			local v44 = v35 + v43 + bit32.bor(bit32.band(v36, v34), bit32.band(-1 - v36, v33), 0) + v4[i2] + v6[i2]
			local v45 = v32 + v42 + bit32.bor(bit32.band(v37, v31), bit32.band(-1 - v37, v30), 0) + v3[i2] + v5[i2] + v44 // 4294967296
			local v46 = bit32.bor(v44, 0)
			local v47 = v41 + bit32.band(v29, v28) + bit32.band(v38, (bit32.bxor(v29, v28)))
			local v48 = v40 + bit32.band(v27, v26) + bit32.band(v39, (bit32.bxor(v27, v26)))
			local v49 = v46 + v25
			local v50 = v45 + v24 + v49 // 4294967296
			local v51 = bit32.bor(v49, 0)
			local v52 = v46 + v47
			v24 = v27
			v27 = v26
			v26 = v39
			v39 = v45 + v48 + v52 // 4294967296
			v25 = v29
			v29 = v28
			v28 = v38
			v38 = bit32.bor(v52, 0)
			v32 = v30
			v30 = v31
			v31 = v37
			v37 = v50
			v35 = v33
			v33 = v34
			v34 = v36
			v36 = v51
		end

		local v40 = v15 + v38
		v7 = bit32.bor(v7 + v39 + v40 // 4294967296, 0)
		v15 = bit32.bor(v40, 0)
		local v41 = v16 + v28
		v8 = bit32.bor(v8 + v26 + v41 // 4294967296, 0)
		v16 = bit32.bor(v41, 0)
		local v42 = v17 + v29
		v9 = bit32.bor(v9 + v27 + v42 // 4294967296, 0)
		v17 = bit32.bor(v42, 0)
		local v43 = v18 + v25
		v10 = bit32.bor(v10 + v24 + v43 // 4294967296, 0)
		v18 = bit32.bor(v43, 0)
		local v44 = v19 + v36
		v11 = bit32.bor(v11 + v37 + v44 // 4294967296, 0)
		v19 = bit32.bor(v44, 0)
		local v45 = v20 + v34
		v12 = bit32.bor(v12 + v31 + v45 // 4294967296, 0)
		v20 = bit32.bor(v45, 0)
		local v46 = v21 + v33
		v13 = bit32.bor(v13 + v30 + v46 // 4294967296, 0)
		v21 = bit32.bor(v46, 0)
		local v47 = v22 + v35
		v14 = bit32.bor(v14 + v32 + v47 // 4294967296, 0)
		v22 = bit32.bor(v47, 0)
	end

	list[1] = v7
	list2[1] = v15
	list[2] = v8
	list2[2] = v16
	list[3] = v9
	list2[3] = v17
	list[4] = v10
	list2[4] = v18
	list[5] = v11
	list2[5] = v19
	list[6] = v12
	list2[6] = v20
	list[7] = v13
	list2[7] = v21
	list[8] = v14
	list2[8] = v22
end

function sha384(value: string)
	local v5 = {
		3418070365,
		1654270250,
		2438529370,
		355462360,
		1731405415,
		2394180231,
		3675008525,
		1203062813
	}
	local v6 = {
		3238371032,
		914150663,
		812702999,
		4144912697,
		4290775857,
		1750603025,
		1694076839,
		3204075428
	}
	local count = #value

	if count > 1125899906842624 then
		error("cannot calculate the SHA-384 hash of a string longer than 2^50 bytes", 2)
	end

	local v7 = count % 128

	if count >= 128 then
		processBlocks(v5, v6, value, 1, count - v7)
	end

	local v8 = bit32.band(v7 + 64, 4294963200)
	local v9 = {
		v7 == 0 and "" or string.sub(value, -v7),
		"\128",
		string.rep("\0", (v8 - v7 - 17) % 128),
		string.pack(">L", count * 8 / 4294967296),
		string.pack(">L", (bit32.bor(count * 8)))
	}
	local joined = table.concat(v9)
	processBlocks(v5, v6, joined, 1, #joined)
	local buf = buffer.create(48)

	for i = 1, 6 do
		buffer.writeu32(buf, (i - 1) * 8, (bit32.byteswap(v5[i])))
		buffer.writeu32(buf, (i - 1) * 8 + 4, (bit32.byteswap(v6[i])))
	end

	return buf
end

local SHA384 = {
	Name = "SHA-384",
	BlockSize = 128,
	OutputSize = 48,
	Digest = function(p)
		return buffer.tostring(sha384(p))
	end,
	DigestBuffer = function(buf)
		return sha384(buffer.tostring(buf))
	end,
	DigestToBuffer = sha384
}
table.freeze(SHA384)
return SHA384