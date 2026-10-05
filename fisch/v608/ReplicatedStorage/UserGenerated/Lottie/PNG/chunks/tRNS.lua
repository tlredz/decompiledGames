require(script.Parent.Parent.Types)

local function readU16(buf: buffer, offset: number, p: number)
	return (bit32.extract(
		bit32.bor(bit32.lshift(buffer.readu8(buf, offset), 8), (buffer.readu8(buf, offset + 1))),
		0,
		p
	))
end

local function read(buf: buffer, p, p2, p3)
	local gray = -1
	local red = -1
	local green = -1
	local blue = -1

	if p2.colorType == 0 then
		assert(p.length == 2, "invalid tRNS length for color type")
		local offset = p.offset
		local bitDepth = p2.bitDepth
		gray = bit32.extract(
			bit32.bor(bit32.lshift(buffer.readu8(buf, offset), 8), (buffer.readu8(buf, offset + 1))),
			0,
			bitDepth
		)
	elseif p2.colorType == 2 then
		assert(p.length == 6, "invalid tRNS length for color type")
		local offset = p.offset
		local bitDepth = p2.bitDepth
		red = bit32.extract(
			bit32.bor(bit32.lshift(buffer.readu8(buf, offset), 8), (buffer.readu8(buf, offset + 1))),
			0,
			bitDepth
		)
		local v5 = p.offset + 2
		local bitDepth2 = p2.bitDepth
		green = bit32.extract(
			bit32.bor(bit32.lshift(buffer.readu8(buf, v5), 8), (buffer.readu8(buf, v5 + 1))),
			0,
			bitDepth2
		)
		local v6 = p.offset + 4
		local bitDepth3 = p2.bitDepth
		blue = bit32.extract(
			bit32.bor(bit32.lshift(buffer.readu8(buf, v6), 8), (buffer.readu8(buf, v6 + 1))),
			0,
			bitDepth3
		)
	else
		local length = p.length
		assert(p3, "tRNS requires PLTE for color type")
		assert(length <= #p3.colors, "tRNS specified too many PLTE alphas")

		for i = 1, length do
			p3.colors[i].a = buffer.readu8(buf, p.offset + i - 1)
		end
	end

	return {
		gray = gray,
		red = red,
		green = green,
		blue = blue
	}
end

return read