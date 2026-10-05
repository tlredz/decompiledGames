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
	local upperTorso = self._is_humanoid and self._subject.Parent:FindFirstChild("UpperTorso") or self._subject
	local clone = script.Particles:Clone()
	clone.CFrame = upperTorso.CFrame
	clone.Parent = self._subject
	table.insert(self._destroy_these, clone)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = upperTorso
	weldConstraint.Part1 = clone
	weldConstraint.Parent = clone
	self:CreateSound("rbxassetid://94428502262714", 1, 0.9 + 0.2 * math.random(), nil, true, 5)
end

function object:_Init() end

return object