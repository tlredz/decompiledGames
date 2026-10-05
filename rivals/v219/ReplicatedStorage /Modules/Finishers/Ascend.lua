local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
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
	(self._is_humanoid and self._subject.RootPart or self._subject).Anchored = true
end

function object:PlayClient()
	if self._is_humanoid then
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://134648473605383"
		local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

		if success then
			result:Play(0)
		end
	end

	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local clone = script.Explosion.Attachment:Clone()
	clone.Parent = rootPart
	Utility:PlayParticles(clone)
	local clone_2 = script.Idle.Attachment:Clone()
	clone_2.Parent = self._is_humanoid and self._subject.Parent.UpperTorso or self._subject
	self:CreateSound("rbxassetid://86210336908274", 1, 1, nil, true, 5)
	self:CreateSound("rbxassetid://112056531317514", 1, 1, nil, true, 5)
	wait(1)
	local v = {}

	for _, instance in pairs(self:_GetObjects(true)) do
		if not (instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") or instance:IsA("Beam") or instance:IsA("ParticleEmitter") or instance:IsA("Trail")) then
			continue
		end

		v[instance] = true
	end

	local lastTime = tick()

	while tick() < lastTime + 0.3333333333333333 do
		local localTransparencyModifier = 1 - (1 - math.clamp((tick() - lastTime) / 0.3333333333333333, 0, 1)) ^ 3

		for k in pairs(v) do
			k.LocalTransparencyModifier = localTransparencyModifier
		end

		RunService.RenderStepped:Wait()
	end

	self:_HideBody()
end

function object:_Init() end

return object