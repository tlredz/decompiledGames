local Spring = {}
Spring.__index = Spring
local exp = math.exp
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt

function Spring.new(value, value2, p)
	assert(type(value) == "number")
	assert(type(value2) == "number")
	assert(value * value2 >= 0, "Spring does not converge")
	return (setmetatable({
		d = value,
		f = value2,
		g = p,
		p = p,
		v = p * 0
	}, Spring))
end

function Spring:SetGoal(p2)
	self.g = p2
end

function Spring.GetPosition(p)
	return p.p
end

function Spring.GetVelocity(p)
	return p.v
end

function Spring:Update(p)
	local d = self.d
	local v = self.f * 2 * 3.141592653589793
	local g = self.g
	local p2 = self.p
	local v2 = self.v
	local v3 = p2 - g
	local v5 = exp(-d * v * p)
	local v6, v7

	if d == 1 then
		v6 = (v3 * (1 + v * p) + v2 * p) * v5 + g
		v7 = (v2 * (1 - v * p) - v3 * (v * v * p)) * v5
	elseif d < 1 then
		local v9 = sqrt(1 - d * d)
		local v11 = cos(v * v9 * p)
		local v13 = sin(v * v9 * p)
		local v14

		if v9 > 0.0001 then
			v14 = v13 / v9
		else
			local v15 = p * v
			v14 = v15 + (v15 * v15 * (v9 * v9) * (v9 * v9) / 20 - v9 * v9) * (v15 * v15 * v15) / 6
		end

		local v15

		if v * v9 > 0.0001 then
			v15 = v13 / (v * v9)
		else
			local v16 = v * v9
			v15 = p + (p * p * (v16 * v16) * (v16 * v16) / 20 - v16 * v16) * (p * p * p) / 6
		end

		v6 = (v3 * (v11 + d * v14) + v2 * v15) * v5 + g
		v7 = (v2 * (v11 - v14 * d) - v3 * (v14 * v)) * v5
	else
		local v9 = sqrt(d * d - 1)
		local v10 = -v * (d - v9)
		local v11 = -v * (d + v9)
		local v12 = (v2 - v3 * v10) / (2 * v * v9)
		local v15 = (v3 - v12) * exp(v10 * p)
		local v17 = v12 * exp(v11 * p)
		v6 = v15 + v17 + g
		v7 = v15 * v10 + v17 * v11
	end

	self.p = v6
	self.v = v7
	return v6
end

return Spring