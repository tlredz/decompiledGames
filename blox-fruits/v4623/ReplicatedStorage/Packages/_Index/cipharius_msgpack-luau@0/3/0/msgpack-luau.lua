local MsgpackLuau = {}
local band = bit32.band
local bor = bit32.bor
local create = buffer.create
local len = buffer.len
local copy = buffer.copy
local readstring = buffer.readstring
local writestring = buffer.writestring
local readu8 = buffer.readu8
local readi8 = buffer.readi8
local writeu8 = buffer.writeu8
local writei8 = buffer.writei8
local lshift = bit32.lshift
local extract = bit32.extract
local _ = math.ldexp
local _ = math.frexp
local floor = math.floor
local modf = math.modf
local sign = math.sign
local _ = string.sub
local _ = string.char
local byte = string.byte
local _ = table.concat
local create2 = table.create

local function reverse(buf: buffer, offset: number, p: number)
	for i = 1, p // 2 do
		local v2 = readu8(buf, offset + i - 1)
		copy(buf, offset + i - 1, buf, offset + p - i, 1)
		writeu8(buf, offset + p - i, v2)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writeu16(buf: buffer, offset: number, value: number)
	buffer.writeu16(buf, offset, value)
	local v2 = readu8(buf, offset + 1 - 1)
	copy(buf, offset + 1 - 1, buf, offset + 2 - 1, 1)
	writeu8(buf, offset + 2 - 1, v2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writei16(buf: buffer, offset: number, value: number)
	buffer.writei16(buf, offset, value)
	local v2 = readu8(buf, offset + 1 - 1)
	copy(buf, offset + 1 - 1, buf, offset + 2 - 1, 1)
	writeu8(buf, offset + 2 - 1, v2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writeu32(buf: buffer, offset: number, value: number)
	buffer.writeu32(buf, offset, value)

	for i = 1, 2 do
		local v2 = readu8(buf, offset + i - 1)
		copy(buf, offset + i - 1, buf, offset + 4 - i, 1)
		writeu8(buf, offset + 4 - i, v2)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writei32(buf: buffer, offset: number, value: number)
	buffer.writei32(buf, offset, value)

	for i = 1, 2 do
		local v2 = readu8(buf, offset + i - 1)
		copy(buf, offset + i - 1, buf, offset + 4 - i, 1)
		writeu8(buf, offset + 4 - i, v2)
	end
end

local function writef32(buf: buffer, offset: number, value: number)
	buffer.writef32(buf, offset, value)

	for i = 1, 2 do
		local v2 = readu8(buf, offset + i - 1)
		copy(buf, offset + i - 1, buf, offset + 4 - i, 1)
		writeu8(buf, offset + 4 - i, v2)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writef64(buf: buffer, offset: number, value: number)
	buffer.writef64(buf, offset, value)
	reverse(buf, offset, 8)
end

local function readu16(buf: buffer, offset: number)
	local v2 = readu8(buf, offset + 1 - 1)
	copy(buf, offset + 1 - 1, buf, offset + 2 - 1, 1)
	writeu8(buf, offset + 2 - 1, v2)
	return (buffer.readu16(buf, offset))
end

local function readi16(buf: buffer, offset: number)
	local v2 = readu8(buf, offset + 1 - 1)
	copy(buf, offset + 1 - 1, buf, offset + 2 - 1, 1)
	writeu8(buf, offset + 2 - 1, v2)
	return (buffer.readi16(buf, offset))
end

local function readu32(buf: buffer, offset: number)
	for i = 1, 2 do
		local v2 = readu8(buf, offset + i - 1)
		copy(buf, offset + i - 1, buf, offset + 4 - i, 1)
		writeu8(buf, offset + 4 - i, v2)
	end

	return (buffer.readu32(buf, offset))
end

local function readi32(buf: buffer, offset: number)
	for i = 1, 2 do
		local v2 = readu8(buf, offset + i - 1)
		copy(buf, offset + i - 1, buf, offset + 4 - i, 1)
		writeu8(buf, offset + 4 - i, v2)
	end

	return (buffer.readi32(buf, offset))
end

local function readf32(buf: buffer, offset: number)
	for i = 1, 2 do
		local v2 = readu8(buf, offset + i - 1)
		copy(buf, offset + i - 1, buf, offset + 4 - i, 1)
		writeu8(buf, offset + 4 - i, v2)
	end

	return (buffer.readf32(buf, offset))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function readf64(buf: buffer, offset: number)
	reverse(buf, offset, 8)
	return (buffer.readf64(buf, offset))
end

local parse

parse = function(buf: buffer, p: number)
	local v = readu8(buf, p)

	if v == 192 then
		return nil, p + 1
	elseif v == 194 then
		return false, p + 1
	elseif v == 195 then
		return true, p + 1
	end

	if v == 196 then
		local v3 = readu8(buf, p + 1)
		local buf2 = create(v3)
		copy(buf2, 0, buf, p + 2, v3)
		return buf2, p + 2 + v3
	elseif v == 197 then
		local v2 = p + 1
		local v4 = readu8(buf, v2 + 1 - 1)
		copy(buf, v2 + 1 - 1, buf, v2 + 2 - 1, 1)
		writeu8(buf, v2 + 2 - 1, v4)
		local v6 = buffer.readu16(buf, v2)
		local buf2 = create(v6)
		copy(buf2, 0, buf, p + 3, v6)
		return buf2, p + 3 + v6
	elseif v == 198 then
		local v2 = p + 1

		for i = 1, 2 do
			local v4 = readu8(buf, v2 + i - 1)
			copy(buf, v2 + i - 1, buf, v2 + 4 - i, 1)
			writeu8(buf, v2 + 4 - i, v4)
		end

		local v3 = buffer.readu32(buf, v2)
		local buf2 = create(v3)
		copy(buf2, 0, buf, p + 5, v3)
		return buf2, p + 5 + v3
	elseif v == 199 then
		local v3 = readu8(buf, p + 1)
		local buf2 = create(v3)
		copy(buf2, 0, buf, p + 3, v3)
		return MsgpackLuau.Extension.new(readu8(buf, p + 2), buf2), p + 2 + v3
	elseif v == 200 then
		local v2 = p + 1
		local v4 = readu8(buf, v2 + 1 - 1)
		copy(buf, v2 + 1 - 1, buf, v2 + 2 - 1, 1)
		writeu8(buf, v2 + 2 - 1, v4)
		local v6 = buffer.readu16(buf, v2)
		local buf2 = create(v6)
		copy(buf2, 0, buf, p + 4, v6)
		return MsgpackLuau.Extension.new(readu8(buf, p + 3), buf2), p + 3 + v6
	elseif v == 201 then
		local v2 = p + 1

		for i = 1, 2 do
			local v4 = readu8(buf, v2 + i - 1)
			copy(buf, v2 + i - 1, buf, v2 + 4 - i, 1)
			writeu8(buf, v2 + 4 - i, v4)
		end

		local v3 = buffer.readu32(buf, v2)
		local buf2 = create(v3)
		copy(buf2, 0, buf, p + 6, v3)
		return MsgpackLuau.Extension.new(readu8(buf, p + 5), buf2), p + 5 + v3
	elseif v == 202 then
		local v2 = p + 1

		for i = 1, 2 do
			local v4 = readu8(buf, v2 + i - 1)
			copy(buf, v2 + i - 1, buf, v2 + 4 - i, 1)
			writeu8(buf, v2 + 4 - i, v4)
		end

		return buffer.readf32(buf, v2), p + 5
	elseif v == 203 then
		return readf64(buf, p + 1), p + 9
	else
		if v == 204 then
			return readu8(buf, p + 1), p + 2
		end

		if v == 205 then
			local v2 = p + 1
			local v4 = readu8(buf, v2 + 1 - 1)
			copy(buf, v2 + 1 - 1, buf, v2 + 2 - 1, 1)
			writeu8(buf, v2 + 2 - 1, v4)
			return buffer.readu16(buf, v2), p + 3
		elseif v == 206 then
			local v2 = p + 1

			for i = 1, 2 do
				local v4 = readu8(buf, v2 + i - 1)
				copy(buf, v2 + i - 1, buf, v2 + 4 - i, 1)
				writeu8(buf, v2 + 4 - i, v4)
			end

			return buffer.readu32(buf, v2), p + 5
		elseif v == 207 then
			local new = MsgpackLuau.UInt64.new
			local v2 = p + 1

			for i = 1, 2 do
				local v4 = readu8(buf, v2 + i - 1)
				copy(buf, v2 + i - 1, buf, v2 + 4 - i, 1)
				writeu8(buf, v2 + 4 - i, v4)
			end

			local v3 = buffer.readu32(buf, v2)
			local v4 = p + 5

			for i = 1, 2 do
				local v6 = readu8(buf, v4 + i - 1)
				copy(buf, v4 + i - 1, buf, v4 + 4 - i, 1)
				writeu8(buf, v4 + 4 - i, v6)
			end

			return new(v3, (buffer.readu32(buf, v4))), p + 9
		else
			if v == 208 then
				return readi8(buf, p + 1), p + 2
			end

			if v == 209 then
				local v2 = p + 1
				local v4 = readu8(buf, v2 + 1 - 1)
				copy(buf, v2 + 1 - 1, buf, v2 + 2 - 1, 1)
				writeu8(buf, v2 + 2 - 1, v4)
				return buffer.readi16(buf, v2), p + 3
			elseif v == 210 then
				local v2 = p + 1

				for i = 1, 2 do
					local v4 = readu8(buf, v2 + i - 1)
					copy(buf, v2 + i - 1, buf, v2 + 4 - i, 1)
					writeu8(buf, v2 + 4 - i, v4)
				end

				return buffer.readi32(buf, v2), p + 5
			elseif v == 211 then
				local new = MsgpackLuau.Int64.new
				local v2 = p + 1

				for i = 1, 2 do
					local v4 = readu8(buf, v2 + i - 1)
					copy(buf, v2 + i - 1, buf, v2 + 4 - i, 1)
					writeu8(buf, v2 + 4 - i, v4)
				end

				local v3 = buffer.readu32(buf, v2)
				local v4 = p + 5

				for i = 1, 2 do
					local v6 = readu8(buf, v4 + i - 1)
					copy(buf, v4 + i - 1, buf, v4 + 4 - i, 1)
					writeu8(buf, v4 + 4 - i, v6)
				end

				return new(v3, (buffer.readu32(buf, v4))), p + 9
			elseif v == 212 then
				local buf2 = create(1)
				copy(buf2, 0, buf, p + 2, 1)
				return MsgpackLuau.Extension.new(readu8(buf, p + 1), buf2), p + 3
			elseif v == 213 then
				local buf2 = create(2)
				copy(buf2, 0, buf, p + 2, 2)
				return MsgpackLuau.Extension.new(readu8(buf, p + 1), buf2), p + 4
			elseif v == 214 then
				local buf2 = create(4)
				copy(buf2, 0, buf, p + 2, 4)
				return MsgpackLuau.Extension.new(readu8(buf, p + 1), buf2), p + 6
			elseif v == 215 then
				local buf2 = create(8)
				copy(buf2, 0, buf, p + 2, 8)
				return MsgpackLuau.Extension.new(readu8(buf, p + 1), buf2), p + 10
			elseif v == 216 then
				local buf2 = create(16)
				copy(buf2, 0, buf, p + 2, 16)
				return MsgpackLuau.Extension.new(readu8(buf, p + 1), buf2), p + 18
			elseif v == 217 then
				local v3 = readu8(buf, p + 1)
				return readstring(buf, p + 2, v3), p + 2 + v3
			elseif v == 218 then
				local v2 = p + 1
				local v4 = readu8(buf, v2 + 1 - 1)
				copy(buf, v2 + 1 - 1, buf, v2 + 2 - 1, 1)
				writeu8(buf, v2 + 2 - 1, v4)
				local v6 = buffer.readu16(buf, v2)
				return readstring(buf, p + 3, v6), p + 3 + v6
			elseif v == 219 then
				local v2 = p + 1

				for i = 1, 2 do
					local v4 = readu8(buf, v2 + i - 1)
					copy(buf, v2 + i - 1, buf, v2 + 4 - i, 1)
					writeu8(buf, v2 + 4 - i, v4)
				end

				local v3 = buffer.readu32(buf, v2)
				return readstring(buf, p + 5, v3), p + 5 + v3
			elseif v == 220 then
				local v2 = p + 1
				local v4 = readu8(buf, v2 + 1 - 1)
				copy(buf, v2 + 1 - 1, buf, v2 + 2 - 1, 1)
				writeu8(buf, v2 + 2 - 1, v4)
				local v6 = buffer.readu16(buf, v2)
				local result = create2(v6)
				local v7 = p + 3

				for i = 1, v6 do
					local v8
					v8, v7 = parse(buf, v7)
					result[i] = v8
				end

				return result, v7
			elseif v == 221 then
				local v2 = p + 1

				for i = 1, 2 do
					local v4 = readu8(buf, v2 + i - 1)
					copy(buf, v2 + i - 1, buf, v2 + 4 - i, 1)
					writeu8(buf, v2 + 4 - i, v4)
				end

				local v3 = buffer.readu32(buf, v2)
				local result = create2(v3)
				local v4 = p + 5

				for i = 1, v3 do
					local v5
					v5, v4 = parse(buf, v4)
					result[i] = v5
				end

				return result, v4
			elseif v == 222 then
				local v2 = p + 1
				local v4 = readu8(buf, v2 + 1 - 1)
				copy(buf, v2 + 1 - 1, buf, v2 + 2 - 1, 1)
				writeu8(buf, v2 + 2 - 1, v4)
				local v6 = buffer.readu16(buf, v2)
				local v7 = p + 3
				local result = {}

				for _ = 1, v6 do
					local v8, v9 = parse(buf, v7)
					local v10
					v10, v7 = parse(buf, v9)
					result[v8] = v10
				end

				return result, v7
			elseif v == 223 then
				local v2 = p + 1

				for i = 1, 2 do
					local v4 = readu8(buf, v2 + i - 1)
					copy(buf, v2 + i - 1, buf, v2 + 4 - i, 1)
					writeu8(buf, v2 + 4 - i, v4)
				end

				local v3 = buffer.readu32(buf, v2)
				local v4 = p + 5
				local result = {}

				for _ = 1, v3 do
					local v5, v6 = parse(buf, v4)
					local v7
					v7, v4 = parse(buf, v6)
					result[v5] = v7
				end

				return result, v4
			else
				if v >= 224 then
					return v - 256, p + 1
				end

				if v <= 127 then
					return v, p + 1
				end

				if v - 128 <= 15 then
					local v2 = band(v, 15)
					local v3 = p + 1
					local result = {}

					for _ = 1, v2 do
						local v4, v5 = parse(buf, v3)
						local v6
						v6, v3 = parse(buf, v5)
						result[v4] = v6
					end

					return result, v3
				elseif v - 144 <= 15 then
					local v2 = band(v, 15)
					local result = create2(v2)
					local v3 = p + 1

					for i = 1, v2 do
						local v4
						v4, v3 = parse(buf, v3)
						result[i] = v4
					end

					return result, v3
				elseif v - 160 <= 31 then
					local v2 = v - 160
					return readstring(buf, p + 1, v2), p + 1 + v2
				else
					error("Not all decoder cases are handled, report as bug to msgpack-luau maintainer")
				end
			end
		end
	end
end

local computeLength

computeLength = function(list, p)
	local typeName = type(list)

	if not (list ~= nil and typeName ~= "boolean") then
		return 1
	end

	if typeName == "string" then
		local count = #list

		if count <= 31 then
			return count + 1
		end

		if count <= 255 then
			return count + 2
		end

		if count <= 65535 then
			return count + 3
		end

		if count <= 4294967295 then
			return count + 5
		else
			error("Could not encode - too long string")
		end
	elseif typeName == "buffer" then
		local v = len(list)

		if v <= 255 then
			return 2 + v
		end

		if v <= 65535 then
			return 3 + v
		end

		if v <= 4294967295 then
			return 5 + v
		else
			error("Could not encode - too long binary buffer")
		end
	elseif typeName == "number" then
		if list == 0 then
			return 1
		end

		if list ~= list then
			return 5
		end

		if list == 1e999 then
			return 5
		elseif list == -1e999 then
			return 5
		end

		local v, v2 = modf(list)
		local v3 = sign(list)

		if v2 ~= 0 or v > 4294967295 or v < -2147483648 then
			return 9
		end

		if v3 > 0 then
			if v <= 127 then
				return 1
			end

			if v <= 255 then
				return 2
			end

			if v <= 65535 then
				return 3
			end

			if v <= 4294967295 then
				return 5
			end
		else
			if v >= -32 then
				return 1
			end

			if v >= -128 then
				return 2
			end

			if v >= -32768 then
				return 3
			end

			if v >= -2147483648 then
				return 5
			end
		end

		error(string.format("Could not encode - unhandled number \"%s\"", (typeof(list))))
	elseif typeName == "table" then
		local _msgpackType = list._msgpackType

		if _msgpackType then
			if _msgpackType == MsgpackLuau.Int64 or _msgpackType == MsgpackLuau.UInt64 then
				return 9
			end

			if _msgpackType == MsgpackLuau.Extension then
				local v = len(list.data)

				if v == 1 then
					return 3
				elseif v == 2 then
					return 4
				elseif v == 4 then
					return 6
				elseif v == 8 then
					return 10
				elseif v == 16 then
					return 18
				end

				if v <= 255 then
					return 3 + v
				end

				if v <= 65535 then
					return 4 + v
				end

				if v <= 4294967295 then
					return 6 + v
				else
					error("Could not encode - too long extension data")
				end
			end
		end

		if p[list] then
			error("Can not serialize cyclic table")
		else
			p[list] = true
		end

		local count = #list
		local count2 = 0

		for _, _ in pairs(list) do
			count2 += 1
		end

		local v = nil

		if count2 <= 15 then
			v = 1
		elseif count2 <= 65535 then
			v = 3
		elseif count2 <= 4294967295 then
			v = 5
		elseif count == count2 then
			error("Could not encode - too long array")
		else
			error("Could not encode - too long map")
		end

		if count == count2 then
			local total = 0

			for _, v2 in ipairs(list) do
				total += computeLength(v2, p)
			end

			return v + total
		else
			local v2 = 0

			for k, v3 in pairs(list) do
				v2 = v2 + computeLength(k, p) + computeLength(v3, p)
			end

			return v + v2
		end
	end

	error(string.format("Could not encode - unsupported datatype \"%s\"", (typeof(list))))
end

local v = {
	[1] = 212,
	[2] = 213,
	[4] = 214,
	[8] = 215,
	[16] = 216
}
local encode

encode = function(buf: buffer, p: number, list)
	local typeName = type(list)

	if list == nil then
		writestring(buf, p, "\192")
		return p + 1
	elseif list == false then
		writestring(buf, p, "\194")
		return p + 1
	elseif list == true then
		writestring(buf, p, "\195")
		return p + 1
	end

	if typeName == "string" then
		local count = #list

		if count <= 31 then
			writeu8(buf, p, (bor(160, count)))
			writestring(buf, p + 1, list)
			return p + 1 + count
		elseif count <= 255 then
			writeu8(buf, p, 217)
			writeu8(buf, p + 1, count)
			writestring(buf, p + 2, list)
			return p + 2 + count
		elseif count <= 65535 then
			writeu8(buf, p, 218)
			writeu16(buf, p + 1, count) -- equivalent call inferred; original call site unknown
			writestring(buf, p + 3, list)
			return p + 3 + count
		elseif count <= 4294967295 then
			writeu8(buf, p, 219)
			writeu32(buf, p + 1, count) -- equivalent call inferred; original call site unknown
			writestring(buf, p + 5, list)
			return p + 5 + count
		else
			error("Could not encode - too long string")
		end
	elseif typeName == "buffer" then
		local v2 = len(list)

		if v2 <= 255 then
			writeu8(buf, p, 196)
			writeu8(buf, p + 1, v2)
			copy(buf, p + 2, list)
			return p + 2 + v2
		elseif v2 <= 65535 then
			writeu8(buf, p, 197)
			writeu16(buf, p + 1, v2) -- equivalent call inferred; original call site unknown
			copy(buf, p + 3, list)
			return p + 3 + v2
		elseif v2 <= 4294967295 then
			writeu8(buf, p, 198)
			writeu32(buf, p + 1, v2) -- equivalent call inferred; original call site unknown
			copy(buf, p + 5, list)
			return p + 5 + v2
		else
			error("Could not encode - too long binary buffer")
		end
	elseif typeName == "number" then
		if list == 0 then
			writeu8(buf, p, 0)
			return p + 1
		end

		if list ~= list then
			writestring(buf, p, "\202\127\128\0\1")
			return p + 5
		end

		if list == 1e999 then
			writestring(buf, p, "\202\127\128\0\0")
			return p + 5
		elseif list == -1e999 then
			writestring(buf, p, "\202\255\128\0\0")
			return p + 5
		end

		local v2, v3 = modf(list)
		local v4 = sign(list)

		if v3 == 0 and not (v2 > 4294967295 or v2 < -2147483648) then
			if v4 > 0 then
				if v2 <= 127 then
					writeu8(buf, p, v2)
					return p + 1
				end

				if v2 <= 255 then
					writeu8(buf, p, 204)
					writeu8(buf, p + 1, v2)
					return p + 2
				elseif v2 <= 65535 then
					writeu8(buf, p, 205)
					writeu16(buf, p + 1, v2) -- equivalent call inferred; original call site unknown
					return p + 3
				elseif v2 <= 4294967295 then
					writeu8(buf, p, 206)
					writeu32(buf, p + 1, v2) -- equivalent call inferred; original call site unknown
					return p + 5
				end
			elseif v2 >= -32 then
				writeu8(buf, p, (bor(224, (extract(v2, 0, 5)))))
				return p + 1
			elseif v2 >= -128 then
				writeu8(buf, p, 208)
				writei8(buf, p + 1, v2)
				return p + 2
			elseif v2 >= -32768 then
				writeu8(buf, p, 209)
				writei16(buf, p + 1, v2) -- equivalent call inferred; original call site unknown
				return p + 3
			elseif v2 >= -2147483648 then
				writeu8(buf, p, 210)
				writei32(buf, p + 1, v2) -- equivalent call inferred; original call site unknown
				return p + 5
			end

			error(string.format("Could not encode - unhandled number \"%s\"", (typeof(list))))
		else
			writeu8(buf, p, 203)
			writef64(buf, p + 1, list) -- equivalent call inferred; original call site unknown
			return p + 9
		end
	elseif typeName == "table" then
		local _msgpackType = list._msgpackType

		if _msgpackType then
			if _msgpackType == MsgpackLuau.Int64 or _msgpackType == MsgpackLuau.UInt64 then
				writeu8(buf, p, _msgpackType == MsgpackLuau.UInt64 and 207 or 211)
				writeu32(buf, p + 1, list.mostSignificantPart) -- equivalent call inferred; original call site unknown
				writeu32(buf, p + 5, list.leastSignificantPart) -- equivalent call inferred; original call site unknown
				return p + 9
			elseif _msgpackType == MsgpackLuau.Extension then
				local v2 = len(list.data)
				local v3 = v[v2]

				if v3 then
					writeu8(buf, p, v3)
					writeu8(buf, p + 1, list.type)
					copy(buf, p + 2, list.data)
					return p + 2 + v2
				elseif v2 <= 255 then
					writeu8(buf, p, 199)
					writeu8(buf, p + 1, v2)
					writeu8(buf, p + 2, list.type)
					copy(buf, p + 3, list.data)
					return p + 3 + v2
				elseif v2 <= 65535 then
					writeu8(buf, p, 200)
					writeu16(buf, p + 1, v2) -- equivalent call inferred; original call site unknown
					writeu8(buf, p + 3, list.type)
					copy(buf, p + 4, list.data)
					return p + 4 + v2
				elseif v2 <= 4294967295 then
					writeu8(buf, p, 201)
					writeu32(buf, p + 1, v2) -- equivalent call inferred; original call site unknown
					writeu8(buf, p + 5, list.type)
					copy(buf, p + 6, list.data)
					return p + 6 + v2
				else
					error("Could not encode - too long extension data")
				end
			end
		end

		local count = #list
		local count2 = 0

		for _, _ in pairs(list) do
			count2 += 1
		end

		if count == count2 then
			if count <= 15 then
				writeu8(buf, p, (bor(144, count2)))
				p += 1
			elseif count <= 65535 then
				writeu8(buf, p, 220)
				writeu16(buf, p + 1, count) -- equivalent call inferred; original call site unknown
				p += 3
			elseif count <= 4294967295 then
				writeu8(buf, p, 221)
				writeu32(buf, p + 1, count) -- equivalent call inferred; original call site unknown
				p += 5
			else
				error("Could not encode - too long array")
			end

			for _, v2 in ipairs(list) do
				p = encode(buf, p, v2)
			end
		else
			if count2 <= 15 then
				writeu8(buf, p, (bor(128, count2)))
				p += 1
			elseif count2 <= 65535 then
				writeu8(buf, p, 222)
				writeu16(buf, p + 1, count2) -- equivalent call inferred; original call site unknown
				p += 3
			elseif count2 <= 4294967295 then
				writeu8(buf, p, 223)
				writeu32(buf, p + 1, count2) -- equivalent call inferred; original call site unknown
				p += 5
			else
				error("Could not encode - too long map")
			end

			for k, v2 in pairs(list) do
				p = encode(buf, encode(buf, p, k), v2)
			end
		end

		return p
	end

	error(string.format("Could not encode - unsupported datatype \"%s\"", (typeof(list))))
end

MsgpackLuau.Int64 = {}

function MsgpackLuau.Int64.new(mostSignificantPart: number, leastSignificantPart: number)
	return {
		_msgpackType = MsgpackLuau.Int64,
		mostSignificantPart = mostSignificantPart,
		leastSignificantPart = leastSignificantPart
	}
end

MsgpackLuau.UInt64 = {}

function MsgpackLuau.UInt64.new(mostSignificantPart: number, leastSignificantPart: number)
	return {
		_msgpackType = MsgpackLuau.UInt64,
		mostSignificantPart = mostSignificantPart,
		leastSignificantPart = leastSignificantPart
	}
end

MsgpackLuau.Extension = {}

function MsgpackLuau.Extension.new(p: number, buf: buffer)
	return {
		_msgpackType = MsgpackLuau.Extension,
		type = p,
		data = buf
	}
end

function MsgpackLuau.utf8Encode(list: string)
	local v2 = math.ceil(#list * 1.1428571428571428)
	local buf = create(v2)
	local total = 0

	for i = 1, v2 do
		local v4 = floor(total / 8) + 1
		local v5 = total % 8
		local v6 = byte(list, v4)

		if v5 == 0 then
			local v8 = extract(v6, 1, 7)
			writeu8(buf, i - 1, v8)
		elseif v5 == 1 then
			local v8 = extract(v6, 0, 7)
			writeu8(buf, i - 1, v8)
		else
			local v8 = byte(list, v4 + 1) or 0
			local v17 = bor(lshift(extract(v6, 0, 8 - v5), v5 - 1), (extract(v8, 9 - v5, v5 - 1)))
			writeu8(buf, i - 1, v17)
		end

		total += 7
	end

	return buffer.tostring(buf)
end

function MsgpackLuau.utf8Decode(list: string)
	local v3 = floor(#list * 7 / 8)
	local buf = create(v3)
	local total = 0

	for i = 1, v3 do
		local v4 = total % 7
		local v7 = byte(list, floor(total / 7) + 1)
		local v10 = byte(list, floor(total / 7) + 2)
		local v19 = bor(lshift(extract(v7, 0, 7 - v4), v4 + 1), (extract(v10, 6 - v4, v4 + 1)))
		writeu8(buf, i - 1, v19)
		total += 8
	end

	return buffer.tostring(buf)
end

function MsgpackLuau.decode(str: string)
	if str == "" then
		error("Could not decode - input string is too short")
	end

	return (parse(buffer.fromstring(str), 0))
end

function MsgpackLuau.encode(p)
	local buf = create((computeLength(p, {})))
	encode(buf, 0, p)
	return buffer.tostring(buf)
end

return MsgpackLuau