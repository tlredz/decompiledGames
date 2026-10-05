local Spring = {}
Spring.__index = Spring

function Spring.new(damping: number, frequency: number, p: number)
	local self = setmetatable({}, Spring)
	assert(damping * frequency >= 0, "stop that")
	self.Damping = damping
	self.Frequency = frequency
	self.Goal = p
	self.Position = p
	self.Velocity = p * 0
	return self
end

function Spring:Set(goal: number)
	self.Goal = goal
	return nil
end

function Spring.Get(p)
	return p.Position
end

function Spring:Step(p: number)
	local damping = self.Damping
	local v = self.Frequency * 2 * 3.141592653589793
	local goal = self.Goal
	local position = self.Position
	local velocity = self.Velocity
	local v2 = position - goal
	local v3 = math.exp(-p * damping * v)

	if damping == 1 then
		self.Position = (velocity * p + v2 * (v * p + 1)) * v3 + goal
		self.Velocity = (velocity - v * p * (v2 * v + velocity)) * v3
	elseif damping < 1 then
		local v4 = math.sqrt(1 - damping * damping)
		local v5 = math.cos(v * v4 * p)
		local v6 = math.sin(v * v4 * p)
		self.Position = (v5 * v2 + v6 * (velocity + damping * v * v2) / (v * v4)) * v3 + goal
		self.Velocity = (v5 * v4 * velocity - v6 * (velocity * damping + v * v2)) * v3 / v4
	elseif damping > 1 then
		local v4 = math.sqrt(damping * damping - 1)
		local v5 = -v * (damping - v4)
		local v6 = -v * (damping + v4)
		local v7 = (velocity - v5 * v2) / (2 * v * v4)
		local v8 = (v2 - v7) * math.exp(v5 * p)
		local v9 = v7 * math.exp(v6 * p)
		self.Position = v8 + v9 + goal
		self.Velocity = v5 * v8 + v6 * v9
	end

	return nil
end

return Spring