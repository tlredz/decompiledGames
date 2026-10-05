local HttpService = game:GetService("HttpService")

local function create()
	return HttpService:GenerateGUID(false)
end

local function compress(buf: buffer, offset: number, value: string)
	local v = value:gsub("-", "")
	buffer.writeu32(buf, offset, tonumber(v:sub(1, 8), 16) or 0)
	local v2 = tonumber(v:sub(9, 12), 16)
	buffer.writeu16(buf, offset + 4, v2 or 0)
	local v3 = tonumber(v:sub(13, 16), 16)
	buffer.writeu16(buf, offset + 6, v3 or 0)
	local v4 = tonumber(v:sub(17, 20), 16)
	buffer.writeu16(buf, offset + 8, v4 or 0)
	local v5 = tonumber(v:sub(21, 24), 16)
	buffer.writeu16(buf, offset + 10, v5 or 0)
	local v6 = tonumber(v:sub(25, 32), 16)
	buffer.writeu32(buf, offset + 12, v6 or 0)
	return offset + 16
end

local function decompress(buf: buffer, offset: number)
	local v = buffer.readu32(buf, offset)
	local v2 = buffer.readu16(buf, offset + 4)
	local v3 = buffer.readu16(buf, offset + 6)
	local v4 = buffer.readu16(buf, offset + 8)
	local v5 = buffer.readu16(buf, offset + 10)
	local v6 = buffer.readu32(buf, offset + 12)
	return string.format("%08x-%04x-%04x-%04x-%04x%08x", v, v2, v3, v4, v5, v6), offset + 16
end

return table.freeze({
	Create = create,
	Compress = compress,
	Decompress = decompress
})