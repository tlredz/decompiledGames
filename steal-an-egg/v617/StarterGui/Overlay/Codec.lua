local v = {
	VERSION = 2,
	PREVIEW_PAYLOAD = "D200000000000000",
	getIsUserId = function(value)
		return type(value) == "number" and value > 0 and value <= 9007199254740991 and value % 1 == 0
	end
}

function v.createUserIdPayload(p: number)
	assert(v.getIsUserId(p), "Expected a positive, exact Roblox UserId")
	local v2 = math.floor(p / 4294967296)
	local v3 = p % 4294967296
	return string.format("D2%06X%08X", v2, v3)
end

function v.getIsPayload(value)
	if type(value) ~= "string" or #value ~= 16 or not string.match(value, "^%x+$") then
		return false
	end

	local v2 = tonumber(string.sub(value, 3), 16)
	return string.upper((string.sub(value, 1, 2))) == "D2" and v2 ~= nil and v2 >= 0 and v2 <= 9007199254740991
end

function v.getCrc16(value: string)
	assert(v.getIsPayload(value), "Expected a 16-digit hexadecimal payload")
	local v2 = 65535

	for i = 1, #value, 2 do
		v2 = bit32.bxor(v2, (bit32.lshift(assert((tonumber(string.sub(value, i, i + 1), 16))), 8)))

		for _ = 1, 8 do
			local v3

			if bit32.band(v2, 32768) == 0 then
				v3 = bit32.lshift(v2, 1)
			else
				v3 = bit32.bxor(bit32.lshift(v2, 1), 4129)
			end

			v2 = bit32.band(v3, 65535)
		end
	end

	return v2
end

function v.encode(value: string)
	local v2 = bit32.bxor(v.getCrc16(value), 42405)
	local v3 = string.upper(value) .. string.format("%04X", v2)
	local result = table.create(169, 0)
	local count = 0

	local function appendSymbol(p: number)
		local v4 = (count * 73 + 19) % 169
		result[v4 + 1] = p
		count += 1
	end

	for i = 1, #v3 do
		local v4 = assert((tonumber(string.sub(v3, i, i), 16)))
		local v5 = bit32.extract(v4, 3)
		local v6 = bit32.extract(v4, 2)
		local v7 = bit32.extract(v4, 1)
		local v8 = bit32.extract(v4, 0)
		local v9 = bit32.bxor(v5, v6, v8)
		result[(count * 73 + 19) % 169 + 1] = v9
		count += 1
		local v10 = bit32.bxor(v5, v7, v8)
		result[(count * 73 + 19) % 169 + 1] = v10
		count += 1
		result[(count * 73 + 19) % 169 + 1] = v5
		count += 1
		local v11 = bit32.bxor(v6, v7, v8)
		result[(count * 73 + 19) % 169 + 1] = v11
		count += 1
		result[(count * 73 + 19) % 169 + 1] = v6
		count += 1
		result[(count * 73 + 19) % 169 + 1] = v7
		count += 1
		result[(count * 73 + 19) % 169 + 1] = v8
		count += 1
	end

	for i = 0, 28 do
		local v4 = (i * 7 + math.floor(i / 3)) % 2
		result[(count * 73 + 19) % 169 + 1] = v4
		count += 1
	end

	return result
end

function v.getPair(p: number)
	local v2 = p + 1

	local function nextNumber()
		v2 = (v2 * 25173 + 13849) % 65536
		return v2
	end

	v2 = (v2 * 25173 + 13849) % 65536
	local v3 = (v2 / 65535 - 0.5) * 0.24
	v2 = (v2 * 25173 + 13849) % 65536
	local v4 = (v2 / 65535 - 0.5) * 0.24
	v2 = (v2 * 25173 + 13849) % 65536
	local v5 = v2 % 2 == 1
	local v6 = (p % 13 + 0.5 + v3) / 13
	local v7 = (math.floor(p / 13) + 0.5 + v4) / 13
	local v8 = v5 and 0 or 0.016923076923076923
	local v9 = v5 and 0.016923076923076923 or 0
	return {
		ax = v6 - v8,
		ay = v7 - v9,
		bx = v6 + v8,
		by = v7 + v9
	}
end

return table.freeze(v)