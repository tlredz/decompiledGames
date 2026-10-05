local function readf16(buf: buffer, offset: number)
	local v = buffer.readu8(buf, offset)
	local v2 = buffer.readu8(buf, offset + 1)
	local v3 = bit32.btest(v, 128) and -1 or 1
	local v4 = bit32.rshift(bit32.band(v, 127), 2)
	local v5 = bit32.lshift(bit32.band(v, 3), 8) + v2

	if v4 == 31 then
		if v5 == 0 then
			return 1e999 * v3
		end

		return (0 / 0)
	else
		if v4 ~= 0 then
			return math.ldexp(v5 / 1024 + 1, v4 - 15) * v3
		end

		if v5 == 0 then
			return 0
		end

		return math.ldexp(v5 / 1024, -14) * v3
	end
end

local function writef16(buf: buffer, offset: number, p: number)
	local v = p < 0
	local v2 = math.abs(p)
	local v3, v4 = math.frexp(v2)

	if v2 == 1e999 then
		if v then
			buffer.writeu8(buf, offset, 252)
		else
			buffer.writeu8(buf, offset, 124)
		end

		buffer.writeu8(buf, offset + 1, 0)
	elseif v2 ~= v2 or v2 == 0 then
		buffer.writeu16(buf, offset, 0)
	elseif v4 + 15 <= 1 then
		local v5 = math.floor(v3 * 1024 + 0.5)

		if v then
			buffer.writeu8(buf, offset, bit32.rshift(v5, 8) + 128)
		else
			buffer.writeu8(buf, offset, (bit32.rshift(v5, 8)))
		end

		buffer.writeu8(buf, offset + 1, (bit32.band(v5, 255)))
	else
		local v5 = ((v3 - 0.5) * 2048 + 0.5) // 1

		if v then
			buffer.writeu8(buf, offset, bit32.lshift(v4 + 14, 2) + 128 + bit32.rshift(v5, 8))
		else
			buffer.writeu8(buf, offset, bit32.lshift(v4 + 14, 2) + bit32.rshift(v5, 8))
		end

		buffer.writeu8(buf, offset + 1, (bit32.band(v5, 255)))
	end
end

local function readi53(buf: buffer, offset: number)
	local v = buffer.readu32(buf, offset)
	return buffer.readi32(buf, offset + 4) * 2147483647 + v
end

local function writei53(buf: buffer, offset: number, p: number)
	local v = p % 2147483647
	local v2 = p // 2147483647
	buffer.writeu32(buf, offset, v)
	buffer.writei32(buf, offset + 4, v2)
end

local function readu53(buf: buffer, offset: number)
	local v = buffer.readu32(buf, offset)
	return buffer.readu32(buf, offset + 4) * 4294967296 + v
end

local function writeu53(buf: buffer, offset: number, p: number)
	local v = p % 4294967296
	local v2 = p // 4294967296
	buffer.writeu32(buf, offset, v)
	buffer.writeu32(buf, offset + 4, v2)
end

local function readVarInt(buf: buffer, count: number)
	local total = 0
	local total2 = 0

	repeat
		local v = buffer.readu8(buf, count)
		total2 += bit32.lshift(bit32.band(v, 127), total)
		count += 1
		total += 7
	until bit32.btest(v, 128)

	return total2, count
end

local function writeVarInt(buf: buffer, count: number, p: number)
	while true do
		local v = bit32.band(p, 127)
		p = bit32.rshift(p, 7)

		if p ~= 0 then
			v = bit32.bor(v, 128)
		end

		buffer.writeu8(buf, count, v)
		count += 1

		if p == 0 then
			return count
		end
	end
end

return table.freeze({
	ReadInt53 = readi53,
	WriteInt53 = writei53,
	ReadUInt53 = readu53,
	WriteUInt53 = writeu53,
	ReadFloat16 = readf16,
	WriteFloat16 = writef16,
	ReadVarInt = readVarInt,
	WriteVarInt = writeVarInt
})