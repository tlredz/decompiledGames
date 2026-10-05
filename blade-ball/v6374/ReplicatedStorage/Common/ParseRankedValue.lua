local function getDigitsBetweenAandB(p, p2, p3)
	return (math.floor(p % 10 ^ p3 / 10 ^ (p2 - 1)))
end

local function interpret(p, p2)
	local v = tostring(p)
	local v2 = {
		math.floor(p2 % 100 / 1),
		math.floor(p2 % 1000000 / 100),
		math.floor(p2 % 100000000000 / 1000000),
		(math.floor(p2 % 1e16 / 100000000000))
	}
	local v3 = nil
	local v4 = nil
	local v5

	if tonumber(v) then
		v5 = tonumber(v)
	else
		local parts = v:split(":")
		v5 = tonumber(parts[1])
		v3 = parts[2]
		v4 = parts[3]
	end

	return v5, v3, v4, v2[4], v2[3], v2[2], v2[1]
end

return interpret