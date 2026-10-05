local band = bit32.band
local lshift = bit32.lshift
local rshift = bit32.rshift
local lrotate = bit32.lrotate
local bxor = bit32.bxor
local bor = bit32.bor
local len = buffer.len
local readu32 = buffer.readu32
local readu8 = buffer.readu8
local readu16 = buffer.readu16
local fromstring = buffer.fromstring

function mul32(p: number, p2: number)
	return band(p, 65535) * p2 + lshift(band(rshift(p, 16) * p2, 65535), 16)
end

function DigestBufferUnsafe(buf: buffer, total: number, p: number, p2: number?)
	if p2 == nil then
		p2 = 0
	else
		assert(bor(p2, 0) == p2)
	end

	local v = total + p - 3

	while total < v do
		local v2 = readu32(buf, total)
		local v4 = lrotate(mul32(v2, 3432918353), 15)
		p2 = lshift(lrotate(bxor(p2, (mul32(v4, 461845907))), 13) * 5, 0) + 3864292196
		total += 4
	end

	local v2 = band(p, 3)

	if v2 > 0 then
		local v3

		if v2 == 3 then
			v3 = readu8(buf, total) + lshift(readu16(buf, total + 1), 8)
		elseif v2 == 2 then
			v3 = readu16(buf, total)
		else
			v3 = readu8(buf, total)
		end

		local v5 = lrotate(mul32(v3, 3432918353), 15)
		p2 = bxor(p2, (mul32(v5, 461845907)))
	end

	local v3 = bxor(p2, p)
	local v5 = bxor(v3, (rshift(v3, 16)))
	local v6 = mul32(v5, 2246822507)
	local v8 = bxor(v6, (rshift(v6, 13)))
	local v9 = mul32(v8, 3266489909)
	return (bxor(v9, (rshift(v9, 16))))
end

function DigestBufferCustom(buf: buffer, value: number, value2: number, p: number?)
	assert(type(buf) == "buffer")
	local v

	if type(value) == "number" and value >= 0 then
		v = value <= len(buf)
	else
		v = false
	end

	assert(v)
	local v2

	if type(value2) == "number" and value2 >= 0 then
		v2 = value2 <= len(buf) - value
	else
		v2 = false
	end

	assert(v2)
	return DigestBufferUnsafe(buf, value, value2, p)
end

function DigestBuffer(buf: buffer, p: number?)
	return DigestBufferUnsafe(buf, 0, len(buf), p)
end

function Digest(p: string, p2: number?)
	local buffer2 = fromstring(p)
	return DigestBufferUnsafe(buffer2, 0, len(buffer2), p2)
end

local MurmurHash3 = {
	DigestBufferCustom = DigestBufferCustom,
	DigestBuffer = DigestBuffer,
	Digest = Digest
}
table.freeze(MurmurHash3)
return MurmurHash3