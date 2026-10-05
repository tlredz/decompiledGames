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
	BetterDebris:AddItem(bodyGyro, 1.5)
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://135124706498215"
	local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

	if success then
		result:Play(0)
	end

	wait(1.25)
	local position = self._subject.RootPart.Position
	wait(0.25)
	bodyGyro:Destroy()
	self:_Ragdoll()
	self:_AnchorModel()
	local v = self._subject.RootPart.Position - position
	local v2 = v.Magnitude <= 0.01 and createVector(0, 0, 0) or v.Unit
	self._subject.RootPart.Velocity = v2 * -256
end

function object:PlayClient()
	if not self._is_humanoid then
		return
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://135124706498215"
	local clone = script.Model:Clone()
	clone.PrimaryPart = clone.HumanoidRootPart
	clone:PivotTo(self._subject.RootPart.CFrame)
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	BetterDebris:AddItem(clone, 2.2)
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

	self:CreateSound("rbxassetid://77810366972840", 1, 1 + 0.1 * math.random(), nil, true, 5)
	wait(1)
	self:CreateSound("rbxassetid://76979641579471", 1, 1 + 0.1 * math.random(), nil, true, 5)
end

function object:_Init() end

return object