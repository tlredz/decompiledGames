local createVector = vector.create

local function createHuffmanTable(items)
	local v = table.create(15, 0)
	v[0] = 0

	for _, item in items do
		if item > 0 then
			v[item] = (v[item] or 0) + 1
		end
	end

	local v2 = table.create(15)
	local v3 = 1

	for i = 1, 15 do
		v3 = bit32.lshift(v3 + v[i - 1], 1)
		v2[i] = v3
	end

	local result = {}
	local result2 = {}
	local result3 = {}

	for k, item in items do
		if not (item > 0) then
			continue
		end

		result[v2[item]] = k - 1
		result2[k - 1] = bit32.extract(v2[item], 0, item)
		result3[k - 1] = item
		v2[item] += 1
	end

	return result, result2, result3
end

local v = {
	3,
	4,
	5,
	6,
	7,
	8,
	9,
	10,
	11,
	13,
	15,
	17,
	19,
	23,
	27,
	31,
	35,
	43,
	51,
	59,
	67,
	83,
	99,
	115,
	131,
	163,
	195,
	227,
	258
}
local v2 = {}
local v3 = {}
local v4 = {
	1,
	1,
	1,
	1,
	2,
	2,
	2,
	2,
	3,
	3,
	3,
	3,
	4,
	4,
	4,
	4,
	5,
	5,
	5,
	5,
	0
}
local v5 = {}
local v6 = {
	1,
	2,
	3,
	4,
	5,
	7,
	9,
	13,
	17,
	25,
	33,
	49,
	65,
	97,
	129,
	193,
	257,
	385,
	513,
	769,
	1025,
	1537,
	2049,
	3073,
	4097,
	6145,
	8193,
	12289,
	16385,
	24577
}
local v8 = {
	16,
	17,
	18,
	0,
	8,
	7,
	9,
	6,
	10,
	5,
	11,
	4,
	12,
	3,
	13,
	2,
	14,
	1,
	15
}
local v9 = {
	0,
	0,
	0,
	1,
	1,
	2,
	2,
	3,
	3,
	4,
	4,
	5,
	5,
	6,
	6,
	7,
	7,
	8,
	8,
	9,
	9,
	10,
	10,
	11,
	11,
	12,
	12,
	13,
	13
}

for i = 3, 258 do
	local v10 = nil

	for i2 = #v, 1, -1 do
		if not (v[i2] <= i) then
			continue
		end

		v10 = i2
		break
	end

	v2[i] = 256 + v10
	v3[i] = i - v[v10]
	v5[i] = v4[v10 - 8] or 0
end

local v10 = {}

for i = 1, 1024 do
	local v11 = nil

	for i2 = #v6, 1, -1 do
		if not (v6[i2] <= i) then
			continue
		end

		v11 = i2
		break
	end

	v10[i] = v11
end

local huffmanTable, v11, v12 = createHuffmanTable({
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	9,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
	8,
	8,
	8,
	8,
	8,
	8,
	8,
	8
})
local huffmanTable2, v13, v14 = createHuffmanTable(table.create(32, 5))

-- equivalent calls inferred from this helper; original call sites unknown
local function getStoreSize(p: number)
	return math.ceil(p / 32768) * 5 + p
end

local function getDistIdx(p: number)
	if p < 1025 then
		return v10[p]
	end

	if p < 1537 then
		return 21
	end

	if p < 2049 then
		return 22
	end

	if p < 3073 then
		return 23
	end

	if p < 4097 then
		return 24
	end

	if p < 6145 then
		return 25
	end

	if p < 8193 then
		return 26
	end

	if p < 12289 then
		return 27
	end

	if p < 16385 then
		return 28
	end

	if p < 24577 then
		return 29
	end

	return 30
end

local function adler32(buf: buffer, p: number, p2: number)
	local v15 = 1
	local v16 = 0
	local count = 0

	for i = p, p + p2 - 1 do
		v15 += buffer.readu8(buf, i)
		v16 += v15
		count += 1

		if count ~= 8400000 then
			continue
		end

		v15 %= 65521
		v16 %= 65521
		count = 0
	end

	return (bit32.bor(bit32.lshift(v16 % 65521, 16), v15 % 65521))
end

local Zlib = {}

