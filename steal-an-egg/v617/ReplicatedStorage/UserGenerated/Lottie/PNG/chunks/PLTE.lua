require(script.Parent.Parent.Types)

local function read(buf: buffer, p, p2)
	assert(p.length % 3 == 0, "malformed PLTE chunk")
	local v = p.length / 3
	assert(v > 0, "no entries in PLTE")
	assert(v <= 256, "too many entries in PLTE")
	assert(v <= 2 ^ p2.bitDepth, "too many entries in PLTE for bit depth")
	local colors = table.create(v)
	local offset = p.offset

	for i = 1, v do
		colors[i] = {
			r = buffer.readu8(buf, offset),
			g = buffer.readu8(buf, offset + 1),
			b = buffer.readu8(buf, offset + 2),
			a = 255
		}
		offset += 3
	end

	return {
		colors = colors
	}
end

return read