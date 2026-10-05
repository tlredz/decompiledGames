require(game.ReplicatedStorage.UserGenerated.IO.Crypto.Hash)
local v = {
	3614090360,
	3905402710,
	606105819,
	3250441966,
	4118548399,
	1200080426,
	2821735955,
	4249261313,
	1770035416,
	2336552879,
	4294925233,
	2304563134,
	1804603682,
	4254626195,
	2792965006,
	1236535329,
	4129170786,
	3225465664,
	643717713,
	3921069994,
	3593408605,
	38016083,
	3634488961,
	3889429448,
	568446438,
	3275163606,
	4107603335,
	1163531501,
	2850285829,
	4243563512,
	1735328473,
	2368359562,
	4294588738,
	2272392833,
	1839030562,
	4259657740,
	2763975236,
	1272893353,
	4139469664,
	3200236656,
	681279174,
	3936430074,
	3572445317,
	76029189,
	3654602809,
	3873151461,
	530742520,
	3299628645,
	4096336452,
	1126891415,
	2878612391,
	4237533241,
	1700485571,
	2399980690,
	4293915773,
	2240044497,
	1873313359,
	4264355552,
	2734768916,
	1309151649,
	4149444226,
	3174756917,
	718787259,
	3951481745
}
local v2 = {
	7,
	12,
	17,
	22,
	7,
	12,
	17,
	22,
	7,
	12,
	17,
	22,
	7,
	12,
	17,
	22,
	5,
	9,
	14,
	20,
	5,
	9,
	14,
	20,
	5,
	9,
	14,
	20,
	5,
	9,
	14,
	20,
	4,
	11,
	16,
	23,
	4,
	11,
	16,
	23,
	4,
	11,
	16,
	23,
	4,
	11,
	16,
	23,
	6,
	10,
	15,
	21,
	6,
	10,
	15,
	21,
	6,
	10,
	15,
	21,
	6,
	10,
	15,
	21
}
local v3 = table.create(64, 0)

function processBlocks(list, value: string, p: number, p2: number)
	local v4 = v3
	local v5 = list[1]
	local v6 = list[2]
	local v7 = list[3]
	local v8 = list[4]

	for i = p, p2, 64 do
		local v9 = i

		for i2 = 1, 16 do
			local v10, v11, v12, v13 = string.byte(value, v9, v9 + 3)
			v4[i2] = bit32.bor(bit32.lshift(v13, 24), bit32.lshift(v12, 16), bit32.lshift(v11, 8), v10)
			v9 += 4
		end

		local v10 = v5
		local v11 = v6
		local v12 = v8
		local v13 = v7

		for i2 = 0, 15 do
			local v14 = v11 + bit32.lrotate(
				v10 + bit32.bxor(v12, (bit32.band(v11, (bit32.bxor(v13, v12))))) + v[i2 + 1] + v4[i2 + 1],
				v2[i2 + 1]
			)
			v10 = v12
			v12 = v13
			v13 = v11
			v11 = v14
		end

		for i2 = 16, 31 do
			local v14 = v11 + bit32.lrotate(
				v10 + bit32.bxor(v13, (bit32.band(v12, (bit32.bxor(v11, v13))))) + v[i2 + 1] + v4[(i2 * 5 + 1) % 16 + 1],
				v2[i2 + 1]
			)
			v10 = v12
			v12 = v13
			v13 = v11
			v11 = v14
		end

		for i2 = 32, 47 do
			local v14 = v11 + bit32.lrotate(
				v10 + bit32.bxor(v11, v13, v12) + v[i2 + 1] + v4[(i2 * 3 + 5) % 16 + 1],
				v2[i2 + 1]
			)
			v10 = v12
			v12 = v13
			v13 = v11
			v11 = v14
		end

		for i2 = 48, 63 do
			local v14 = v11 + bit32.lrotate(
				v10 + bit32.bxor(v13, (bit32.bor(v11, (bit32.bnot(v12))))) + v[i2 + 1] + v4[i2 * 7 % 16 + 1],
				v2[i2 + 1]
			)
			v10 = v12
			v12 = v13
			v13 = v11
			v11 = v14
		end

		v5 = bit32.bor(v10 + v5)
		v6 = bit32.bor(v11 + v6)
		v7 = bit32.bor(v13 + v7)
		v8 = bit32.bor(v12 + v8)
	end

	list[1] = v5
	list[2] = v6
	list[3] = v7
	list[4] = v8
end

function md5(value: string)
	local v4 = {
		1732584193,
		4023233417,
		2562383102,
		271733878
	}
	local count = #value
	local v5 = count % 64

	if count >= 64 then
		processBlocks(v4, value, 1, count - v5)
	end

	local v6 = bit32.band(v5 + 32, 4294967232)
	local v7 = {
		v5 == 0 and "" or string.sub(value, -v5),
		"\128",
		string.rep("\0", (v6 - v5 - 9) % 64),
		string.pack("<L", count * 8)
	}
	local joined = table.concat(v7)
	processBlocks(v4, joined, 1, #joined)
	local buf = buffer.create(16)
	buffer.writeu32(buf, 0, v4[1])
	buffer.writeu32(buf, 4, v4[2])
	buffer.writeu32(buf, 8, v4[3])
	buffer.writeu32(buf, 12, v4[4])
	return buf
end

local MD5 = {
	Name = "MD5",
	BlockSize = 64,
	OutputSize = 16,
	Digest = function(p)
		return buffer.tostring(md5(p))
	end,
	DigestBuffer = function(buf)
		return md5(buffer.tostring(buf))
	end,
	DigestToBuffer = md5
}
table.freeze(MD5)
return MD5