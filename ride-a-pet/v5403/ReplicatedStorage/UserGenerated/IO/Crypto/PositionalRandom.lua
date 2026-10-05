local function Mix(p: number, p2: number, p3: number)
	local v = bit32.bor(p, 0)
	local v2 = bit32.bor(p2, 0)
	local v3 = bit32.bor(p3, 0)
	local v4 = bit32.bxor(v - v2 - v3, (bit32.rshift(v3, 13)))
	local v5 = bit32.bxor(v2 - v3 - v4, (bit32.lshift(v4, 8)))
	local v6 = bit32.bxor(v3 - v4 - v5, (bit32.rshift(v5, 13)))
	local v7 = bit32.bxor(v4 - v5 - v6, (bit32.rshift(v6, 12)))
	local v8 = bit32.bxor(v5 - v6 - v7, (bit32.lshift(v7, 16)))
	local v9 = bit32.bxor(v6 - v7 - v8, (bit32.rshift(v8, 5)))
	local v10 = bit32.bxor(v7 - v8 - v9, (bit32.rshift(v9, 3)))
	local v11 = bit32.bxor(v8 - v9 - v10, (bit32.lshift(v10, 10)))
	return (bit32.bxor(v9 - v10 - v11, (bit32.rshift(v11, 15))))
end

local function Unpack64(p: number)
	if p < 0 then
		local v = -1 - p
		return bit32.bnot(v // 4294967296), (bit32.bnot(v))
	else
		return bit32.bor(p // 4294967296, 0), (bit32.bor(p, 0))
	end
end

local function ParseUUID(value: string)
	return
		tonumber(string.sub(value, 1, 8), 16),
		tonumber(string.sub(value, 10, 13) .. string.sub(value, 15, 18), 16),
		tonumber(string.sub(value, 20, 23) .. string.sub(value, 25, 28), 16),
		(tonumber(string.sub(value, 29, 36), 16))
end

return table.freeze({
	Mix = Mix,
	DoubleFromInt64 = function(p: number, p2: number)
		local v, v2

		if p < 0 then
			local v3 = -1 - p
			v = bit32.bnot(v3 // 4294967296)
			v2 = bit32.bnot(v3)
		else
			v = bit32.bor(p // 4294967296, 0)
			v2 = bit32.bor(p, 0)
		end

		return Mix(v2, v, p2) / 4294967296
	end,
	DoubleFromUUID = function(value: string, p: number)
		local v = tonumber(string.sub(value, 1, 8), 16)
		local v2 = tonumber(string.sub(value, 10, 13) .. string.sub(value, 15, 18), 16)
		local v3 = tonumber(string.sub(value, 20, 23) .. string.sub(value, 25, 28), 16)
		local v4 = tonumber(string.sub(value, 29, 36), 16)
		return Mix(Mix(v, v2, 2197175160), Mix(v3, v4, 2821953579), p) / 4294967296
	end,
	IntegerFromUUID = function(value: string, p: number, p2: number, p3: number)
		local v = p3 - p2 + 1
		local v2 = tonumber(string.sub(value, 1, 8), 16)
		local v3 = tonumber(string.sub(value, 10, 13) .. string.sub(value, 15, 18), 16)
		local v4 = tonumber(string.sub(value, 20, 23) .. string.sub(value, 25, 28), 16)
		local v5 = tonumber(string.sub(value, 29, 36), 16)
		return (math.floor(p2 + v * (Mix(Mix(v2, v3, 2197175160), Mix(v4, v5, 2821953579), p) / 4294967296)))
	end
})