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
	BetterDebris:AddItem(bodyGyro, 2)
	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.Position = rootPart.Position
	bodyPosition.MaxForce = createVector(1000000, 1000000, 1000000)
	bodyPosition.Parent = rootPart
	table.insert(self._destroy_these, bodyGyro)
	BetterDebris:AddItem(bodyGyro, 2)
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://118451940351578"
	local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

	if success then
		result:Play(0)
	end

	wait(2)
	bodyGyro:Destroy()
	self:_Ragdoll()
	self:_AnchorModel()
end

function object:PlayClient()
	if not self._is_humanoid then
		return
	end

	local rootPart = self._subject.RootPart
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://118451940351578"
	local clone = script.Model:Clone()
	clone.PrimaryPart = clone.HumanoidRootPart
	clone:PivotTo(self._subject.RootPart.CFrame)
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	BetterDebris:AddItem(clone, 2.4)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone:PivotTo(rootPart.CFrame)
	end)
	table.insert(self._connections, renderSteppedConnection)

	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Noclip"
		end
	end

	local success, result = pcall(clone.AnimationController.LoadAnimation, clone.AnimationController, animation)

	if success then
		result:Play(0)
	end

	self:CreateSound("rbxassetid://74600054680969", 2, 1 + 0.2 * math.random(), nil, true, 5)
	wait(1.2)
	self:CreateSound("rbxassetid://133211885821177", 1.5, 1 + 0.2 * math.random(), nil, true, 5)
end

function object:_Init() end

return object