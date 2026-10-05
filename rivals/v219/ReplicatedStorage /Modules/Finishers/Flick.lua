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
	wait(1)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	Utility:Knockback(rootPart, self:_GetKnockbackDirection() * 75)
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local _GetKnockbackDirection = self:_GetKnockbackDirection()
	local clone = script.Model:Clone()
	clone.Parent = self._subject
	table.insert(self._destroy_these, clone)
	local v = Spring.new(rootPart.Position + -_GetKnockbackDirection * createVector(5, -5, 5) * 2, 1, 10)
	local now = tick()

	while tick() < now + 1 do
		v.Target = rootPart.Position + -_GetKnockbackDirection * createVector(1, -1, 1)
		clone:PivotTo(CFrame.new(v.Value) * CFrame.new(
			createVector(0, 0, 0),
			_GetKnockbackDirection * createVector(1, 0, 1)
		))
		RunService.RenderStepped:Wait()
	end

	self:CreateSound("rbxassetid://120809068918800", 1.25, 1, nil, true, 5)
	self:CreateSound("rbxassetid://92760487729234", 2.5, 1, nil, true, 5)
	clone.Before.Transparency = 1
	clone.After.Transparency = 0
	local v2 = clone.After.Size * 2
	local size = clone.After.Size
	local cFrame = clone.After.CFrame
	local v3 = (_GetKnockbackDirection * createVector(1, 0, 1) + Vector3.new(0, math.abs(_GetKnockbackDirection.Y), 0)) * 2
	Utility:RenderstepForLoop(0, 100, 4, function(p)
		local v4 = 1 - (1 - p / 100) ^ 3
		clone.After.Size = v2:Lerp(size, v4)
		clone.After.CFrame = cFrame + v3:Lerp(createVector(0, 0, 0), v4)
	end)
	local cFrame2 = clone.After.CFrame
	local v4 = clone.After.CFrame - createVector(0, 10, 0)
	Utility:RenderstepForLoop(0, 100, 4, function(p)
		local v5 = (p / 100) ^ 3
		clone.After.CFrame = cFrame2:Lerp(v4, v5)
	end)
end

function object:_GetKnockbackDirection()
	return (Random.new(self._serial and self._serial.Seed or self._seed):NextUnitVector() * createVector(1, 0, 1) + createVector(
		0,
		1,
		0
	)).Unit
end

function object:_Init() end

return object