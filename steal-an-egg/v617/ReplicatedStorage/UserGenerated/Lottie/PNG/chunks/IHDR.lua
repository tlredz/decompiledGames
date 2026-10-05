require(script.Parent.Parent.Types)
local v = {
	[0] = {
		1,
		2,
		4,
		8,
		16
	},
	[2] = { 8, 16 },
	[3] = {
		1,
		2,
		4,
		8
	},
	[4] = { 8, 16 },
	[6] = { 8, 16 }
}

local function read(buf: buffer, p)
	assert(p.length == 13, "IHDR data must be 13 bytes")
	local offset = p.offset
	local width = bit32.byteswap((buffer.readu32(buf, offset)))
	local height = bit32.byteswap((buffer.readu32(buf, offset + 4)))
	local bitDepth = buffer.readu8(buf, offset + 8)
	local colorType = buffer.readu8(buf, offset + 9)
	local v6 = buffer.readu8(buf, offset + 10)
	local v7 = buffer.readu8(buf, offset + 11)
	local v8 = buffer.readu8(buf, offset + 12)
	local v9

	if width > 0 and width <= 2147483648 and height > 0 then
		v9 = height <= 2147483648
	else
		v9 = false
	end

	assert(v9, "invalid dimensions")
	assert(v6 == 0, "invalid compression method")
	assert(v7 == 0, "invalid filter method")
	assert(v8 == 0 or v8 == 1, "invalid interlace method")
	local v10 = v[colorType]
	assert(v10 ~= nil, "invalid color type")
	assert(table.find(v10, bitDepth) ~= nil, "invalid bit depth")
	return {
		width = width,
		height = height,
		bitDepth = bitDepth,
		colorType = colorType,
		interlaced = v8 == 1
	}
end

return read