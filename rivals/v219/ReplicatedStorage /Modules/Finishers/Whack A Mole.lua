local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local Utility = require(ReplicatedStorage.Modules.Utility)
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayServer()
	if not self._is_humanoid then
		return
	end

	local rootPart = self._subject.RootPart

	for _, part in pairs(self:_GetObjects(true)) do
		if part:IsA("BasePart") and part ~= rootPart then
			part.CollisionGroup = "Noclip"
		end
	end

	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.CFrame = CFrame.new(createVector(0, 0, 0), rootPart.CFrame.LookVector * createVector(1, 0, 1))
	bodyGyro.MaxTorque = createVector(100000, 100000, 100000)
	bodyGyro.Parent = rootPart
	table.insert(self._destroy_these, bodyGyro)
	BetterDebris:AddItem(bodyGyro, 2.85)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
	bodyVelocity.Velocity = createVector(0, 0, 0)
	bodyVelocity.Parent = rootPart
	table.insert(self._destroy_these, bodyGyro)
	BetterDebris:AddItem(bodyGyro, 2.85)
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://96799926007713"
	local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

	if success then
		result:Play(0)
	end

	wait(2.8)
	self:_Ragdoll()
	self:_AnchorModel()
end

function object:PlayClient()
	if not self._is_humanoid then
		return
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://96799926007713"
	local clone = script.Model:Clone()
	clone.PrimaryPart = clone.HumanoidRootPart
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	BetterDebris:AddItem(clone, 2.85)
	table.insert(self._connections, RunService.RenderStepped:Connect(function()
		clone:PivotTo(self._subject.RootPart.CFrame)
	end))

	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Noclip"
		end
	end

	local success, result = pcall(clone.AnimationController.LoadAnimation, clone.AnimationController, animation)

	if success then
		result:Play(0)
	end

	wait(2)
	self:CreateSound("rbxassetid://83406711884881", 1, 1 + 0.1 * math.random(), nil, true, 5)
	Utility:PlayParticles(clone.Hole)
end

function object:_Init() end

return object