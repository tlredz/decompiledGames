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
			instance.Color = Color3.fromRGB(163, 162, 165)
			instance.Material = Enum.Material.Slate
			instance.MaterialVariant = ""

			if instance:IsA("MeshPart") then
				instance.TextureID = ""
			end
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("Texture") or instance:IsA("Decal") or instance:IsA("Clothing") or instance:IsA("ShirtGraphic") then
			instance:Destroy()
		end
	end

	local clones = {}

	for _, child in pairs(script.Particles:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = self._is_humanoid and self._subject.RootPart or self._subject
		table.insert(self._destroy_these, clone)
		table.insert(clones, clone)
	end

	Utility:PlayParticles(clones)
	self:CreateSound("rbxassetid://113140086283098", 1.25, 0.9 + 0.2 * math.random(), nil, true, 10)
	self:CreateSound("rbxassetid://120323428371971", 1, 0.9 + 0.2 * math.random(), nil, true, 10)
end

function object:_Init() end

return object