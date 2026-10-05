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

	if not self._is_humanoid then
		return
	end

	local clone = script.Part:Clone()
	clone.CFrame = self._subject.RootPart.CFrame
	clone.Parent = workspace
	Utility:PlayParticles(clone)
	BetterDebris:AddItem(clone, 10)
	table.insert(self._destroy_these, clone)
	local unitVector = Random.new():NextUnitVector()
	local v = (unitVector * createVector(1, 0, 1) + createVector(0, 1, 0) * math.abs(unitVector.Y)) * (16 + 16 * math.random())
	local position = self._subject.Parent:GetPivot().Position
	local raycastResult = Utility:Raycast(
		position,
		position + v,
		v.Magnitude,
		{ self._subject.Parent },
		Enum.RaycastFilterType.Exclude
	)
	self._subject.Parent:PivotTo(CFrame.new(raycastResult.Position) * CFrame.Angles(
		math.random() * 3.141592653589793 * 2,
		math.random() * 3.141592653589793 * 2,
		math.random() * 3.141592653589793 * 2
	))
end

function object.PlayClient(object2, ...)
	object2:CreateSound("rbxassetid://77408061407414", 1, 1 + 0.1 * math.random(), nil, true, 5)
	Ragdoll.PlayClient(object2, ...)
end

function object:_Init() end

return object