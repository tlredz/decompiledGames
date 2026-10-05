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
			instance.Color = Color3.fromRGB(124, 92, 70)
			instance.Material = Enum.Material.Wood
			instance.MaterialVariant = "Wood01a"

			if instance:IsA("MeshPart") then
				instance.TextureID = ""
			end
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("Texture") or instance:IsA("Decal") or instance:IsA("Clothing") or instance:IsA("ShirtGraphic") then
			instance:Destroy()
		end
	end

	for _, childName in pairs({ "Head", "HumanoidRootPart" }) do
		local child = self._is_humanoid and self._subject.Parent:FindFirstChild(childName)

		if not child then
			continue
		end

		local clone = script[childName]:Clone()
		clone.PrimaryPart = clone.Primary
		clone:PivotTo(child.CFrame)
		clone.Parent = child
		table.insert(self._destroy_these, clone)
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = child
		weldConstraint.Part1 = clone.Primary
		weldConstraint.Parent = clone
	end

	local clones = {}

	for _, child in pairs(script.Particles:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = self._is_humanoid and self._subject.RootPart or self._subject
		table.insert(self._destroy_these, clone)
		table.insert(clones, clone)
	end

	Utility:PlayParticles(clones)
	self:CreateSound("rbxassetid://96385683410648", 1.5, 1 + 0.1 * math.random(), nil, true, 5)
end

function object:_Init() end

return object