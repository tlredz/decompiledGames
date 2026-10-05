local v = {}

for i = 0, 255 do
	local v2 = i

	for _ = 1, 8 do
		if bit32.band(v2, 1) == 0 then
			v2 = bit32.rshift(v2, 1)
		else
			v2 = bit32.bxor(bit32.rshift(v2, 1), 3988292384)
		end
	end

	v[i + 1] = v2
end

local v2 = {
	Init = function()
		return 4294967295
	end,
	Update = function(p: number, value: string, value2: number?, p2: number?)
		local v3 = value2 or 1

		for i = v3, v3 + (p2 or string.len(value)) - 1 do
			local v4 = string.byte(value, i)
			p = bit32.bxor(bit32.rshift(p, 8), v[bit32.band(bit32.bxor(p, v4), 255) + 1])
		end

		return p
	end,
	UpdateBuffer = function(p: number, buf: buffer, value: number?, p2: number?)
		local v3 = value or 0

		for i = v3, v3 + (p2 or buffer.len(buf)) - 1 do
			local v4 = buffer.readu8(buf, i)
			p = bit32.bxor(bit32.rshift(p, 8), v[bit32.band(bit32.bxor(p, v4), 255) + 1])
		end

		return p
	end,
	Finish = function(p: number)
		return (bit32.bnot(p))
	end
}

function v2.Digest(p: string, p2: number?, p3: number?)
	local v3 = v2.Init()
	local v4 = v2.Update(v3, p, p2, p3)
	return v2.Finish(v4)
end

function v2.DigestBuffer(buf: buffer, p: number?, p2: number?)
	local v3 = v2.Init()
	local v4 = v2.UpdateBuffer(v3, buf, p, p2)
	return v2.Finish(v4)
end

return table.freeze(v2)