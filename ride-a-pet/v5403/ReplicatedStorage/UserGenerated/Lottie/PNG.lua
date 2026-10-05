require(script.Types)
local chunks = require(script.chunks)
local crc32 = require(script.crc32)
local zlib = require(script.zlib)
local v = {
	[0] = 1,
	[2] = 3,
	[3] = 1,
	[4] = 2,
	[6] = 4
}
local v2 = {
	0,
	0,
	4,
	0,
	2,
	0,
	1
}
local v3 = {
	0,
	4,
	0,
	2,
	0,
	1,
	0
}
local v4 = {
	8,
	8,
	8,
	4,
	4,
	2,
	2
}
local v5 = {
	8,
	8,
	4,
	4,
	2,
	2,
	1
}
local PNG = {}

function PNG.decode(buf: buffer, p)
	local v6 = buffer.len(buf)
	assert(v6 >= 8, "not a PNG")
	assert(buffer.readstring(buf, 0, 8) == "\137PNG\r\n\26\n", "not a PNG")
	local v7 = table.create(3)
	local v8 = 8
	local v9

	if p == nil then
		v9 = false
	elseif p.allowIncorrectCRC == true then
		v9 = true
	else
		v9 = false
	end

	local v10

	while true do
		local length = bit32.byteswap((buffer.readu32(buf, v8)))
		local v12 = buffer.readstring(buf, v8 + 4, 4)
		assert(string.match(v12, "%a%a%a%a"), (`invalid chunk type {v12}`))
		local offset = v8 + 8
		v10 = offset + length + 4
		assert(v10 <= v6, (`EOF while reading {v12} chunk`))
		local v14 = bit32.byteswap((buffer.readu32(buf, v10 - 4)))
		local v15 = crc32(buf, v8 + 4, v10 - 5)
		assert(v9 or v14 == v15, (`incorrect checksum in {v12}`))
		table.insert(v7, {
			type = v12,
			offset = offset,
			length = length
		})

		if v6 <= v10 then
			break
		end

		v8 = v10
	end

	assert(v10 == v6, "trailing data in file")

	for _, v11 in v7 do
		local type = v11.type

		if not (bit32.extract(string.byte(type, 1, 1), 5) == 0 and type ~= "IHDR" and type ~= "IDAT" and type ~= "PLTE") then
			continue
		end

		if type == "IEND" then
			continue
		end

		error((`unhandled critical chunk {type}`))
	end

	local v11 = v7[1]
	assert(v11.type == "IHDR", "first chunk must be IHDR")

	for i = 2, #v7 do
		assert(v7[i].type ~= "IHDR", "multiple IHDR chunks are not allowed")
	end

	local IHDR = chunks.IHDR(buf, v11)
	local v12 = -1
	local v13 = -1
	local total = 0

	for k, v14 in v7 do
		if v14.type ~= "IDAT" then
			continue
		end

		if v12 < 0 then
			v12 = k
		else
			assert(k == v13 + 1, "multiple IDAT chunks must be consecutive")
		end

		total += v14.length
		v13 = k
	end

	assert(v12 > 0, "no IDAT chunks")
	assert(total > 0, "no image data in IDAT chunks")
	local v14 = nil
	local v15 = -1

	for k, v16 in v7 do
		if v16.type ~= "PLTE" then
			continue
		end

		assert(not v14, "multiple PLTE chunks are not allowed")
		assert(k < v12, "PLTE not allowed after IDAT chunks")
		local v17

		if IHDR.colorType == 0 then
			v17 = false
		else
			v17 = IHDR.colorType ~= 4
		end

		assert(v17, "PLTE not allowed for color type")
		v14 = chunks.PLTE(buf, v16, IHDR)
		v15 = k
	end

	if IHDR.colorType == 3 then
		assert(v14 ~= nil, "color type requires a PLTE chunk")
	end

	local v16 = nil

	for k, v17 in v7 do
		if v17.type ~= "tRNS" then
			continue
		end

		assert(v16 == nil, "multiple tRNS chunks are not allowed")
		assert(k < v12, "tRNS not allowed after IDAT chunks")
		assert(not v14 or v15 < k, "tRNS must be after PLTE")
		local v18

		if IHDR.colorType == 4 then
			v18 = false
		else
			v18 = IHDR.colorType ~= 6
		end

		assert(v18, "tRNS not allowed for color type")
		v16 = chunks.tRNS(buf, v17, IHDR, v14)
	end

	local v17 = v7[#v7]
	assert(v17.type == "IEND", "final chunk must be IEND")
	assert(v17.length == 0, "IEND chunk must be empty")

	for i = 2, #v7 - 1 do
		assert(v7[i].type ~= "IEND", "multiple IEND chunks are not allowed")
	end

	local buf2 = buffer.create(total)
	local total2 = 0

	for _, v18 in v7 do
		if v18.type ~= "IDAT" then
			continue
		end

		buffer.copy(buf2, total2, buf, v18.offset, v18.length)
		total2 += v18.length
	end

	local width = IHDR.width
	local height = IHDR.height
	local bitDepth = IHDR.bitDepth
	local colorType = IHDR.colorType
	local v18 = v[colorType]
	local v19 = 0

	if IHDR.interlaced then
		for i = 1, 7 do
			local v20 = math.ceil((width - v3[i]) / v5[i])
			local v21 = math.ceil((height - v2[i]) / v4[i])

			if v20 > 0 and v21 > 0 then
				v19 += v21 * (math.ceil(v20 * v18 * bitDepth / 8) + 1)
			end
		end
	else
		v19 = height * (math.ceil(width * v18 * bitDepth / 8) + 1)
	end

	local colors

	if v14 then
		colors = v14.colors
	else
		colors = nil
	end

	local v20

	if colorType == 3 or not (bitDepth < 8) then
		v20 = nil
	else
		v20 = 255 / (2 ^ bitDepth - 1)
	end

	local v21 = math.ceil(v18 * bitDepth / 8)
	local v22 = 2 ^ bitDepth - 1
	local total3 = 0
	local buf3 = buffer.create(v19)
	assert(zlib.inflate(buf2, buf3) == v19, "decompressed data size mismatch")
	local buf4 = buffer.create(width * height * 4)
	local v23 = not v16 and -1 or v16.gray
	local v24 = not v16 and -1 or v16.red
	local v25 = not v16 and -1 or v16.green
	local v26 = not v16 and -1 or v16.blue

	local function pass(p2: number, p3: number, p4: number, p5: number)
		local v27 = math.ceil((width - p2) / p4)
		local v28 = math.ceil((height - p3) / p5)

		if v27 < 1 or v28 < 1 then
			return
		end

		local v29 = math.ceil(v27 * v18 * bitDepth / 8)
		local v30 = total3

		for i = 1, v28 do
			local v31 = buffer.readu8(buf3, total3)
			total3 += 1

			if v31 == 0 or v31 == 2 and i == 1 then
				total3 += v29
			elseif v31 == 1 then
				for i2 = 1, v29 do
					local v32 = i2 <= v21 and 0 or buffer.readu8(buf3, total3 - v21)
					local v33 = bit32.band(buffer.readu8(buf3, total3) + v32, 255)
					buffer.writeu8(buf3, total3, v33)
					total3 += 1
				end
			elseif v31 == 2 then
				for _ = 1, v29 do
					local v32 = buffer.readu8(buf3, total3 - v29 - 1)
					local v33 = bit32.band(buffer.readu8(buf3, total3) + v32, 255)
					buffer.writeu8(buf3, total3, v33)
					total3 += 1
				end
			elseif v31 == 3 then
				for i2 = 1, v29 do
					local v32 = i2 <= v21 and 0 or buffer.readu8(buf3, total3 - v21)
					local v33 = i == 1 and 0 or buffer.readu8(buf3, total3 - v29 - 1)
					local v34 = bit32.band(buffer.readu8(buf3, total3) + bit32.rshift(v32 + v33, 1), 255)
					buffer.writeu8(buf3, total3, v34)
					total3 += 1
				end
			elseif v31 == 4 then
				for i2 = 1, v29 do
					local v32 = i2 <= v21 and 0 or buffer.readu8(buf3, total3 - v21)
					local v33 = i == 1 and 0 or buffer.readu8(buf3, total3 - v29 - 1)
					local v34 = (i2 <= v21 or i == 1) and 0 or buffer.readu8(buf3, total3 - v29 - v21 - 1)
					local v35 = math.abs(v33 - v34)
					local v36 = math.abs(v32 - v34)
					local v37 = math.abs(v32 + v33 - v34 * 2)

					if v35 <= v36 and v35 <= v37 then
						v34 = v32
					elseif v36 <= v37 then
						v34 = v33
					end

					local v38 = bit32.band(buffer.readu8(buf3, total3) + v34, 255)
					buffer.writeu8(buf3, total3, v38)
					total3 += 1
				end
			else
				error("invalid row filter")
			end
		end

		local v31 = 8

		local function readValue()
			local v32 = buffer.readu8(buf3, v30)
			local v33

			if bitDepth < 8 then
				v33 = bit32.extract(v32, v31 - bitDepth, bitDepth)
				v31 -= bitDepth

				if v31 ~= 0 then
					return v33
				end

				v31 = 8
				v30 += 1
			else
				if bitDepth == 8 then
					v30 += 1
					return v32
				end

				v33 = bit32.bor(bit32.lshift(v32, 8), (buffer.readu8(buf3, v30 + 1)))
				v30 += 2
			end

			return v33
		end

		for i = 1, v28 do
			v30 += 1

			if v31 < 8 then
				v31 = 8
				v30 += 1
			end

			for i2 = 1, v27 do
				local r = nil
				local g = nil
				local b = nil
				local a = nil

				if colorType == 0 then
					r = buffer.readu8(buf3, v30)

					if bitDepth < 8 then
						r = bit32.extract(r, v31 - bitDepth, bitDepth)
						v31 -= bitDepth

						if v31 == 0 then
							v31 = 8
							v30 += 1
						end
					elseif bitDepth == 8 then
						v30 += 1
					else
						r = bit32.bor(bit32.lshift(r, 8), (buffer.readu8(buf3, v30 + 1)))
						v30 += 2
					end

					if r == v23 then
						b = r
						g = b
						b = g
						a = 0
					else
						a = v22
						b = r
						g = b
						b = g
					end
				elseif colorType == 2 then
					r = buffer.readu8(buf3, v30)

					if bitDepth < 8 then
						r = bit32.extract(r, v31 - bitDepth, bitDepth)
						v31 -= bitDepth

						if v31 == 0 then
							v31 = 8
							v30 += 1
						end
					elseif bitDepth == 8 then
						v30 += 1
					else
						r = bit32.bor(bit32.lshift(r, 8), (buffer.readu8(buf3, v30 + 1)))
						v30 += 2
					end

					g = buffer.readu8(buf3, v30)

					if bitDepth < 8 then
						g = bit32.extract(g, v31 - bitDepth, bitDepth)
						v31 -= bitDepth

						if v31 == 0 then
							v31 = 8
							v30 += 1
						end
					elseif bitDepth == 8 then
						v30 += 1
					else
						g = bit32.bor(bit32.lshift(g, 8), (buffer.readu8(buf3, v30 + 1)))
						v30 += 2
					end

					b = buffer.readu8(buf3, v30)

					if bitDepth < 8 then
						b = bit32.extract(b, v31 - bitDepth, bitDepth)
						v31 -= bitDepth

						if v31 == 0 then
							v31 = 8
							v30 += 1
						end
					elseif bitDepth == 8 then
						v30 += 1
					else
						b = bit32.bor(bit32.lshift(b, 8), (buffer.readu8(buf3, v30 + 1)))
						v30 += 2
					end

					if r == v24 and g == v25 and b == v26 then
						a = 0
					else
						a = v22
					end
				elseif colorType == 3 then
					local v33 = buffer.readu8(buf3, v30)

					if bitDepth < 8 then
						v33 = bit32.extract(v33, v31 - bitDepth, bitDepth)
						v31 -= bitDepth

						if v31 == 0 then
							v31 = 8
							v30 += 1
						end
					elseif bitDepth == 8 then
						v30 += 1
					else
						v33 = bit32.bor(bit32.lshift(v33, 8), (buffer.readu8(buf3, v30 + 1)))
						v30 += 2
					end

					local v34 = colors[v33 + 1]
					r = v34.r
					g = v34.g
					b = v34.b
					a = v34.a
				elseif colorType == 4 then
					r = buffer.readu8(buf3, v30)

					if bitDepth < 8 then
						r = bit32.extract(r, v31 - bitDepth, bitDepth)
						v31 -= bitDepth

						if v31 == 0 then
							v31 = 8
							v30 += 1
						end
					elseif bitDepth == 8 then
						v30 += 1
					else
						r = bit32.bor(bit32.lshift(r, 8), (buffer.readu8(buf3, v30 + 1)))
						v30 += 2
					end

					a = buffer.readu8(buf3, v30)

					if bitDepth < 8 then
						a = bit32.extract(a, v31 - bitDepth, bitDepth)
						v31 -= bitDepth

						if v31 == 0 then
							v31 = 8
							v30 += 1
						end
					elseif bitDepth == 8 then
						v30 += 1
					else
						a = bit32.bor(bit32.lshift(a, 8), (buffer.readu8(buf3, v30 + 1)))
						v30 += 2
					end

					b = r
					g = b
					b = g
				elseif colorType == 6 then
					r = buffer.readu8(buf3, v30)

					if bitDepth < 8 then
						r = bit32.extract(r, v31 - bitDepth, bitDepth)
						v31 -= bitDepth

						if v31 == 0 then
							v31 = 8
							v30 += 1
						end
					elseif bitDepth == 8 then
						v30 += 1
					else
						r = bit32.bor(bit32.lshift(r, 8), (buffer.readu8(buf3, v30 + 1)))
						v30 += 2
					end

					g = buffer.readu8(buf3, v30)

					if bitDepth < 8 then
						g = bit32.extract(g, v31 - bitDepth, bitDepth)
						v31 -= bitDepth

						if v31 == 0 then
							v31 = 8
							v30 += 1
						end
					elseif bitDepth == 8 then
						v30 += 1
					else
						g = bit32.bor(bit32.lshift(g, 8), (buffer.readu8(buf3, v30 + 1)))
						v30 += 2
					end

					b = buffer.readu8(buf3, v30)

					if bitDepth < 8 then
						b = bit32.extract(b, v31 - bitDepth, bitDepth)
						v31 -= bitDepth

						if v31 == 0 then
							v31 = 8
							v30 += 1
						end
					elseif bitDepth == 8 then
						v30 += 1
					else
						b = bit32.bor(bit32.lshift(b, 8), (buffer.readu8(buf3, v30 + 1)))
						v30 += 2
					end

					a = buffer.readu8(buf3, v30)

					if bitDepth < 8 then
						a = bit32.extract(a, v31 - bitDepth, bitDepth)
						v31 -= bitDepth

						if v31 == 0 then
							v31 = 8
							v30 += 1
						end
					elseif bitDepth == 8 then
						v30 += 1
					else
						a = bit32.bor(bit32.lshift(a, 8), (buffer.readu8(buf3, v30 + 1)))
						v30 += 2
					end
				end

				local v32 = p3 + (i - 1) * p5
				local v33 = p2 + (i2 - 1) * p4
				local v34 = (v32 * width + v33) * 4

				if v20 then
					r = math.round(r * v20)
					g = math.round(g * v20)
					b = math.round(b * v20)
					a = math.round(a * v20)
				elseif bitDepth == 16 then
					r = bit32.rshift(r, 8)
					g = bit32.rshift(g, 8)
					b = bit32.rshift(b, 8)
					a = bit32.rshift(a, 8)
				end

				buffer.writeu32(buf4, v34, (bit32.bor(bit32.lshift(a, 24), bit32.lshift(b, 16), bit32.lshift(g, 8), r)))
			end
		end
	end

	if IHDR.interlaced then
		for i = 1, 7 do
			pass(v3[i], v2[i], v5[i], v4[i])
		end
	else
		pass(0, 0, 1, 1)
	end

	return {
		width = width,
		height = height,
		pixels = buf4,
		readPixel = function(p2: number, p3: number)
			local v27

			if p2 >= 1 and p2 <= width and p3 >= 1 then
				v27 = p3 <= height
			else
				v27 = false
			end

			assert(v27, "pixel out of range")
			local v28 = ((p3 - 1) * width + p2 - 1) * 4
			return
				buffer.readu8(buf4, v28),
				buffer.readu8(buf4, v28 + 1),
				buffer.readu8(buf4, v28 + 2),
				(buffer.readu8(buf4, v28 + 3))
		end
	}
end

function PNG.encode(buf: buffer, p)
	local width = p.width
	local height = p.height
	local v6 = buffer.len(buf)
	local v7 = width * height * 4
	assert(v6 == v7, (`expected {v7} bytes, got {v6} bytes`))
	local v8 = width * 4 + 1
	local buf2 = buffer.create(height * v8)

	for i = 0, height - 1 do
		local v9 = i * width * 4
		local v10 = i * v8
		buffer.writeu8(buf2, v10, 0)
		buffer.copy(buf2, v10 + 1, buf, v9, width * 4)
	end

	local deflate, v9 = zlib.deflate(buf2)
	local v10 = 33 + (8 + v9 + 4) + 12
	local buf3 = buffer.create(v10)
	buffer.writestring(buf3, 0, "\137PNG\r\n\26\n")
	buffer.writeu32(buf3, 8, (bit32.byteswap(13)))
	buffer.writestring(buf3, 12, "IHDR")
	buffer.writeu32(buf3, 16, (bit32.byteswap(width)))
	buffer.writeu32(buf3, 20, (bit32.byteswap(height)))
	buffer.writeu8(buf3, 24, 8)
	buffer.writeu8(buf3, 25, 6)
	buffer.writeu8(buf3, 26, 0)
	buffer.writeu8(buf3, 27, 0)
	buffer.writeu8(buf3, 28, 0)
	buffer.writeu32(buf3, 29, (bit32.byteswap((crc32(buf3, 12, 28)))))
	buffer.writeu32(buf3, 33, (bit32.byteswap(v9)))
	buffer.writestring(buf3, 37, "IDAT")
	buffer.copy(buf3, 41, deflate, 0, v9)
	local v11 = 41 + v9
	buffer.writeu32(buf3, v11, (bit32.byteswap((crc32(buf3, 37, v11 - 1)))))
	buffer.writeu32(buf3, v11 + 4, 0)
	buffer.writestring(buf3, v11 + 8, "IEND")
	buffer.writeu32(buf3, v11 + 12, 2187346606)
	return buf3
end

return PNG