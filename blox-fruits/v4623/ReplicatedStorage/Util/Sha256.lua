local Bit32 = require(script.Bit32)
local band = Bit32.band
local rrotate = Bit32.rrotate
local bxor = Bit32.bxor
local rshift = Bit32.rshift
local bnot = Bit32.bnot
local string2 = string
local _ = setmetatable
local _ = table
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

local function int32tostring(p)
	local v2 = p % 256
	local v3 = p % 65536
	local v4 = p % 16777216
	local v5 = (p - v4) / 16777216
	local v6 = (v4 - v3) / 65536
	local v7 = (v3 - v2) / 256
	return (string2.char(v5, v6, v7, v2))
end

local function int64tostring(p)
	local v2 = p % 256
	local v3 = p % 65536
	local v4 = p % 16777216
	local v5 = p % 4294967296
	local v6 = p % 1099511627776
	local v7 = p % 281474976710656
	local v8 = p % 7.205759403792794e16
	local v9 = (p - v8) / 7.205759403792794e16
	local v10 = (v8 - v7) / 281474976710656
	local v11 = (v7 - v6) / 1099511627776
	local v12 = (v6 - v5) / 4294967296
	local v13 = (v5 - v4) / 16777216
	local v14 = (v4 - v3) / 65536
	local v15 = (v3 - v2) / 256
	return (string2.char(v9, v10, v11, v12, v13, v14, v15, v2))
end

local function toint32(p, p2)
	local v2 = 0

	for i = p2, p2 + 3 do
		v2 = v2 * 256 + string2.byte(p, i)
	end

	return v2
end

local function preproc(p, p2)
	local v2 = 64 - (p2 + 1 + 8) % 64
	local v3 = 8 * p2
	local v4 = v3 % 256
	local v5 = v3 % 65536
	local v6 = v3 % 16777216
	local v7 = v3 % 4294967296
	local v8 = v3 % 1099511627776
	local v9 = v3 % 281474976710656
	local v10 = v3 % 7.205759403792794e16
	local v11 = (v3 - v10) / 7.205759403792794e16
	local v12 = (v10 - v9) / 281474976710656
	local v13 = (v9 - v8) / 1099511627776
	local v14 = (v8 - v7) / 4294967296
	local v15 = (v7 - v6) / 16777216
	local v16 = (v6 - v5) / 65536
	local v17 = (v5 - v4) / 256
	local char = string2.char(v11, v12, v13, v14, v15, v16, v17, v4)
	return p .. "\128" .. string2.rep("\0", v2) .. char
end

local function initH256(list)
	list[1] = 1779033703
	list[2] = 3144134277
	list[3] = 1013904242
	list[4] = 2773480762
	list[5] = 1359893119
	list[6] = 2600822924
	list[7] = 528734635
	list[8] = 1541459225
end

local function digestblock(p, i, list)
	local v2 = {}

	for i2 = 1, 16 do
		local v3 = i + (i2 - 1) * 4
		local v4 = 0

		for i3 = v3, v3 + 3 do
			v4 = v4 * 256 + string2.byte(p, i3)
		end

		v2[i2] = v4
	end

	for i2 = 17, 64 do
		local v3 = v2[i2 - 15] % 4294967296
		local v4 = bxor(bxor(rrotate(v3, 7), rrotate(v3, 18)), rshift(v3, 3))
		local v5 = v2[i2 - 2] % 4294967296
		local v6 = bxor(bxor(rrotate(v5, 17), rrotate(v5, 19)), rshift(v5, 10))
		v2[i2] = v2[i2 - 16] + v4 + v2[i2 - 7] + v6
	end

	local v3 = list[1]
	local v4 = list[2]
	local v5 = list[3]
	local v6 = list[4]
	local v7 = list[5]
	local v8 = list[6]
	local v9 = list[7]
	local v10 = list[8]

	for i2 = 1, 64 do
		local v11 = bxor(bxor(rrotate(v3, 2), rrotate(v3, 13)), rrotate(v3, 22)) + bxor(
			bxor(band(v3, v4), band(v3, v5)),
			band(v4, v5)
		)
		local v12 = bxor(bxor(rrotate(v7, 6), rrotate(v7, 11)), rrotate(v7, 25))
		local v13 = bxor(band(v7, v8), band(bnot(v7), v9))
		local v14 = v10 + v12 + v13 + v[i2] + v2[i2]
		local v15 = (v6 + v14) % 4294967296
		v6 = v5
		v5 = v4
		v4 = v3
		v3 = (v14 + v11) % 4294967296
		v10 = v9
		v9 = v8
		v8 = v7
		v7 = v15
	end

	list[1] = (list[1] + v3) % 4294967296
	list[2] = (list[2] + v4) % 4294967296
	list[3] = (list[3] + v5) % 4294967296
	list[4] = (list[4] + v6) % 4294967296
	list[5] = (list[5] + v7) % 4294967296
	list[6] = (list[6] + v8) % 4294967296
	list[7] = (list[7] + v9) % 4294967296
	list[8] = (list[8] + v10) % 4294967296
end

return {
	hash = function(list)
		local count = #list
		local v3 = 8 * count
		local v4 = v3 % 256
		local v5 = v3 % 65536
		local v6 = v3 % 16777216
		local v7 = v3 % 4294967296
		local v8 = v3 % 1099511627776
		local v9 = v3 % 281474976710656
		local v10 = v3 % 7.205759403792794e16
		local char = string2.char(
			(v3 - v10) / 7.205759403792794e16,
			(v10 - v9) / 281474976710656,
			(v9 - v8) / 1099511627776,
			(v8 - v7) / 4294967296,
			(v7 - v6) / 16777216,
			(v6 - v5) / 65536,
			(v5 - v4) / 256,
			v4
		)
		local v18 = list .. "\128" .. string2.rep("\0", 64 - (count + 1 + 8) % 64) .. char
		local v19 = {
			1779033703,
			3144134277,
			1013904242,
			2773480762,
			1359893119,
			2600822924,
			528734635,
			1541459225
		}

		for i = 1, #v18, 64 do
			digestblock(v18, i, v19)
		end

		return string2.format("%08x%08x%08x%08x%08x%08x%08x%08x", unpack(v19))
	end
}