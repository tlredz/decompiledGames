local module = require("./OscillatingSpring")
local OscillatingVectorSpring = {}
OscillatingVectorSpring.__index = OscillatingVectorSpring

function OscillatingVectorSpring.new(vector: Vector3, p: number, p2: number)
	local object = setmetatable({}, OscillatingVectorSpring)
	object.x = module.new(vector.X, p, p2)
	object.y = module.new(vector.Y, p, p2)
	object.z = module.new(vector.Z, p, p2)
	return object
end

function OscillatingVectorSpring:Update(p: number)
	self.x:Update(p)
	self.y:Update(p)
	self.z:Update(p)
end

function OscillatingVectorSpring:SetTarget(vector: Vector3)
	self.x:SetTarget(vector.X)
	self.y:SetTarget(vector.Y)
	self.z:SetTarget(vector.Z)
end

function OscillatingVectorSpring:GetPosition()
	return (Vector3.new(self.x:GetPosition(), self.y:GetPosition(), self.z:GetPosition()))
end

function OscillatingVectorSpring:GetVelocity()
	return (Vector3.new(self.x:GetVelocity(), self.y:GetVelocity(), self.z:GetVelocity()))
end

function OscillatingVectorSpring:GetTarget()
	return (Vector3.new(self.x:GetTarget(), self.y:GetTarget(), self.z:GetTarget()))
end

function OscillatingVectorSpring:SetFrequency(p: number)
	self.x:SetFrequency(p)
	self.y:SetFrequency(p)
	self.z:SetFrequency(p)
end

function OscillatingVectorSpring:SetDamping(p: number)
	self.x:SetDamping(p)
	self.y:SetDamping(p)
	self.z:SetDamping(p)
end

function OscillatingVectorSpring:Snap(vector: Vector3)
	self.x:Snap(vector.X)
	self.y:Snap(vector.Y)
	self.z:Snap(vector.Z)
end

function OscillatingVectorSpring:ResetVelocity()
	self.x:ResetVelocity()
	self.y:ResetVelocity()
	self.z:ResetVelocity()
end

function OscillatingVectorSpring:Impulse(vector: Vector3)
	self.x:Impulse(vector.X)
	self.y:Impulse(vector.Y)
	self.z:Impulse(vector.Z)
end

function OscillatingVectorSpring:IsAtRest(p: number?, p2: number?)
	return self.x:IsAtRest(p, p2) and self.y:IsAtRest(p, p2) and self.z:IsAtRest(p, p2)
end

function OscillatingVectorSpring.GetAxis(p, value: string)
	return p[value:lower()]
end

return OscillatingVectorSpring