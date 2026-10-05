local buf = buffer.create(85)
local buf2 = buffer.create(256)
assert(true, (`Ascii85Util: alphabet has {85} characters, expected {85}`))
local Ascii85Util = {}

for i = 0, 255 do
	buffer.writeu8(buf2, i, 255)
end

local count = 0

for i = 1, 85 do
	local v = string.byte("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:+=^!/*?&<>()[]{}@%$#", i)
	buffer.writeu8(buf, i - 1, v)

	if buffer.readu8(buf2, v) == 255 then
		count += 1
	end

	buffer.writeu8(buf2, v, i - 1)
end

assert(count == 85, "Ascii85Util: alphabet contains duplicate characters")

function Ascii85Util.encodedLength(p: number)
	local v = p // 4
	local v2 = p % 4
	return v * 5 + (not (v2 > 0) and 0 or v2 + 1)
end

function Ascii85Util.maxInputBytes(p: number)
	local v = p // 5
	local v2 = v * 4
	local v3 = p - v * 5

	if v3 >= 2 then
		return v2 + math.min(v3 - 1, 3)
	end

	return v2
end

function Ascii85Util.encode(buf3: buffer)
	local v = buffer.len(buf3)

	if v == 0 then
		return ""
	end

	local buf4 = buffer.create(Ascii85Util.encodedLength(v))
	local v2 = v // 4
	local total = 0

	for i = 0, v2 - 1 do
		local v3 = i * 4
		local v4 = buffer.readu8(buf3, v3) * 16777216 + buffer.readu8(buf3, v3 + 1) * 65536 + buffer.readu8(
			buf3,
			v3 + 2
		) * 256 + buffer.readu8(buf3, v3 + 3)
		local v5 = v4 % 85
		local v6 = v4 // 85
		local v7 = v6 % 85
		local v8 = v6 // 85
		local v9 = v8 % 85
		local v10 = v8 // 85
		local v11 = v10 % 85
		local v12 = v10 // 85
		buffer.writeu8(buf4, total, (buffer.readu8(buf, v12)))
		buffer.writeu8(buf4, total + 1, (buffer.readu8(buf, v11)))
		buffer.writeu8(buf4, total + 2, (buffer.readu8(buf, v9)))
		buffer.writeu8(buf4, total + 3, (buffer.readu8(buf, v7)))
		buffer.writeu8(buf4, total + 4, (buffer.readu8(buf, v5)))
		total += 5
	end

	local v3 = v % 4

	if not (v3 > 0) then
		return buffer.tostring(buf4)
	end

	local v4 = v2 * 4
	local v5 = 0

	for i = 0, 3 do
		local v6 = not (i < v3) and 0 or buffer.readu8(buf3, v4 + i)
		v5 = v5 * 256 + v6
	end

	local _ = v5 % 85
	local v6 = v5 // 85
	local v7 = v6 % 85
	local v8 = v6 // 85
	local v9 = v8 % 85
	local v10 = v8 // 85
	local v11 = v10 % 85
	local v12 = v10 // 85
	buffer.writeu8(buf4, total, (buffer.readu8(buf, v12)))
	buffer.writeu8(buf4, total + 1, (buffer.readu8(buf, v11)))
	local v13 = total + 2

	if v3 >= 2 then
		buffer.writeu8(buf4, v13, (buffer.readu8(buf, v9)))
		v13 += 1
	end

	if v3 >= 3 then
		buffer.writeu8(buf4, v13, (buffer.readu8(buf, v7)))
		v13 += 1
	end

	return buffer.tostring(buf4)
end

function Ascii85Util.decode(str: string)
	local count2 = #str

	if count2 == 0 then
		return buffer.create(0)
	end

	local v2 = count2 % 5
	assert(v2 ~= 1, "Ascii85Util: trailing group has a single character, which encodes no byte")
	local buf3 = buffer.create(count2 // 5 * 4 + (not (v2 > 0) and 0 or v2 - 1))
	local buffer2 = buffer.fromstring(str)
	local v3 = 0
	local count3 = 0
	local total = 0

	for i = 0, count2 - 1 do
		local v4 = buffer.readu8(buffer2, i)
		local v5 = buffer.readu8(buf2, v4)

		if v5 == 255 then
			error((`Ascii85Util: character {v4} at position {i + 1} is outside the alphabet`))
		end

		v3 = v3 * 85 + v5
		count3 += 1

		if count3 ~= 5 then
			continue
		end

		if v3 > 4294967295 then
			error((`Ascii85Util: group ending at position {i + 1} overflows 32 bits`))
		end

		buffer.writeu8(buf3, total, v3 // 16777216 % 256)
		buffer.writeu8(buf3, total + 1, v3 // 65536 % 256)
		buffer.writeu8(buf3, total + 2, v3 // 256 % 256)
		buffer.writeu8(buf3, total + 3, v3 % 256)
		total += 4
		v3 = 0
		count3 = 0
	end

	if not (count3 > 0) then
		return buf3
	end

	for _ = count3 + 1, 5 do
		v3 = v3 * 85 + 84
	end

	assert(v3 <= 4294967295, "Ascii85Util: trailing group overflows 32 bits")
	buffer.writeu8(buf3, total, v3 // 16777216 % 256)
	local v4 = total + 1

	if count3 >= 3 then
		buffer.writeu8(buf3, v4, v3 // 65536 % 256)
		v4 += 1
	end

	if count3 >= 4 then
		buffer.writeu8(buf3, v4, v3 // 256 % 256)
		v4 += 1
	end

	return buf3
end

return Ascii85Util