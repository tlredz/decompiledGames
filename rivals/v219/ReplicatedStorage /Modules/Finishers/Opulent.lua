local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local Utility = require(ReplicatedStorage.Modules.Utility)
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)

	for _, instance in pairs(self:_GetObjects(true)) do
		if instance:IsA("BasePart") then
			instance.Color = Color3.fromRGB(255, 232, 128)
			instance.Material = Enum.Material.Glass
			instance.MaterialVariant = ""
			instance.Reflectance = 0.4

			if instance:IsA("MeshPart") then
				instance.TextureID = ""
			end
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("Texture") or instance:IsA("Decal") or instance:IsA("Clothing") or instance:IsA("ShirtGraphic") then
			instance:Destroy()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function scale(emitter, p)
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p)
		end
	end

	local clones = {}

	for _, child in pairs(script.Particles:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = self._is_humanoid and self._subject.RootPart or self._subject
		table.insert(self._destroy_these, clone)
		table.insert(clones, clone)
		scale(child, 0.5) -- equivalent call inferred; original call site unknown

		for _, descendant in pairs(clone:GetDescendants()) do
			scale(descendant, 0.5) -- equivalent call inferred; original call site unknown
		end
	end

	Utility:PlayParticles(clones)
	self:CreateSound("rbxassetid://18179281854", 2, 0.9 + 0.2 * math.random(), nil, true, 10)
end

function object:_Init() end

return object