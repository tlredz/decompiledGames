local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
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
	wait(0.5)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	Utility:Knockback(rootPart, (self:_GetKnockbackDirection() + createVector(0, 0.25, 0)).Unit * 75)
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local _GetGroundPosition = self:_GetGroundPosition(rootPart.Position, self:_GetObjects(true))
	local sound = self:CreateSound("rbxassetid://137714378265704", 1, 1, rootPart, true)

	if sound then
		sound.Looped = true
	end

	local clone = script.Model:Clone()
	clone.Parent = self._subject
	table.insert(self._destroy_these, clone)
	local descendants = {}

	for _, descendant in pairs(clone:GetDescendants()) do
		if not (descendant:IsA("BasePart") or descendant:IsA("ParticleEmitter") or descendant:IsA("Beam")) then
			continue
		end

		table.insert(descendants, descendant)
	end

	local position = nil
	local _GetKnockbackDirection = self:_GetKnockbackDirection()
	local lastTime = tick()
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v = math.clamp((tick() - lastTime) / 1.5, 0, 1)
		local localTransparencyModifier = (1 - math.sin(3.141592653589793 * v)) ^ 10

		if not position or v < 0.4 then
			position = rootPart.Position
		end

		clone:PivotTo(CFrame.new(position.X, _GetGroundPosition.Y, position.Z) * CFrame.new(
			createVector(0, 0, 0),
			-_GetKnockbackDirection
		).Rotation * CFrame.new(0, 0, v * 64 + -32) * CFrame.Angles(0, -1.5707963267948966, 0))

		for _, v3 in pairs(descendants) do
			v3.LocalTransparencyModifier = localTransparencyModifier
		end

		if sound then
			sound.Volume = 1 - localTransparencyModifier
		end
	end)
	table.insert(self._connections, renderSteppedConnection)
	wait(0.75)
	self:CreateSound("rbxassetid://108806529299457", 1, 1.25 + 0.25 * math.random(), rootPart, true)
	wait(0.75)
	renderSteppedConnection:Disconnect()
	clone:Destroy()
end

function object:_GetKnockbackDirection()
	return (Random.new(self._serial and self._serial.Seed or self._seed):NextUnitVector() * createVector(1, 0, 1)).Unit
end

function object:_Init() end

return object