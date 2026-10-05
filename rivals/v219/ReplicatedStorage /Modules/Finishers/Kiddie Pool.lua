local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Spring = require(ReplicatedStorage.Modules.Spring)
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
	rootPart.CFrame = CFrame.new(self:_GetGroundPosition(rootPart.Position, self:_GetObjects(true))) * rootPart.CFrame.Rotation + createVector(
		0,
		2,
		0
	)
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local cframe = CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
	local clone = script.Model:Clone()
	clone.Parent = self._subject
	table.insert(self._destroy_these, clone)
	local clone2 = script.Particles:Clone()
	clone2.CFrame = CFrame.new(rootPart.Position)
	clone2.Parent = rootPart
	table.insert(self._destroy_these, clone2)
	Utility:PlayParticles(clone2)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = clone2
	weldConstraint.Part1 = rootPart
	weldConstraint.Parent = clone2
	local _GetObjects = self:_GetObjects(true)
	local v = Spring.new(rootPart.Position, 1, 2)
	table.insert(self._connections, RunService.RenderStepped:Connect(function()
		v.Target = self:_GetGroundPosition(rootPart.Position, _GetObjects)
		clone:PivotTo(CFrame.new(v.Value.X, v.Target.Y, v.Value.Z) * cframe)
	end))
	self:CreateSound("rbxassetid://17812496122", 1, 1.1 + 0.1 * math.random(), nil, true, 5)
end

function object:_Init() end

return object