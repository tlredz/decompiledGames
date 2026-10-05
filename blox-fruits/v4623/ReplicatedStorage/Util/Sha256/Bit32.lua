local Bit32 = {}

function Bit32.band(p, p2)
	local v = 1
	local total = 0

	while p > 0 or p2 > 0 do
		local v2 = p % 2
		local v3 = p2 % 2
		total += v2 * v3 * v
		p = (p - v2) * 0.5
		p2 = (p2 - v3) * 0.5
		v *= 2
	end

	return total
end

function Bit32.bnot(p)
	return 4294967295 - p
end

function Bit32.bor(p, p2)
	local v = 4294967295 - p
	local v2 = 4294967295 - p2
	local v3 = 1
	local total = 0

	while v > 0 or v2 > 0 do
		local v4 = v % 2
		local v5 = v2 % 2
		total += v4 * v5 * v3
		v = (v - v4) * 0.5
		v2 = (v2 - v5) * 0.5
		v3 *= 2
	end

	return 4294967295 - total
end

function Bit32.bxor(p, p2)
	local v = 1
	local total = 0

	while p > 0 or p2 > 0 do
		local v2 = p % 2
		local v3 = p2 % 2
		total += (v2 + v3) % 2 * v
		p = (p - v2) * 0.5
		p2 = (p2 - v3) * 0.5
		v *= 2
	end

	return total
end

function Bit32.lshift(p, p2)
	return p * 2 ^ p2 % 4294967296
end

function Bit32.rshift(p, p2)
	local v = p * 0.5 ^ p2
	return v - v % 1
end

function Bit32.lrotate(p, p2)
	local v = p * 2 ^ p2 % 4294967296
	local v2 = p * 0.5 ^ (32 - p2)
	return v + v2 - v2 % 1
end

function Bit32.rrotate(p, p2)
	local v = p * 0.5 ^ p2
	local v2 = p * 2 ^ (32 - p2) % 4294967296
	return v - v % 1 + v2
end

return Bit32