function Zlib.inflate(buf: buffer, buf2: buffer)
	local v15 = buffer.readu8(buf, 0)
	local v16 = buffer.readu8(buf, 1)
	assert(bit32.extract(v15, 0, 4) == 8, "invalid zlib comp method")
	assert(bit32.extract(v15, 4, 4) <= 7, "invalid zlib window size")
	assert(bit32.extract(v16, 5, 1) == 0, "preset dictionary is not allowed")
	assert(bit32.bor(bit32.lshift(v15, 8), v16) % 31 == 0, "zlib header sum mismatch")
	local total = 2
	local v17 = 0

	local function readBit()
		local v18 = bit32.extract(buffer.readu8(buf, total), v17)
		v17 += 1

		if v17 == 8 then
			v17 = 0
			total += 1
		end

		return v18
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function readBits(bitCount: number)
		local v18 = buffer.readbits(buf, total * 8 + v17, bitCount)
		v17 += bitCount
		total += bit32.rshift(v17, 3)
		v17 = bit32.band(v17, 7)
		return v18
	end

	local function readHuffmanTable(p)
		local v19 = bit32.extract(buffer.readu8(buf, total), v17)
		v17 += 1

		if v17 == 8 then
			v17 = 0
			total += 1
		end

		local v20 = 2 + v19

		while not p[v20] do
			local v21 = 2 * v20
			local v22 = bit32.extract(buffer.readu8(buf, total), v17)
			v17 += 1

			if v17 == 8 then
				v17 = 0
				total += 1
			end

			v20 = v21 + v22
		end

		return p[v20]
	end

	local total2 = 0

	while true do
		local v18 = bit32.extract(buffer.readu8(buf, total), v17)
		v17 += 1

		if v17 == 8 then
			v17 = 0
			total += 1
		end

		local bits = readBits(2) -- equivalent call inferred; original call site unknown
		assert(bits ~= 3, "reserved btype")

		if bits == 0 then
			if v17 > 0 then
				total += 1
				v17 = 0
			end

			local v20 = buffer.readu16(buf, total)
			assert(bit32.bxor(v20, (buffer.readu16(buf, total + 2))) == 65535, "len ~= nlen")
			total += 4
			buffer.copy(buf2, total2, buf, total, v20)
			total2 += v20
			total += v20
		else
			local v20 = huffmanTable
			local v21 = huffmanTable2

			if bits == 2 then
				local v22 = readBits(5) + 257
				local v23 = readBits(5) + 1
				local v24 = readBits(4) + 4
				local v25 = table.create(19, 0)

				for i = 1, v24 do
					local v26 = v8[i] + 1
					v25[v26] = readBits(3)
				end

				local huffmanTable3 = createHuffmanTable(v25)
				local v26 = table.create(v22)
				local v27 = nil

				while true do
					local v29 = bit32.extract(buffer.readu8(buf, total), v17)
					v17 += 1

					if v17 == 8 then
						v17 = 0
						total += 1
					end

					local v30 = 2 + v29

					while not huffmanTable3[v30] do
						local v31 = 2 * v30
						local v32 = bit32.extract(buffer.readu8(buf, total), v17)
						v17 += 1

						if v17 == 8 then
							v17 = 0
							total += 1
						end

						v30 = v31 + v32
					end

					local v31 = huffmanTable3[v30]
					local v32 = 1

					if v31 <= 15 then
						v27 = v31
					elseif v31 == 16 then
						v32 = readBits(2) + 3
					elseif v31 == 17 then
						v27 = 0
						v32 = readBits(3) + 3
					elseif v31 == 18 then
						v27 = 0
						v32 = readBits(7) + 11
					end

					for _ = 1, v32 do
						table.insert(v26, v27)
					end

					if not (v22 <= #v26) then
						continue
					end

					v20 = createHuffmanTable(v26)
					local v33 = table.create(v23)
					local v34 = nil

					while true do
						local v36 = bit32.extract(buffer.readu8(buf, total), v17)
						v17 += 1

						if v17 == 8 then
							v17 = 0
							total += 1
						end

						local v37 = 2 + v36

						while not huffmanTable3[v37] do
							local v38 = 2 * v37
							local v39 = bit32.extract(buffer.readu8(buf, total), v17)
							v17 += 1

							if v17 == 8 then
								v17 = 0
								total += 1
							end

							v37 = v38 + v39
						end

						local v38 = huffmanTable3[v37]
						local v39 = 1

						if v38 <= 15 then
							v34 = v38
						elseif v38 == 16 then
							v39 = readBits(2) + 3
						elseif v38 == 17 then
							v34 = 0
							v39 = readBits(3) + 3
						elseif v38 == 18 then
							v34 = 0
							v39 = readBits(7) + 11
						end

						for _ = 1, v39 do
							table.insert(v33, v34)
						end

						if not (v23 <= #v33) then
							continue
						end

						v21 = createHuffmanTable(v33)
						break
					end

					break
				end
			end

			repeat
				local v23 = bit32.extract(buffer.readu8(buf, total), v17)
				v17 += 1

				if v17 == 8 then
					v17 = 0
					total += 1
				end

				local v24 = 2 + v23

				while not v20[v24] do
					local v25 = 2 * v24
					local v26 = bit32.extract(buffer.readu8(buf, total), v17)
					v17 += 1

					if v17 == 8 then
						v17 = 0
						total += 1
					end

					v24 = v25 + v26
				end

				local v25 = v20[v24]

				if v25 < 256 then
					buffer.writeu8(buf2, total2, v25)
					total2 += 1
				elseif v25 > 256 then
					local v26 = v[v25 - 256]

					if v25 > 268 then
						v26 += readBits(v4[v25 - 264])
					elseif v25 > 264 then
						local v27 = bit32.extract(buffer.readu8(buf, total), v17)
						v17 += 1

						if v17 == 8 then
							v17 = 0
							total += 1
						end

						v26 += v27
					end

					local v28 = bit32.extract(buffer.readu8(buf, total), v17)
					v17 += 1

					if v17 == 8 then
						v17 = 0
						total += 1
					end

					local v29 = 2 + v28

					while not v21[v29] do
						local v30 = 2 * v29
						local v31 = bit32.extract(buffer.readu8(buf, total), v17)
						v17 += 1

						if v17 == 8 then
							v17 = 0
							total += 1
						end

						v29 = v30 + v31
					end

					local v30 = v21[v29]
					local v31 = v6[v30 + 1]

					if v30 > 5 then
						v31 += readBits(v9[v30])
					elseif v30 > 3 then
						local v32 = bit32.extract(buffer.readu8(buf, total), v17)
						v17 += 1

						if v17 == 8 then
							v17 = 0
							total += 1
						end

						v31 += v32
					end

					if v26 <= v31 then
						buffer.copy(buf2, total2, buf2, total2 - v31, v26)
						total2 += v26
					else
						repeat
							local v32 = math.min(v26, v31)
							buffer.copy(buf2, total2, buf2, total2 - v31, v32)
							total2 += v32
							v26 -= v32
							v31 += v32
						until v26 == 0
					end
				end
			until v25 == 256
		end

		if v18 ~= 1 then
			continue
		end

		if v17 > 0 then
			v17 = 0
			total += 1
		end

		assert(
			adler32(buf2, 0, buffer.len(buf2)) == bit32.byteswap((buffer.readu32(buf, total))),
			"adler-32 checksum mismatch"
		)
		return total2
	end
end

function Zlib.deflate(buf: buffer)
	local v15 = buffer.len(buf)
	local buf2 = buffer.create(getStoreSize(v15) + 6)
	buffer.writeu16(buf2, 0, 24184)
	local total = 2
	local v16 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function writeBits(value: number, bitCount: number)
		buffer.writebits(buf2, total * 8 + v16, bitCount, value)
		v16 += bitCount
		total += bit32.rshift(v16, 3)
		v16 = bit32.band(v16, 7)
	end

	local function writeHuffmanBits(p: number, bitCount: number)
		local v17 = bit32.bor(bit32.band(bit32.rshift(p, 1), 1431655765), (bit32.band(bit32.lshift(p, 1), 2863311530)))
		local v18 = bit32.bor(
			bit32.band(bit32.rshift(v17, 2), 858993459),
			(bit32.band(bit32.lshift(v17, 2), 3435973836))
		)
		local v19 = bit32.bor(
			bit32.band(bit32.rshift(v18, 4), 252645135),
			(bit32.band(bit32.lshift(v18, 4), 4042322160))
		)
		local v20 = bit32.bor(
			bit32.band(bit32.rshift(v19, 8), 16711935),
			(bit32.band(bit32.lshift(v19, 8), 4278255360))
		)
		writeBits(
			bit32.band(
				bit32.rshift(bit32.bor(bit32.rshift(v20, 16), (bit32.lshift(v20, 16))), 32 - bitCount),
				bit32.lshift(1, bitCount) - 1
			),
			bitCount
		) -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function writeLitOrLen(p: number)
		writeHuffmanBits(v11[p], v12[p])
	end

	local function writeBackRef(y: number, z: number)
		writeLitOrLen(v2[z]) -- equivalent call inferred; original call site unknown

		if z > 10 then
			writeBits(v3[z], v5[z]) -- equivalent call inferred; original call site unknown
		end

		local distIdx = getDistIdx(y)
		writeHuffmanBits(v13[distIdx - 1], v14[distIdx - 1])

		if distIdx > 3 then
			writeBits(y - v6[distIdx], v9[distIdx - 1]) -- equivalent call inferred; original call site unknown
		end
	end

	local function getLitOrLenSize(p: number)
		return v12[p]
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getBackRefSize(p: number, p2: number)
		local distIdx = getDistIdx(p)
		return v12[v2[p2]] + v5[p2] + v14[distIdx - 1] + (v9[distIdx - 1] or 0)
	end

	local v17 = {}
	local v18 = {}
	local v19 = {}
	local count = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function insertNode(p: number, p2: number)
		count += 1
		v17[count] = p
		v18[count] = p2
		return count
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearTables()
		table.clear(v17)
		table.clear(v18)
		table.clear(v19)
		count = 0
	end

	for i = 0, v15 - 1, 32768 do
		local v20 = math.min(v15, i + 32768)
		local v21 = i
		local total2 = 0
		local v22 = {}

		while v21 < v20 - 3 do
			local v23 = bit32.band(buffer.readu32(buf, v21), 16777215)
			local count3 = insertNode(v21, v19[v23] or 0) -- equivalent call inferred; original call site unknown
			v19[v23] = count3
			local v26 = v18[count3]
			local count2 = 0
			local v27 = 0
			local v28 = -1

			while v26 do
				local v29 = v17[v26] or -1e999

				if not (v21 - 32510 <= v29 and count2 < 12 and v27 < 96) then
					break
				end

				local v30 = 3
				local v31 = v17[v26]
				local v32 = math.min(v20, v21 + 258)
				local v33

				if v21 + v27 < v32 and buffer.readu8(buf, v31 + v27) ~= buffer.readu8(buf, v21 + v27) then
					v33 = true
				else
					v33 = false
				end

				while not v33 and v30 < 258 and v21 + v30 < v20 and buffer.readu8(buf, v31 + v30) == buffer.readu8(
					buf,
					v21 + v30
				) do
					v30 += 1
				end

				if v27 < v30 then
					if v30 >= 258 then
						v28 = v31
						v27 = v30
						break
					else
						v28 = v31
						v27 = v30
					end
				end

				v26 = v18[v26]
				count2 += 1
			end

			if v27 == 0 then
				local v29 = buffer.readu8(buf, v21)
				total2 += v12[v29]
				table.insert(v22, (vector.create(0, v29)))
				v21 += 1
			else
				total2 += getBackRefSize(v21 - v28, v27)
				table.insert(v22, (vector.create(1, v21 - v28, v27)))

				for i2 = v21 + 1, math.min(v21 + v27 - 1, v20 - 4) do
					local v30 = bit32.band(buffer.readu32(buf, i2), 16777215)
					v19[v30] = insertNode(i2, v19[v30] or 0)
				end

				v21 += v27
			end
		end

		while v21 < v20 do
			local v23 = buffer.readu8(buf, v21)
			total2 += v12[v23]
			table.insert(v22, (vector.create(0, v23)))
			v21 += 1
		end

		local v23 = total2 + v12[256]
		table.insert(v22, createVector(0, 256, 0))

		if v20 == v15 then
			buffer.writebits(buf2, total * 8 + v16, 1, 1)
		else
			buffer.writebits(buf2, total * 8 + v16, 1, 0)
		end

		v16 += 1
		total += bit32.rshift(v16, 3)
		v16 = bit32.band(v16, 7)
		local v24 = v20 - i

		if math.ceil(v23 / 8) + 1 < getStoreSize(v24) then
			writeBits(1, 2) -- equivalent call inferred; original call site unknown

			for _, v25 in v22 do
				if v25.x == 0 then
					writeLitOrLen(v25.y) -- equivalent call inferred; original call site unknown
				else
					writeBackRef(v25.y, v25.z)
				end
			end
		else
			writeBits(0, 2) -- equivalent call inferred; original call site unknown

			if v16 > 0 then
				total += 1
				v16 = 0
			end

			buffer.writeu16(buf2, total, v24)
			buffer.writeu16(buf2, total + 2, (bit32.bxor(65535, v24)))
			buffer.copy(buf2, total + 4, buf, i, v24)
			total += v24 + 4
		end

		if not (count > 50000) then
			continue
		end

		clearTables() -- equivalent call inferred; original call site unknown
	end

	if v16 > 0 then
		total += 1
	end

	local v20 = bit32.byteswap((adler32(buf, 0, buffer.len(buf))))
	buffer.writeu32(buf2, total, v20)
	return buf2, total + 4
end

return Zlib