local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
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
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
	bodyVelocity.Velocity = Random.new():NextUnitVector() * createVector(1, 0, 1) * 24
	bodyVelocity.Parent = rootPart
	table.insert(self._destroy_these, bodyVelocity)
	BetterDebris:AddItem(bodyVelocity, 0.2)
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local head = self._is_humanoid and self._subject.Parent:FindFirstChild("Head")

	if not head then
		return
	end

	local clone = script.Model:Clone()
	clone.PrimaryPart = clone.Primary
	clone:PivotTo(head.CFrame)
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
	self:CreateSound("rbxassetid://106768039815049", 1.25, 1 + 0.1 * math.random(), nil, true, 5)
	self:CreateSound("rbxassetid://113457984699397", 1.75, 1 + 0.1 * math.random(), nil, true, 5)
end

function object:_Init() end

return object