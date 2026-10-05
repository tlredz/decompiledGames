local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local clone = script.Particles:Clone()
	clone.CFrame = rootPart.CFrame
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = rootPart
	weldConstraint.Part1 = clone
	weldConstraint.Parent = clone
	self:CreateSound("rbxassetid://101557890598386", 1 + 0.5 * math.random(), 0.95 + 0.1 * math.random(), nil, true, 10)
	self:CreateSound("rbxassetid://124233252129930", 1 + 0.5 * math.random(), 0.95 + 0.1 * math.random(), nil, true, 10)
	wait(6.5)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end

function object:_Init() end

return object