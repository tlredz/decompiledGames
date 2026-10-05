local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Modules.BetterDebris)
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local v = {
	"rbxassetid://91261888651237",
	"rbxassetid://116627376811943",
	"rbxassetid://131046967935934",
	"rbxassetid://98510973512946",
	"rbxassetid://102276174123211",
	"rbxassetid://119206791261589",
	"rbxassetid://85250994493837",
	"rbxassetid://80578622827590",
	"rbxassetid://108990615121442",
	"rbxassetid://123917383226893"
}
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object:PlayServer()
	if not self._is_humanoid then
		return
	end

	self._subject.HipHeight += 1.5
	local rootPart = self._subject.RootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.CFrame = CFrame.new(createVector(0, 0, 0), rootPart.CFrame.LookVector * createVector(1, 0, 1))
	bodyGyro.MaxTorque = createVector(100000, 100000, 100000)
	bodyGyro.Parent = rootPart
	table.insert(self._destroy_these, bodyGyro)
	local animation = Instance.new("Animation")
	animation.AnimationId = self:_GetAnimationID()
	local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

	if success then
		result:Play(0)
	end

	wait(1.5)
	self:_AnchorModel(0)
end

function object:PlayClient()
	if not self._is_humanoid then
		return
	end

	for _, instance in pairs(self:_GetObjects(true)) do
		if instance:IsA("BasePart") then
			instance.Color = Color3.fromRGB(105, 104, 106)
			instance.Material = Enum.Material.SmoothPlastic
			instance.MaterialVariant = ""

			if instance:IsA("MeshPart") then
				instance.TextureID = ""
			end
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("Texture") or instance:IsA("Decal") or instance:IsA("Clothing") or instance:IsA("ShirtGraphic") then
			instance:Destroy()
		end
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = self:_GetAnimationID()
	local clone = script.Model:Clone()
	clone.PrimaryPart = clone.HumanoidRootPart
	clone:PivotTo(self._subject.RootPart.CFrame)
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)

	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Noclip"
		end
	end

	local success, result = pcall(clone.AnimationController.LoadAnimation, clone.AnimationController, animation)

	if success then
		result:Play(0)
	end

	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone:PivotTo(self._subject.RootPart.CFrame * CFrame.new(0, 2.25, 0))
	end)
	table.insert(self._connections, renderSteppedConnection)
	self:CreateSound("rbxassetid://90323515241815", 1, 1 + 0.1 * math.random(), nil, true, 5)
	wait(1.5)
	renderSteppedConnection:Disconnect()

	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end
end

function object:_GetAnimationID()
	return v[Random.new(self._serial and self._serial.Seed or self._seed):NextInteger(1, #v)]
end

function object:_Init() end

return object