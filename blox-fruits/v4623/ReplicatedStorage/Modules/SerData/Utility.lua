local Utility = {}

function Utility.newReader(buf: buffer)
	local total = 0
	return function(bitCount: number)
		local v = total
		total += bitCount
		return buffer.readbits(buf, v, bitCount)
	end
end

function Utility.newWriter()
	local total = 0
	local v = 64
	local buf = buffer.create(v)
	return function(bitCount: number, value: number)
		local v2 = math.ceil((total + bitCount) / 8)

		if v < v2 then
			while true do
				local v3 = math.ceil((total + bitCount) / 8)

				if not (v < v3) then
					break
				end

				v *= 2
			end

			local buf2 = buffer.create(v)
			buffer.copy(buf2, 0, buf, 0)
			buf = buf2
		end

		local v3 = total
		total += bitCount
		buffer.writebits(buf, v3, bitCount, value)
		return buf, total
	end
end

function Utility.Trim(source: buffer, p: number)
	local v = math.ceil(p / 8)
	local buf = buffer.create(v)
	buffer.copy(buf, 0, source, 0, v)
	return buf
end

return Utility