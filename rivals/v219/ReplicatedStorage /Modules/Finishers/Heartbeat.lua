local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local Utility = require(ReplicatedStorage.Modules.Utility)
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local clone = script.Particles.Attachment:Clone()
	clone.Parent = self._is_humanoid and self._subject.Parent.UpperTorso or self._subject
	table.insert(self._destroy_these, clone)

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, 0.25)
		end
	end

	Utility:PlayParticles(clone)
	wait(0.5)

	for i = 1, 3 do
		self:CreateSound("rbxassetid://127325407221199", 1.5 - i * 0.25, 1, nil, true, 5)
		wait(0.9)
	end

	self:CreateSound("rbxassetid://106567630436220", 0.75, 1, nil, true, 5)
end

function object:_Init() end

return object