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
	wait(0.75)
	local clone = script.Particles.Attachment:Clone()
	clone.Parent = self._is_humanoid and self._subject.Parent.LowerTorso or self._subject
	table.insert(self._destroy_these, clone)
	Utility:PlayParticles(clone)
	self:CreateSound("rbxassetid://16924073325", 1, 1 + 0.2 * math.random(), nil, true, 5)
end

function object:_Init() end

return object