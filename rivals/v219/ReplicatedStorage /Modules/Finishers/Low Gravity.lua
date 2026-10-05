local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.CONSTANTS)
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local Utility = require(ReplicatedStorage.Modules.Utility)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object:PlayServer()
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local attachment = Instance.new("Attachment")
	attachment.Parent = rootPart
	local angularVelocity = Instance.new("AngularVelocity")
	angularVelocity.MaxTorque = 10000
	angularVelocity.AngularVelocity = Random.new():NextUnitVector() * 5
	angularVelocity.Attachment0 = attachment
	angularVelocity.Parent = rootPart
	table.insert(self._destroy_these, angularVelocity)
	local clone = script.Guide:Clone()
	clone.BodyForce.Force = Vector3.new(0, workspace.Gravity * clone:GetMass() * 0.875, 0)
	clone.CFrame = rootPart.CFrame
	clone.CollisionGroup = rootPart.CollisionGroup

	for _, part in pairs(self:_GetObjects(true)) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Massless = true
		local noCollisionConstraint = Instance.new("NoCollisionConstraint")
		noCollisionConstraint.Part0 = clone
		noCollisionConstraint.Part1 = part
		noCollisionConstraint.Parent = clone
	end

	local attachment2 = Instance.new("Attachment")
	attachment2.Parent = rootPart
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Attachment0 = attachment2
	alignPosition.Attachment1 = clone.Attachment
	alignPosition.MaxForce = 1000000
	alignPosition.MaxVelocity = 32
	alignPosition.Parent = clone
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	Utility:Knockback(clone, Random.new():NextUnitVector() * createVector(1, 0, 1) * 10 + createVector(0, 15, 0))
	self:_Ragdoll()
end

function object.PlayClient(object2)
	object2:CreateSound("rbxassetid://115089214845604", 1, 1 + 0.1 * math.random(), nil, true, 10)
end

function object:_Init() end

return object