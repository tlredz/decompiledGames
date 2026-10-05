local buf = buffer.create(64)
local buf2 = buffer.create(256)

for i = 1, 64 do
	local v = i - 1
	local v2 = string.byte("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", i)
	buffer.writeu8(buf, v, v2)
	buffer.writeu8(buf2, v2, v)
end

function encode(buf3: buffer, p: number?)
	local v = p or buffer.len(buf3)
	local v2 = math.ceil(v / 3)
	local v3 = v2 * 4
	local buf4 = buffer.create(v3)

	for i = 1, v2 - 1 do
		local v5 = (i - 1) * 4
		local v6 = bit32.byteswap((buffer.readu32(buf3, (i - 1) * 3)))
		local v7 = bit32.rshift(v6, 26)
		local v8 = bit32.band(bit32.rshift(v6, 20), 63)
		local v9 = bit32.band(bit32.rshift(v6, 14), 63)
		local v10 = bit32.band(bit32.rshift(v6, 8), 63)
		buffer.writeu8(buf4, v5, (buffer.readu8(buf, v7)))
		buffer.writeu8(buf4, v5 + 1, (buffer.readu8(buf, v8)))
		buffer.writeu8(buf4, v5 + 2, (buffer.readu8(buf, v9)))
		buffer.writeu8(buf4, v5 + 3, (buffer.readu8(buf, v10)))
	end

	local v4 = v % 3

	if v4 == 1 then
		local v5 = buffer.readu8(buf3, v - 1)
		local v6 = bit32.rshift(v5, 2)
		local v7 = bit32.band(bit32.lshift(v5, 4), 63)
		buffer.writeu8(buf4, v3 - 4, (buffer.readu8(buf, v6)))
		buffer.writeu8(buf4, v3 - 3, (buffer.readu8(buf, v7)))
		buffer.writeu8(buf4, v3 - 2, 61)
		buffer.writeu8(buf4, v3 - 1, 61)
		return buf4
	elseif v4 == 2 then
		local v5 = bit32.bor(bit32.lshift(buffer.readu8(buf3, v - 2), 8), (buffer.readu8(buf3, v - 1)))
		local v6 = bit32.rshift(v5, 10)
		local v7 = bit32.band(bit32.rshift(v5, 4), 63)
		local v8 = bit32.band(bit32.lshift(v5, 2), 63)
		buffer.writeu8(buf4, v3 - 4, (buffer.readu8(buf, v6)))
		buffer.writeu8(buf4, v3 - 3, (buffer.readu8(buf, v7)))
		buffer.writeu8(buf4, v3 - 2, (buffer.readu8(buf, v8)))
		buffer.writeu8(buf4, v3 - 1, 61)
		return buf4
	else
		if v4 ~= 0 or v == 0 then
			return buf4
		end

		local v5 = bit32.bor(
			bit32.lshift(buffer.readu8(buf3, v - 3), 16),
			bit32.lshift(buffer.readu8(buf3, v - 2), 8),
			(buffer.readu8(buf3, v - 1))
		)
		local v6 = bit32.rshift(v5, 18)
		local v7 = bit32.band(bit32.rshift(v5, 12), 63)
		local v8 = bit32.band(bit32.rshift(v5, 6), 63)
		local v9 = bit32.band(v5, 63)
		buffer.writeu8(buf4, v3 - 4, (buffer.readu8(buf, v6)))
		buffer.writeu8(buf4, v3 - 3, (buffer.readu8(buf, v7)))
		buffer.writeu8(buf4, v3 - 2, (buffer.readu8(buf, v8)))
		buffer.writeu8(buf4, v3 - 1, (buffer.readu8(buf, v9)))
		return buf4
	end
end

function decode(buf3: buffer)
	local v = buffer.len(buf3)
	local v2 = math.ceil(v / 4)
	local count = 0

	if v ~= 0 then
		if buffer.readu8(buf3, v - 1) == 61 then
			count += 1
		end

		if buffer.readu8(buf3, v - 2) == 61 then
			count += 1
		end
	end

	local v3 = v2 * 3 - count
	local buf4 = buffer.create(v3)

	for i = 1, v2 - 1 do
		local v4 = (i - 1) * 4
		local v5 = (i - 1) * 3
		local v6 = buffer.readu8(buf2, (buffer.readu8(buf3, v4)))
		local v7 = buffer.readu8(buf2, (buffer.readu8(buf3, v4 + 1)))
		local v8 = buffer.readu8(buf2, (buffer.readu8(buf3, v4 + 2)))
		local v9 = buffer.readu8(buf2, (buffer.readu8(buf3, v4 + 3)))
		local v10 = bit32.bor(bit32.lshift(v6, 18), bit32.lshift(v7, 12), bit32.lshift(v8, 6), v9)
		local v11 = bit32.rshift(v10, 16)
		local v12 = bit32.band(bit32.rshift(v10, 8), 255)
		local v13 = bit32.band(v10, 255)
		buffer.writeu8(buf4, v5, v11)
		buffer.writeu8(buf4, v5 + 1, v12)
		buffer.writeu8(buf4, v5 + 2, v13)
	end

	if v == 0 then
		return buf4
	end

	local v4 = (v2 - 1) * 4
	local v5 = (v2 - 1) * 3
	local v6 = buffer.readu8(buf2, (buffer.readu8(buf3, v4)))
	local v7 = buffer.readu8(buf2, (buffer.readu8(buf3, v4 + 1)))
	local v8 = buffer.readu8(buf2, (buffer.readu8(buf3, v4 + 2)))
	local v9 = buffer.readu8(buf2, (buffer.readu8(buf3, v4 + 3)))
	local v10 = bit32.bor(bit32.lshift(v6, 18), bit32.lshift(v7, 12), bit32.lshift(v8, 6), v9)

	if count <= 2 then
		buffer.writeu8(buf4, v5, (bit32.rshift(v10, 16)))

		if count <= 1 then
			local v11 = bit32.band(bit32.rshift(v10, 8), 255)
			buffer.writeu8(buf4, v5 + 1, v11)

			if count == 0 then
				local v12 = bit32.band(v10, 255)
				buffer.writeu8(buf4, v5 + 2, v12)
			end
		end
	end

	return buf4
end

function Encode(str: string)
	return buffer.tostring(encode(buffer.fromstring(str)))
end

function Decode(str: string)
	return buffer.tostring(decode(buffer.fromstring(str)))
end

return table.freeze({
	Encode = Encode,
	Decode = Decode,
	EncodeBuffer = encode,
	DecodeBuffer = decode
})