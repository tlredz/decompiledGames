function BufferToHex(buf: buffer)
	local v = buffer.len(buf)
	local buf2 = buffer.create(v * 2)

	for i = 0, v - 1 do
		local v2 = buffer.readu8(buf, i)
		local v3 = bit32.rshift(v2, 4)
		local v4 = bit32.band(v2, 15)
		local v6

		if v3 < 10 then
			v6 = v3 + 48
		else
			v6 = v3 + 87
		end

		buffer.writeu8(buf2, i * 2 + 0, v6)
		local v8

		if v4 < 10 then
			v8 = v4 + 48
		else
			v8 = v4 + 87
		end

		buffer.writeu8(buf2, i * 2 + 1, v8)
	end

	return buffer.tostring(buf2)
end

return BufferToHex