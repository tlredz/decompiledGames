local v = table.create(90)
local v2 = table.create(90)

for i = 1, 91 do
	v[i - 1] = string.byte(
		"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&()*+,./:;<=>?@[]^_`{|}~'",
		i,
		i
	)
	v2[string.byte("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&()*+,./:;<=>?@[]^_`{|}~'", i, i)] = i - 1
end

local v3 = table.create(5)

local function stringBuilder(list)
	local count = #list

	for i = 1, count, 4096 do
		table.insert(v3, (string.char(table.unpack(list, i, (math.min(i + 4095, count))))))
	end

	local joined = table.concat(v3)
	table.clear(v3)
	return joined
end

return table.freeze({
	encodeBuffer = function(buf: buffer, flag: boolean?)
		local buf2 = buffer.create(buffer.len(buf) * 2)
		local v4 = 0
		local v5 = 0
		local total = 0

		for i = 0, buffer.len(buf) - 1 do
			v5 = bit32.bor(v5, (bit32.lshift(buffer.readu8(buf, i), v4)))
			v4 += 8

			if not (v4 > 13) then
				continue
			end

			local v6 = bit32.band(v5, 8191)

			if v6 > 88 then
				v5 = bit32.rshift(v5, 13)
				v4 -= 13
			else
				v6 = bit32.band(v5, 16383)
				v5 = bit32.rshift(v5, 14)
				v4 -= 14
			end

			buffer.writeu16(buf2, total, bit32.lshift(v[v6 // 91], 8) + v[v6 % 91])
			total += 2
		end

		if v4 > 0 then
			buffer.writeu8(buf2, total, v[v5 % 91])
			total += 1

			if v4 > 7 or v5 > 90 then
				buffer.writeu8(buf2, total, v[v5 // 91])
				total += 1
			end
		end

		if flag then
			return buf2
		end

		local buf3 = buffer.create(total)
		buffer.copy(buf3, 0, buf2, 0, total)
		return buf3
	end,
	decodeBuffer = function(buf: buffer, flag: boolean?)
		local buf2 = buffer.create(buffer.len(buf) * 2)
		local v4 = -1
		local v5 = 0
		local v6 = 0
		local count = 0

		for i = 0, buffer.len(buf) - 1 do
			local v7 = buffer.readu8(buf, i)

			if not v2[v7] then
				continue
			end

			if v4 == -1 then
				v4 = v2[v7]
			else
				local v8 = v4 + v2[v7] * 91
				v6 = bit32.bor(v6, (bit32.lshift(v8, v5)))

				if bit32.band(v8, 8191) > 88 then
					v5 += 13
				else
					v5 += 14
				end

				while v5 > 7 do
					buffer.writeu8(buf2, count, v6 % 256)
					count += 1
					v6 = bit32.rshift(v6, 8)
					v5 -= 8
				end

				v4 = -1
			end
		end

		if v4 ~= -1 then
			buffer.writeu8(buf2, count, bit32.bor(v6, (bit32.lshift(v4, v5))) % 256)
			count += 1
		end

		if flag then
			return buf2
		end

		local buf3 = buffer.create(count)
		buffer.copy(buf3, 0, buf2, 0, count)
		return buf3
	end,
	encodeBytes = function(list)
		local result = table.create((math.ceil(#list * 1.2308)))
		local v4 = 0
		local v5 = 0
		local total = 1

		for _, v6 in list do
			v5 = bit32.bor(v5, (bit32.lshift(v6, v4)))
			v4 += 8

			if not (v4 > 13) then
				continue
			end

			local v7 = bit32.band(v5, 8191)

			if v7 > 88 then
				v5 = bit32.rshift(v5, 13)
				v4 -= 13
			else
				v7 = bit32.band(v5, 16383)
				v5 = bit32.rshift(v5, 14)
				v4 -= 14
			end

			result[total] = v[v7 % 91]
			result[total + 1] = v[math.floor(v7 / 91)]
			total += 2
		end

		if v4 > 0 then
			result[total] = v[v5 % 91]

			if v4 > 7 or v5 > 90 then
				result[total + 1] = v[math.floor(v5 / 91)]
			end
		end

		return result
	end,
	decodeBytes = function(list)
		local result = table.create((math.ceil(#list / 1.2308)))
		local v4 = -1
		local v5 = 0
		local v6 = 0
		local v7 = 1

		for _, v8 in list do
			if not v2[v8] then
				continue
			end

			if v4 == -1 then
				v4 = v2[v8]
			else
				local v9 = v4 + v2[v8] * 91
				v6 = bit32.bor(v6, (bit32.lshift(v9, v5)))

				if bit32.band(v9, 8191) > 88 then
					v5 += 13
				else
					v5 += 14
				end

				while v5 > 7 do
					result[v7] = v6 % 256
					v7 += 1
					v6 = bit32.rshift(v6, 8)
					v5 -= 8
				end

				v4 = -1
			end
		end

		if v4 ~= -1 then
			result[v7] = bit32.bor(v6, (bit32.lshift(v4, v5))) % 256
		end

		return result
	end,
	encodeString = function(value: string)
		local v4 = table.create(#value * 1.2308)
		local v5 = 0
		local v6 = 0
		local total = 1

		for i = 1, #value do
			v6 = bit32.bor(v6, (bit32.lshift(string.byte(value, i), v5)))
			v5 += 8

			if not (v5 > 13) then
				continue
			end

			local v7 = bit32.band(v6, 8191)

			if v7 > 88 then
				v6 = bit32.rshift(v6, 13)
				v5 -= 13
			else
				v7 = bit32.band(v6, 16383)
				v6 = bit32.rshift(v6, 14)
				v5 -= 14
			end

			v4[total] = v[v7 % 91]
			v4[total + 1] = v[math.floor(v7 / 91)]
			total += 2
		end

		if v5 > 0 then
			v4[total] = v[v6 % 91]

			if v5 > 7 or v6 > 90 then
				v4[total + 1] = v[math.floor(v6 / 91)]
			end
		end

		return (stringBuilder(v4))
	end,
	decodeString = function(value: string)
		local v4 = table.create((math.ceil(#value / 1.2308)))
		local v5 = -1
		local v6 = 0
		local v7 = 0
		local v8 = 1

		for i = 1, #value do
			local v9 = string.byte(value, i)

			if not v2[v9] then
				continue
			end

			if v5 == -1 then
				v5 = v2[v9]
			else
				local v10 = v5 + v2[v9] * 91
				v7 = bit32.bor(v7, (bit32.lshift(v10, v6)))

				if bit32.band(v10, 8191) > 88 then
					v6 += 13
				else
					v6 += 14
				end

				while v6 > 7 do
					v4[v8] = v7 % 256
					v8 += 1
					v7 = bit32.rshift(v7, 8)
					v6 -= 8
				end

				v5 = -1
			end
		end

		if v5 ~= -1 then
			v4[v8] = bit32.bor(v7, (bit32.lshift(v5, v6))) % 256
		end

		return (stringBuilder(v4))
	end
})