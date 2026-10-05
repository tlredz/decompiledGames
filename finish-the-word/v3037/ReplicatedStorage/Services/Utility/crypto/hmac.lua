-- equivalent calls inferred from this helper; original call sites unknown
local function FromByteAndSize(value: number, size: number)
	local buf = buffer.create(size)
	buffer.fill(buf, 0, value)
	return buf
end

local function ToBigEndian(buf: buffer)
	for i = 0, buffer.len(buf) - 1, 4 do
		buffer.writeu32(buf, i, (bit32.byteswap((buffer.readu32(buf, i)))))
	end
end

local function ConcatenateBuffers(buf: buffer, buf2: buffer)
	local v = buffer.len(buf)
	local buf3 = buffer.create(v + buffer.len(buf2))
	buffer.copy(buf3, 0, buf)
	buffer.copy(buf3, v, buf2)
	return buf3
end

local function XORBuffer(buf: buffer, buf2: buffer)
	local v = math.min(buffer.len(buf), buffer.len(buf2))
	local buf3 = buffer.create(v)

	for i = 0, v - 1 do
		buffer.writeu8(buf3, i, (bit32.bxor(buffer.readu8(buf, i), (buffer.readu8(buf2, i)))))
	end

	return buf3
end

local function ComputeBlockSizedKey(buf: buffer, callback, size: number)
	local v = buffer.len(buf)

	if size < v then
		local _, v2 = callback(buf)
		ToBigEndian(v2)
		local buf2 = buffer.create(size)
		buffer.copy(buf2, 0, v2)
		return buf2
	elseif v < size then
		local buf2 = buffer.create(size)
		buffer.copy(buf2, 0, buf)
		return buf2
	else
		return buf
	end
end

local function HMAC(buf: buffer, buf2: buffer, callback, size: number)
	local buf3 = ComputeBlockSizedKey(buf2, callback, size)
	local xORBuffer = XORBuffer(buf3, FromByteAndSize(92, size))
	local _, v5 = callback((ConcatenateBuffers(XORBuffer(buf3, FromByteAndSize(54, size)), buf)))
	ToBigEndian(v5)
	return callback((ConcatenateBuffers(xORBuffer, v5)))
end

return HMAC