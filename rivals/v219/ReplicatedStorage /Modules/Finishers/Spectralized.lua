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
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.MaxTorque = createVector(100000, 100000, 100000)
	bodyAngularVelocity.AngularVelocity = Random.new():NextUnitVector() * 10
	bodyAngularVelocity.Parent = rootPart
	BetterDebris:AddItem(bodyAngularVelocity, 3)

	for _, part in pairs(self:_GetObjects()) do
		if not part:IsA("BasePart") then
			continue
		end

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(1, 1, 1) * (part == rootPart and 10000 or 500)
		bodyVelocity.Velocity = createVector(0, 2, 0)
		bodyVelocity.Parent = part
		BetterDebris:AddItem(bodyVelocity, 3)
	end
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	self:CreateSound("rbxassetid://115639979533179", 1, 1 + 0.1 * math.random(), nil, true, 5)
	self:CreateSound("rbxassetid://70584026980041", 1.5, 1 + 0.1 * math.random(), nil, true, 5)

	for _, instance in pairs(self:_GetObjects(true)) do
		if instance:IsA("BasePart") then
			instance.Color = Color3.fromRGB(11, 91, 43)
			instance.Material = Enum.Material.SmoothPlastic
			instance.MaterialVariant = ""

			if instance:IsA("MeshPart") then
				instance.TextureID = ""
			end
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("Texture") or instance:IsA("Decal") or instance:IsA("Clothing") or instance:IsA("ShirtGraphic") then
			instance:Destroy()
		end
	end

	local clone = script.Particles.Attachment:Clone()
	clone.Parent = self._is_humanoid and self._subject.RootPart or self._subject
	table.insert(self._destroy_these, clone)
	Utility:PlayParticles(clone)
	Utility:RenderstepForLoop(0, 100, 0.5, function(p)
		local localTransparencyModifier = 1 - (1 - p / 100) ^ 3

		for _, part in pairs(self:_GetObjects(true)) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = localTransparencyModifier
			end
		end
	end)
end

function object:_Init() end

return object