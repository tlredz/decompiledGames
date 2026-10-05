local function CompareBuffer(buf: buffer, buf2: buffer)
	local v = buffer.len(buf)
	local v2 = buffer.len(buf2)

	for i = 0, math.min(v, v2) - 1 do
		local v3 = buffer.readu8(buf, i)
		local v4 = buffer.readu8(buf2, i)

		if v3 ~= v4 then
			return v3 - v4
		end
	end

	return v - v2
end

return CompareBuffer