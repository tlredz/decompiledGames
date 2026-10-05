local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
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
	wait(0.25)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local clone = script.Chalk:Clone()
	clone.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) + createVector(
		0,
		2,
		0
	)
	clone.BodyGyro.CFrame = clone.CFrame
	clone.Top.LocalTransparencyModifier = 1
	clone.Bottom.LocalTransparencyModifier = 1
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)

	for _, part in pairs(self:_GetObjects(true)) do
		if not part:IsA("BasePart") then
			continue
		end

		local noCollisionConstraint = Instance.new("NoCollisionConstraint")
		noCollisionConstraint.Part0 = clone
		noCollisionConstraint.Part1 = part
		noCollisionConstraint.Parent = clone
	end

	wait(0.25)
	local lastTime = tick()

	while tick() < lastTime + 0.5 do
		local v = math.clamp((tick() - lastTime) / 0.5, 0, 1)
		local localTransparencyModifier = 1 - (1 - v) ^ 5

		for _, instance in pairs(self:_GetObjects(true)) do
			if not (instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") or instance:IsA("Beam") or instance:IsA("ParticleEmitter") or instance:IsA("Trail")) then
				continue
			end

			instance.LocalTransparencyModifier = localTransparencyModifier
		end

		clone.Top.LocalTransparencyModifier = 1 - v ^ 5
		clone.Bottom.LocalTransparencyModifier = 1 - v ^ 5
		RunService.RenderStepped:Wait()
	end

	wait(15)
end

function object:_Init() end

return object