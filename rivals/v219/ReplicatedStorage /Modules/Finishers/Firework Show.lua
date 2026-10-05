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

function object:PlayServer()
	Ragdoll.PlayServer(self)

	if not self._is_humanoid then
		return
	end

	self:_AnchorModel(0, false)
	local rootPart = self._subject.RootPart
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
	bodyVelocity.Velocity = createVector(0, 64, 0)
	bodyVelocity.Parent = rootPart
	table.insert(self._destroy_these, bodyVelocity)
	wait(0.5)
	local lastTime = tick()

	while tick() < lastTime + 0.75 do
		local v = math.clamp((tick() - lastTime) / 0.75, 0, 1)
		bodyVelocity.Velocity = (CFrame.new(createVector(0, 0, 0), createVector(0, 1, 0)) * CFrame.Angles(
			6.283185307179586 * v,
			0,
			0
		)).LookVector * 64
		RunService.Heartbeat:Wait()
	end

	bodyVelocity.Velocity = createVector(0, 64, 0)
	wait(1)
	bodyVelocity:Destroy()
	rootPart.Velocity = createVector(0, 64, 0) + Vector3.new(math.random() - 0.5, 0, math.random() - 0.5) * 64 * 0.1
	self:_AnchorModel()
end

function object:PlayClient()
	Ragdoll.PlayClient(self)

	if not self._is_humanoid then
		return
	end

	local rootPart = self._subject.RootPart
	local clones = {}

	for _, child in pairs(script.Trail:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = rootPart
		table.insert(self._destroy_these, clone)
		table.insert(clones, clone)
	end

	self:CreateSound("rbxassetid://108099224793848", 1.25, 1 + 0.1 * math.random(), nil, true, 5)
	wait(2.25)

	for _, emitter in pairs(clones) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end

		for _, emitter2 in pairs(emitter:GetDescendants()) do
			if emitter2:IsA("ParticleEmitter") then
				emitter2.Enabled = false
			end
		end
	end

	local clone = script.Explode.Attachment:Clone()
	clone.Parent = rootPart
	Utility:PlayParticles(clone)
	table.insert(self._destroy_these, clone)
	self:CreateSound("rbxassetid://133816595599115", 1.5, 1 + 0.1 * math.random(), nil, true, 5)
end

function object:_Init() end

return object