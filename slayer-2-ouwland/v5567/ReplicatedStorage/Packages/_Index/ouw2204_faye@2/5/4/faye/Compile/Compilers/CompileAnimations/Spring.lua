local sqrt = math.sqrt
local exp = math.exp
local cos = math.cos
return function(value, p, p2)
	local v = math.clamp(value, 0, 1)
	local v2 = 6.283185307179586 * p
	local v3 = v - 1

	if p2 >= 1 then
		return 1 - v3 * exp(-v2 * p2 * v)
	end

	local v5 = v2 * sqrt(1 - p2 ^ 2)
	return 1 + v3 * exp(-v2 * p2 * v) * cos(v5 * v)
end