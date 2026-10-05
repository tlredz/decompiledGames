return {
	new = function(buf: buffer)
		local total = 0
		return {
			readu8 = function()
				local v = buffer.readu8(buf, total)
				total += 1
				return v
			end,
			readu16 = function()
				local v = buffer.readu16(buf, total)
				total += 2
				return v
			end,
			readu32 = function()
				local v = buffer.readu32(buf, total)
				total += 4
				return v
			end,
			readi16 = function()
				local v = buffer.readi16(buf, total)
				total += 2
				return v
			end,
			readf32 = function()
				local v = buffer.readf32(buf, total)
				total += 4
				return v
			end,
			readf64 = function()
				local v = buffer.readf64(buf, total)
				total += 8
				return v
			end,
			readstring = function(count: number)
				local v = buffer.readstring(buf, total, count)
				total += count
				return v
			end
		}
	end
}