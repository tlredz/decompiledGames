local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
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
	if not self._is_humanoid then
		return
	end

	local rootPart = self._subject.RootPart
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = createVector(0, 0, 0)
	bodyVelocity.MaxForce = createVector(10000, 0, 10000)
	bodyVelocity.Parent = rootPart
	table.insert(self._destroy_these, bodyVelocity)
	BetterDebris:AddItem(bodyVelocity, 0.5)
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.CFrame = CFrame.new(createVector(0, 0, 0), rootPart.CFrame.LookVector * createVector(1, 0, 1))
	bodyGyro.MaxTorque = createVector(100000, 100000, 100000)
	bodyGyro.Parent = rootPart
	table.insert(self._destroy_these, bodyGyro)
	BetterDebris:AddItem(bodyGyro, 0.5)
	wait(0.5)
	bodyVelocity:Destroy()
	bodyGyro:Destroy()
	self:_Ragdoll()
	self:_AnchorModel()
	local bodyVelocity2 = Instance.new("BodyVelocity")
	bodyVelocity2.MaxForce = createVector(100000, 100000, 100000)
	bodyVelocity2.Velocity = rootPart.CFrame.RightVector * 64
	bodyVelocity2.Parent = rootPart
	table.insert(self._destroy_these, bodyVelocity2)
	BetterDebris:AddItem(bodyVelocity2, 0.2)
end

function object:PlayClient()
	if not self._is_humanoid then
		return
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://101848673881346"
	local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

	if success then
		result:Play(0)
	end

	wait(0.25)
	local clone = script.Particles:Clone()
	clone.Parent = workspace
	clone.CFrame = (self._is_humanoid and self._subject.RootPart or self._subject).CFrame
	table.insert(self._destroy_these, clone)
	Utility:PlayParticles(clone)
	self:CreateSound("rbxassetid://79427627396361", 1.5, 0.95 + 0.1 * math.random(), nil, true, 5)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
	highlight.OutlineTransparency = 0
	highlight.FillTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = self._subject.Parent
	table.insert(self._destroy_these, highlight)
	wait(0.05)
	highlight.FillColor = Color3.fromRGB(0, 0, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	wait(0.05)
	highlight.FillColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
	wait(0.05)
	highlight:Destroy()
end

function object:_Init() end

return object