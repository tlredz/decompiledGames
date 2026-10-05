local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
require(ReplicatedStorage.Modules.Utility)
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayServer(...)
	Ragdoll.PlayServer(self, ...)
	local upperTorso = self._is_humanoid and (self._subject.Parent:FindFirstChild("UpperTorso") or self._subject.RootPart) or self._subject
	local humanoidRootPart = self._eliminator and self._eliminator.Character and self._eliminator.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	for _, part in pairs(self:_GetObjects(true)) do
		if part:IsA("BasePart") then
			part.CustomPhysicalProperties = PhysicalProperties.new(
				part.CurrentPhysicalProperties.Density,
				2,
				0,
				100,
				100
			)
		end
	end

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(10000, 10000, 10000)
	bodyVelocity.Velocity = CFrame.new(humanoidRootPart.Position, upperTorso.Position).LookVector * 300
	bodyVelocity.Parent = upperTorso
	BetterDebris:AddItem(bodyVelocity, 5)
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.CFrame = CFrame.new(upperTorso.Position, humanoidRootPart.Position)
	bodyGyro.Parent = upperTorso
	BetterDebris:AddItem(bodyGyro, 5)
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local upperTorso = self._is_humanoid and (self._subject.Parent:FindFirstChild("UpperTorso") or self._subject.RootPart) or self._subject
	local clone = script.Icicle:Clone()
	clone.CFrame = upperTorso.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
	clone.WeldConstraint.Part0 = upperTorso
	clone.Parent = upperTorso
	table.insert(self._destroy_these, clone)
	BetterDebris:AddItem(clone.WeldConstraint, 5 + tweenInfo.Time / 2)
	self:CreateSound("rbxassetid://73317248668904", 1, 1 + 0.1 * math.random(), nil, true, 5)
	self:CreateSound("rbxassetid://115260318005653", 1.5, 1 + 0.1 * math.random(), nil, true, 5)
	wait(5)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(0, 0, 0)
	}):Play()
	wait(tweenInfo.Time)
end

function object:_Init() end

return object