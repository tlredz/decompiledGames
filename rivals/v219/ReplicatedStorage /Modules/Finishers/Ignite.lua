local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

	for _, instance in pairs(self:_GetObjects(true)) do
		if instance:IsA("BasePart") then
			instance.Color = Color3.fromRGB(0, 0, 0)
			instance.Material = Enum.Material.SmoothPlastic
			instance.MaterialVariant = "Scorched"

			if instance:IsA("MeshPart") then
				instance.TextureID = ""
			end
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("Texture") or instance:IsA("Decal") or instance:IsA("Clothing") or instance:IsA("ShirtGraphic") then
			instance:Destroy()
		end
	end

	for _, part in pairs(self:_GetObjects()) do
		if not part:IsA("BasePart") then
			continue
		end

		for _, child in pairs(script.Particles:GetChildren()) do
			local clone = child:Clone()
			clone.Parent = part
			table.insert(self._destroy_these, clone)
		end
	end

	self:CreateSound("rbxassetid://130652232992636", 1, 1 + 0.1 * math.random(), nil, true, 5)
	self:CreateSound("rbxassetid://99039883606432", 1, 1, nil, true)
end

function object:_Init() end

return object