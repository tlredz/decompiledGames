local v = string.split("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz-", "")
local count = #v
local Nanoid = {}

function Nanoid.nanoid(value: number?)
	local v2 = ""

	for _ = 1, value or 21 do
		v2 ..= v[math.random(count)]
	end

	return v2
end

function Nanoid.customAlphabet(value: string, value2: number?)
	local v2 = value2 or 21
	local count2 = #value
	local v3 = math.ceil((bit32.lshift(2, 31 - bit32.countlz(count2 - 1)) - 1) * 1.6 * v2 / count2)
	local v4 = string.split(value, "")
	return function(p: number?)
		local v5 = ""
		local v6 = v3

		if not p then
			p = v2
		end

		while v6 > 0 do
			local v7 = math.random(count2)

			if not (v7 <= count2) then
				continue
			end

			v5 ..= v4[v7]

			if #v5 == p then
				break
			else
				v6 -= 1
			end
		end

		return v5
	end
end

return Nanoid