return {
	new = function()
		local buf = buffer.create(100)
		local total = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resize(p: number)
			if p <= buffer.len(buf) then
				return
			end

			local v2 = math.ceil(p * 1.5)
			local buf2 = buffer.create(v2)
			buffer.copy(buf2, 0, buf)
			buf = buf2
		end

		return {
			writeu8 = function(value: number)
				resize(total + 1) -- equivalent call inferred; original call site unknown
				buffer.writeu8(buf, total, value)
				total += 1
			end,
			writeu16 = function(value: number)
				resize(total + 2) -- equivalent call inferred; original call site unknown
				buffer.writeu16(buf, total, value)
				total += 2
			end,
			writeu32 = function(value: number)
				resize(total + 4) -- equivalent call inferred; original call site unknown
				buffer.writeu32(buf, total, value)
				total += 4
			end,
			writei16 = function(value: number)
				resize(total + 2) -- equivalent call inferred; original call site unknown
				buffer.writei16(buf, total, value)
				total += 2
			end,
			writef32 = function(value: number)
				resize(total + 4) -- equivalent call inferred; original call site unknown
				buffer.writef32(buf, total, value)
				total += 4
			end,
			writef64 = function(value: number)
				resize(total + 8) -- equivalent call inferred; original call site unknown
				buffer.writef64(buf, total, value)
				total += 8
			end,
			writestring = function(str: string)
				resize(total + #str) -- equivalent call inferred; original call site unknown
				buffer.writestring(buf, total, str)
				total += #str
			end,
			finish = function()
				local buf2 = buffer.create(total)
				buffer.copy(buf2, 0, buf, 0, total)
				return buf2
			end
		}
	end
}