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

function object:PlayServer(...)
	Ragdoll.PlayServer(self, ...)

	if not self._is_humanoid then
		return
	end

	self._subject.Parent:ScaleTo(self._subject.Parent:GetScale() * 0.75)
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	self:CreateSound("rbxassetid://109652754163016", 1.25, 1 + 0.1 * math.random(), nil, true, 5)
	local head = self._is_humanoid and self._subject.Parent:FindFirstChild("Head")

	if not head then
		return
	end

	local clone = script.Model:Clone()
	clone.PrimaryPart = clone.Primary
	clone:PivotTo(head.CFrame)
	clone:ScaleTo(clone:GetScale() * head.Size.Y / 1)
	clone.Parent = head
	table.insert(self._destroy_these, clone)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = head
	weldConstraint.Part1 = clone.Primary
	weldConstraint.Parent = clone
	local clone2 = script.Particles.Attachment:Clone()
	clone2.Parent = head
	table.insert(self._destroy_these, clone2)
	Utility:PlayParticles(clone2)
end

function object:_Init() end

return object