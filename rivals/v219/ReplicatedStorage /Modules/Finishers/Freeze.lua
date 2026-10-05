local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local Utility = require(ReplicatedStorage.Modules.Utility)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object.PlayServer(object2)
	object2:_AnchorModel(0)
end

function object:PlayClient()
	for _, instance in pairs(self:_GetObjects(true)) do
		if instance:IsA("BasePart") then
			instance.Color = Color3.fromRGB(110, 241, 243)
			instance.Material = Enum.Material.Glass
			instance.MaterialVariant = ""
			instance.Reflectance = 0.4
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
			instance:Destroy()
		end
	end

	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local clone = script.Particles.Appear:Clone()
	clone.Parent = rootPart
	table.insert(self._destroy_these, clone)
	Utility:PlayParticles(clone)
	self:CreateSound("rbxassetid://93583856628897", 1.5, 1 + 0.1 * math.random(), nil, true, 5)
	wait(3)
	self:CreateSound("rbxassetid://132622182757236", 1, 1 + 0.1 * math.random(), nil, true, 5)
	self:CreateSound("rbxassetid://122487606797793", 1, 1 + 0.1 * math.random(), nil, true, 5)
	clone:Destroy()

	for _, part in pairs(self:_GetObjects(true)) do
		if part:IsA("BasePart") and part ~= rootPart then
			part:Destroy()
		end
	end

	local clone2 = script.Particles.Emit:Clone()
	clone2.Parent = rootPart
	table.insert(self._destroy_these, clone2)
	Utility:PlayParticles(clone2)
end

function object:_Init() end

return object