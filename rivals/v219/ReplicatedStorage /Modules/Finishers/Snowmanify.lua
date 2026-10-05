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
	local head = self._is_humanoid and self._subject.Parent:FindFirstChild("Head")

	if not head then
		return
	end

	for _, instance in pairs(self:_GetObjects(true)) do
		if instance:IsA("BasePart") then
			instance.Color = Color3.fromRGB(248, 248, 248)
			instance.Material = Enum.Material.SmoothPlastic
			instance.MaterialVariant = ""

			if instance:IsA("MeshPart") then
				instance.TextureID = ""
			end
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("Texture") or instance:IsA("Decal") or instance:IsA("Clothing") or instance:IsA("ShirtGraphic") then
			instance:Destroy()
		end
	end

	local clone = script.Model:Clone()
	clone.PrimaryPart = clone.Primary
	clone:PivotTo(head.CFrame)
	clone.Parent = head
	table.insert(self._destroy_these, clone)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = head
	weldConstraint.Part1 = clone.Primary
	weldConstraint.Parent = clone
	local clone2 = script.Particles.Attachment:Clone()
	clone2.Parent = head
	table.insert(self._destroy_these, clone2)
	Utility:PlayParticles(clone2)
	self:CreateSound("rbxassetid://103150011493508", 1.5, 1 + 0.1 * math.random(), nil, true, 5)
end

function object:_Init() end

return object