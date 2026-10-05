local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Finisher = require(ReplicatedStorage.Modules.Finisher)
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

	local rootPart = self._subject.RootPart
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.CFrame = CFrame.new(createVector(0, 0, 0), rootPart.CFrame.LookVector * createVector(1, 0, 1))
	bodyGyro.MaxTorque = createVector(100000, 100000, 100000)
	bodyGyro.Parent = rootPart
	table.insert(self._destroy_these, bodyGyro)
	BetterDebris:AddItem(bodyGyro, 0.9)
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://124846559963188"
	local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

	if success then
		result:Play(0)
	end

	wait(0.9)
	bodyGyro:Destroy()
	self:_Ragdoll()
	self:_AnchorModel()
end

function object:PlayClient()
	if not self._is_humanoid then
		return
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://124846559963188"
	local clone = script.Model:Clone()
	clone.PrimaryPart = clone.HumanoidRootPart
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	BetterDebris:AddItem(clone, 1.7)
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

	self:CreateSound("rbxassetid://71681149544292", 1, 1, nil, true, 5)
	wait(0.6)
	self:CreateSound("rbxassetid://83125848403089", 3, 1, nil, true, 5)
	wait(0.25)
	self:CreateSound("rbxassetid://99072929297079", 1.5, 1, nil, true, 5)
end

function object:_Init() end

return object