local Spring = {}
Spring.__index = Spring
local exp = math.exp
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt

function Spring.new(p, p2, p3, p4)
	local angularFrequency = p2 == nil and 10 or p2
	local dampingRatio = p4 == nil and 1 or p4

	if dampingRatio * angularFrequency < 0 then
		error("Spring does not converge", 2)
	end

	return setmetatable({
		goal = p3 or p,
		dampingRatio = dampingRatio,
		angularFrequency = angularFrequency
	}, Spring):resetToPosition(p)
end

function Spring:resetToPosition(position)
	self.position = position
	self.velocity = position * 0
	return self
end

function Spring:update(p)
	local dampingRatio = self.dampingRatio
	local v = self.angularFrequency * 6.283185307179586
	local goal = self.goal
	local position = self.position
	local velocity = self.velocity
	local v2 = position - goal
	local v4 = exp(-dampingRatio * v * p)
	local position2

	if dampingRatio == 1 then
		position2 = (v2 * (1 + v * p) + velocity * p) * v4 + goal
		self.velocity = (velocity * (1 - v * p) - v2 * (v * v * p)) * v4
	elseif dampingRatio < 1 then
		local v6 = 1 - dampingRatio * dampingRatio
		local v7 = sqrt(v6)
		local v8 = v * v7
		local v10 = cos(v8 * p)
		local v12 = sin(v8 * p)
		local v13

		if v7 > 0.0001 then
			v13 = v12 / v7
		else
			local v14 = p * v
			local v15 = v14 * v14
			v13 = v14 * ((v6 * v6 * v15 - 20 * v6) / 120 * v15 + 1)
		end

		local v14

		if v8 > 0.0001 then
			v14 = v12 / v8
		else
			local v15 = v8 * v8
			local v16 = p * p
			v14 = p * (v16 * (v15 * v15 * v16 / 20 - v15) / 6 + 1)
		end

		local v15 = v13 * dampingRatio
		position2 = (v2 * (v10 + v15) + velocity * v14) * v4 + goal
		self.velocity = (velocity * (v10 - v15) - v2 * (v13 * v)) * v4
	else
		local v6 = -v * dampingRatio
		local v8 = v * sqrt(dampingRatio * dampingRatio - 1)
		local v9 = v6 + v8
		local v10 = v6 - v8
		local v11 = (velocity - v2 * v9) / (2 * v8)
		local v14 = (v2 - v11) * exp(v9 * p)
		local v16 = v11 * exp(v10 * p)
		position2 = v14 + v16 + goal
		self.velocity = v14 * v9 + v16 * v10
	end

	self.position = position2
	return position2
end

return Spring