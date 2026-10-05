local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local Utility = require(ReplicatedStorage.Modules.Utility)
local v = {
	"rbxassetid://1848267914",
	"rbxassetid://1848267930",
	"rbxassetid://9038367984",
	"rbxassetid://9042144091",
	"rbxassetid://9038367978"
}
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object:PlayServer()
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(10000, 10000, 10000)
	bodyVelocity.Velocity = createVector(0, 4, 0)
	bodyVelocity.Parent = self._is_humanoid and self._subject.RootPart or self._subject
	table.insert(self._destroy_these, bodyVelocity)
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.MaxTorque = createVector(10000, 10000, 10000)
	bodyAngularVelocity.AngularVelocity = createVector(0, 2, 0) * math.sign(math.random() - 0.5)
	bodyAngularVelocity.Parent = self._is_humanoid and self._subject.RootPart or self._subject
	table.insert(self._destroy_these, bodyAngularVelocity)
	self:_InternalThread(task.delay, 3, function()
		bodyVelocity.Velocity = createVector(0, 0, 0)
		wait(3)
		bodyVelocity:Destroy()
		bodyAngularVelocity:Destroy()
		self:_AnchorModel()
		self:_Ragdoll()
	end)
end

function object:PlayClient()
	for _, instance in pairs(self:_GetObjects(true)) do
		if instance:IsA("BasePart") and instance.Transparency < 0.99 then
			instance.Color = Color3.fromRGB(255, 255, 255)
			instance.Material = Enum.Material.SmoothPlastic
			instance.MaterialVariant = ""
			instance.Reflectance = 0.5

			for _, child in pairs(script.Texture:GetChildren()) do
				local clone_2 = child:Clone()
				clone_2.Parent = instance
			end

			if instance:IsA("MeshPart") then
				instance.TextureID = ""
			end
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("Texture") or instance:IsA("Decal") or instance:IsA("Clothing") or instance:IsA("ShirtGraphic") then
			instance:Destroy()
		end
	end

	local clone = script.Particles.Enabled:Clone()
	clone.Parent = self._is_humanoid and self._subject.RootPart or self._subject
	local clone2 = script.Particles.Emit:Clone()
	clone2.Parent = self._is_humanoid and self._subject.RootPart or self._subject
	Utility:PlayParticles(clone2)

	if self._is_humanoid then
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://109647828518093"
		local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

		if success then
			result:Play(0)
			result:AdjustSpeed(0.75)
		end
	end

	self:_InternalThread(task.delay, 6, function()
		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") or descendant:IsA("Light") then
				descendant.Enabled = false
			end
		end
	end)
	self:CreateSound(self:_GetMusicID(), 1, 1, nil, true, 5)
end

function object:_GetMusicID()
	return v[Random.new(self._serial and self._serial.Seed or self._seed):NextInteger(1, #v)]
end

function object:_Init() end

return object