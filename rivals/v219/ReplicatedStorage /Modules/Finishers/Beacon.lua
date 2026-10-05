local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
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
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.MaxTorque = createVector(100000, 100000, 100000)
	bodyAngularVelocity.AngularVelocity = Random.new():NextUnitVector() * 10
	bodyAngularVelocity.Parent = rootPart
	BetterDebris:AddItem(bodyAngularVelocity, 3)
	local v = nil

	for _, part in pairs(self:_GetObjects()) do
		if not part:IsA("BasePart") then
			continue
		end

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(1, 1, 1) * (part == rootPart and 10000 or 500)
		bodyVelocity.Velocity = createVector(0, 2, 0)
		bodyVelocity.Parent = part
		BetterDebris:AddItem(bodyVelocity, 3)

		if part == rootPart then
			v = bodyVelocity
		end
	end

	wait(0.25)

	if v then
		v.Velocity *= 150
	end
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local clone = script.Particles:Clone()
	clone.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, 0, 1.5707963267948966) - createVector(0, 2, 0)
	clone.Parent = rootPart
	table.insert(self._destroy_these, clone)
	self:CreateSound("rbxassetid://116502031018076", 1.5, 0.95 + 0.1 * math.random(), clone, true, 10)
	self:_InternalThread(
		task.delay,
		0.1,
		self.CreateSound,
		self,
		"rbxassetid://76502718325596",
		1.5,
		0.95 + 0.1 * math.random(),
		clone,
		true,
		10
	)
	local v = {}
	Utility:RenderstepForLoop(0, 100, 4, function(p)
		local v2 = 1 - (p / 100) ^ 3

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
				v[descendant] = v[descendant] or descendant.Width1
				descendant.Width1 = v[descendant] * v2
			elseif descendant:IsA("Light") then
				v[descendant] = v[descendant] or descendant.Brightness
				descendant.Brightness = v[descendant] * v2
			end
		end
	end)

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = false
		end
	end

	Utility:RenderstepForLoop(0, 100, 4, function(p)
		local localTransparencyModifier = 1 - (1 - p / 100) ^ 3

		for _, part in pairs(self:_GetObjects(true)) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = localTransparencyModifier
			end
		end
	end)

	for _, part in pairs(self:_GetObjects(true)) do
		if part:IsA("BasePart") and part ~= rootPart then
			part:Destroy()
		end
	end

	clone:Destroy()
end

function object:_Init() end

return object