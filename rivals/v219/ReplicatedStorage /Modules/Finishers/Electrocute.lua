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

function object:PlayServer(...)
	if self._is_humanoid then
		self._subject.RootPart.Anchored = true
	end

	wait(1.7999999999999998)

	if self._is_humanoid then
		self._subject.RootPart.Anchored = false
	end

	self:_Ragdoll()
	self:_AnchorModel()
end

function object:PlayClient(...)
	local v = {}

	for _, part in pairs(self:_GetObjects()) do
		if not part:IsA("BasePart") or part.Transparency > 0 then
			continue
		end

		local clone = script[part.Name == "Head" and "Head" or "Limb"]:Clone()
		clone.Size = part.Size
		clone.CFrame = part.CFrame
		clone.Parent = part
		table.insert(v, clone)
		table.insert(self._destroy_these, clone)
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = part
		weldConstraint.Part1 = clone
		weldConstraint.Parent = clone

		if part.Name ~= "Head" then
			continue
		end

		local clone2 = script.Face:Clone()
		clone2.CFrame = part.CFrame
		clone2.Parent = part
		table.insert(v, clone2.Decal)
		table.insert(self._destroy_these, clone2)
		local weldConstraint2 = Instance.new("WeldConstraint")
		weldConstraint2.Part0 = part
		weldConstraint2.Part1 = clone2
		weldConstraint2.Parent = clone2
	end

	local face = self._is_humanoid and self._subject.Parent:FindFirstChild("face", true)

	if face then
		face:Destroy()
	end

	local transparenciesByInstance = {}
	local clones = {}

	for _, instance in pairs(self:_GetObjects(true)) do
		if not (instance:IsA("BasePart") or instance:IsA("Decal")) then
			continue
		end

		transparenciesByInstance[instance] = instance.Transparency

		if not instance:IsA("BasePart") then
			continue
		end

		local clone = script.Particles.Enabled:Clone()
		clone.Parent = instance
		table.insert(self._destroy_these, clone)
		table.insert(clones, clone)

		for _, child in pairs(clone:GetChildren()) do
			Utility:ScaleParticleEmitter(child, 0.5)
		end

		local clone2 = script.Particles.Smoke:Clone()
		clone2.Parent = instance
		table.insert(self._destroy_these, clone2)
	end

	self:CreateSound("rbxassetid://79646963478511", 0.75, 1, nil, true, 5)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function show_shock(p)
		for k, v2 in pairs(transparenciesByInstance) do
			k.Transparency = p and 1 or v2
		end

		for _, v2 in pairs(v) do
			v2.Transparency = p and 0 or 1
		end
	end

	for _ = 1, 15 do
		show_shock(true) -- equivalent call inferred; original call site unknown
		wait(0.08)
		show_shock(false) -- equivalent call inferred; original call site unknown
		wait(0.04)
	end

	for _, v2 in pairs(clones) do
		v2:Destroy()
	end

	for _, v2 in pairs(v) do
		v2:Destroy()
	end

	for _, instance in pairs(self:_GetObjects(true)) do
		if instance:IsA("BasePart") then
			instance.Color = Color3.fromRGB(30, 30, 30)
			instance.Material = Enum.Material.Grass
			instance.Reflectance = 0
			instance.MaterialVariant = ""

			if instance:IsA("MeshPart") then
				instance.TextureID = ""
			end
		elseif instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("Texture") or instance:IsA("Decal") or instance:IsA("Clothing") or instance:IsA("ShirtGraphic") then
			instance:Destroy()
		end
	end
end

function object:_Init() end

return object