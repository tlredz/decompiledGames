require(game.ReplicatedStorage.UserGenerated.IO.Crypto.Hash)
local v = table.create(80, 0)

function processBlocks(list, value: string, p: number, p2: number)
	local v2 = v
	local v3 = list[1]
	local v4 = list[2]
	local v5 = list[3]
	local v6 = list[4]
	local v7 = list[5]

	for i = p, p2, 64 do
		local v8 = i

		for i2 = 1, 16 do
			local v9, v10, v11, v12 = string.byte(value, v8, v8 + 3)
			v2[i2] = bit32.bor(bit32.lshift(v9, 24), bit32.lshift(v10, 16), bit32.lshift(v11, 8), v12)
			v8 += 4
		end

		for i2 = 17, 80 do
			v2[i2] = bit32.lrotate(bit32.bxor(v2[i2 - 3], v2[i2 - 8], v2[i2 - 14], v2[i2 - 16]), 1)
		end

		local v9 = v7
		local v10 = v6
		local v11 = v5
		local v12 = v4
		local v13 = v3

		for i2 = 1, 20 do
			local v14 = bit32.lrotate(v13, 5) + bit32.band(v12, v11) + bit32.band(bit32.bnot(v12), v10) + v9 + 1518500249 + v2[i2]
			v9 = v10
			v10 = v11
			v11 = bit32.lrotate(v12, 30)
			v12 = v13
			v13 = v14
		end

		for i2 = 21, 40 do
			local v14 = bit32.lrotate(v13, 5) + bit32.bxor(v12, v11, v10) + v9 + 1859775393 + v2[i2]
			v9 = v10
			v10 = v11
			v11 = bit32.lrotate(v12, 30)
			v12 = v13
			v13 = v14
		end

		for i2 = 41, 60 do
			local v14 = bit32.lrotate(v13, 5) + bit32.band(v10, v11) + bit32.band(v12, (bit32.bxor(v10, v11))) + v9 + 2400959708 + v2[i2]
			v9 = v10
			v10 = v11
			v11 = bit32.lrotate(v12, 30)
			v12 = v13
			v13 = v14
		end

		for i2 = 61, 80 do
			local v14 = bit32.lrotate(v13, 5) + bit32.bxor(v12, v11, v10) + v9 + 3395469782 + v2[i2]
			v9 = v10
			v10 = v11
			v11 = bit32.lrotate(v12, 30)
			v12 = v13
			v13 = v14
		end

		v3 = bit32.bor(v13 + v3, 0)
		v4 = bit32.bor(v12 + v4, 0)
		v5 = bit32.bor(v11 + v5, 0)
		v6 = bit32.bor(v10 + v6, 0)
		v7 = bit32.bor(v9 + v7, 0)
	end

	list[1] = v3
	list[2] = v4
	list[3] = v5
	list[4] = v6
	list[5] = v7
end

function sha1(value: string)
	local v2 = {
		1732584193,
		4023233417,
		2562383102,
		271733878,
		3285377520
	}
	local count = #value
	local v3 = count % 64

	if count >= 64 then
		processBlocks(v2, value, 1, count - v3)
	end

	local v4 = bit32.band(v3 + 32, 4294967232)
	local v5 = {
		v3 == 0 and "" or string.sub(value, -v3),
		"\128",
		string.rep("\0", (v4 - v3 - 9) % 64),
		string.pack(">L", count * 8)
	}
	local joined = table.concat(v5)
	processBlocks(v2, joined, 1, #joined)
	local buf = buffer.create(20)
	buffer.writeu32(buf, 0, (bit32.byteswap(v2[1])))
	buffer.writeu32(buf, 4, (bit32.byteswap(v2[2])))
	buffer.writeu32(buf, 8, (bit32.byteswap(v2[3])))
	buffer.writeu32(buf, 12, (bit32.byteswap(v2[4])))
	buffer.writeu32(buf, 16, (bit32.byteswap(v2[5])))
	return buf
end

local SHA1 = {
	Name = "SHA-1",
	BlockSize = 64,
	OutputSize = 20,
	Digest = function(p)
		return buffer.tostring(sha1(p))
	end,
	DigestBuffer = function(buf)
		return sha1(buffer.tostring(buf))
	end,
	DigestToBuffer = sha1
}
table.freeze(SHA1)
return SHA1