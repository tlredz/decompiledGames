local OscillatingSpring = {}
OscillatingSpring.__index = OscillatingSpring

function OscillatingSpring.new(value: number, value2: number, value3: number)
	local self = setmetatable({}, OscillatingSpring)
	self.position = value or 0
	self.velocity = 0
	self.target = value or 0
	self.frequency = value2 or 1
	self.damping = value3 or 0.8
	return self
end

function OscillatingSpring:Update(p: number)
	if p <= 0 then
		return
	end

	local v = 6.283185307179586 * self.frequency
	local v2 = self.target - self.position
	local v3 = v * v * v2 - 2 * self.damping * v * self.velocity
	self.velocity += v3 * p
	self.position += self.velocity * p
end

function OscillatingSpring:SetTarget(target: number)
	self.target = target
end

function OscillatingSpring.GetPosition(p)
	return p.position
end

function OscillatingSpring.GetVelocity(p)
	return p.velocity
end

function OscillatingSpring.GetTarget(p)
	return p.target
end

function OscillatingSpring:SetFrequency(frequency: number)
	self.frequency = frequency
end

function OscillatingSpring:SetDamping(damping: number)
	self.damping = damping
end

function OscillatingSpring:Snap(p2: number)
	self.position = p2
	self.velocity = 0
	self.target = p2
end

function OscillatingSpring:ResetVelocity()
	self.velocity = 0
end

function OscillatingSpring:Impulse(p2: number)
	self.velocity += p2
end

function OscillatingSpring.IsAtRest(data, value: number?, value2: number?)
	return (value or 0.01) > math.abs(data.target - data.position) and math.abs(data.velocity) < (value2 or 0.01)
end

return OscillatingSpring