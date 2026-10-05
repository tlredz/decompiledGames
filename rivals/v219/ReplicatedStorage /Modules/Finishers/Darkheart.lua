local createVector = vector.create
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

function object:PlayServer()
	self:_AnchorModel(0)
	self:_InternalThread(task.delay, 0.25, function()
		self:_AnchorModel(0, false)
		self:_AnchorModel()
		self:_BreakJoints()

		if self._is_humanoid then
			self._subject.Parent:BreakJoints()
		end

		for _, part in pairs(self:_GetObjects()) do
			if not part:IsA("BasePart") then
				continue
			end

			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5).Unit * 40
			bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
			bodyVelocity.Parent = part
			table.insert(self._destroy_these, bodyVelocity)
			part.CFrame *= CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			)
		end
	end)
end

function object:PlayClient()
	for _, instance in pairs(self:_GetObjects(true)) do
		if instance:IsA("BasePart") then
			instance.Color = Color3.fromRGB(0, 0, 0)
			instance.Material = Enum.Material.Glass
			instance.MaterialVariant = ""

			if instance:IsA("MeshPart") then
				instance.TextureID = ""
			end
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
			instance.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
		elseif instance:IsA("Texture") or instance:IsA("Decal") then
			instance.Color3 = Color3.fromRGB(0, 0, 0)
		elseif instance:IsA("Clothing") or instance:IsA("ShirtGraphic") then
			instance:Destroy()
		end
	end

	for _, part in pairs(self:_GetObjects()) do
		if not part:IsA("BasePart") or part.Transparency > 0 then
			continue
		end

		for _, child in pairs(script.Particles:GetChildren()) do
			local clone = child:Clone()
			clone.Parent = part
			table.insert(self._destroy_these, clone)
		end
	end

	self:CreateSound(
		"rbxassetid://133729942047865",
		1,
		1 + 0.2 * math.random(),
		self._is_humanoid and self._subject.RootPart.Position or self._subject.Position,
		true,
		5
	)
	wait(0.25)
	local clones = {}

	for _, child in pairs(script.ExplodeParticles:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = self._is_humanoid and self._subject.RootPart or self._subject
		table.insert(self._destroy_these, clone)
		table.insert(clones, clone)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				Utility:ScaleParticleEmitter(emitter, 3)
			end
		end
	end

	Utility:PlayParticles(clones)
	self:CreateSound(
		"rbxassetid://90611785538933",
		1,
		0.8 + 0.2 * math.random(),
		self._is_humanoid and self._subject.RootPart.Position or self._subject.Position,
		true,
		10
	)
end

function object:_Init() end

return object