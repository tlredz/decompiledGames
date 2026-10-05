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

function object:PlayClient(...)
	for _, instance in pairs(self:_GetObjects(true)) do
		if instance:IsA("BasePart") then
			instance.Color = Color3.fromRGB(205, 208, 255)
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

	self:CreateSound("rbxassetid://94496162153937", 2, 1 + 0.2 * math.random(), nil, true, 5)
	self:CreateSound("rbxassetid://126265374362193", 2, 1 + 0.2 * math.random(), nil, true, 5)
	self:CreateSound("rbxassetid://104909327141208", 1, 1 + 0.2 * math.random(), nil, true, 5)
	local clone = script.Particles.Enabled:Clone()
	clone.Parent = self._is_humanoid and self._subject.RootPart or self._subject
	table.insert(self._destroy_these, clone)
	local clones = {}

	for _, child in pairs(script.Particles.Emit:GetChildren()) do
		local clone2 = child:Clone()
		clone2.Parent = self._is_humanoid and self._subject.RootPart or self._subject
		table.insert(self._destroy_these, clone2)
		table.insert(clones, clone2)
	end

	Utility:PlayParticles(clones)
end

function object:_Init() end

return object