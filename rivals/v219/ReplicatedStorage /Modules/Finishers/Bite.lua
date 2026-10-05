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
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local clone = script.Particles:Clone()
	clone.CFrame = rootPart.CFrame
	clone.Parent = self._subject
	table.insert(self._destroy_these, clone)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = rootPart
	weldConstraint.Part1 = clone
	weldConstraint.Parent = clone
	Utility:PlayParticles(clone)
	self:CreateSound("rbxassetid://119051363107007", 1.25, 1 + 0.2 * math.random(), nil, true, 5)
	self:CreateSound("rbxassetid://70929054322985", 1.25, 1 + 0.2 * math.random(), nil, true, 5)
end

function object:_Init() end

return object