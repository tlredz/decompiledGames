local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
require(ReplicatedStorage.Modules.Utility)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayServer(...)
	Ragdoll.PlayServer(self, ...)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(0, 10000, 0)
	bodyVelocity.Velocity = createVector(0, -100, 0)
	bodyVelocity.Parent = self._is_humanoid and self._subject.RootPart or self._subject
	BetterDebris:AddItem(bodyVelocity, 3)
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local _GetGroundPosition = self:_GetGroundPosition(
		rootPart.Position,
		{ self._is_humanoid and self._subject.Parent or self._subject }
	)

	for _, part in pairs(self:_GetObjects(true)) do
		if part:IsA("BasePart") and part ~= rootPart then
			part:Destroy()
		end
	end

	rootPart.Size = createVector(0, 0, 0)
	local clone = script.DustPile:Clone()
	clone.Anchored = true
	clone.Size = createVector(0, 0, 0)
	clone.CFrame = CFrame.new(_GetGroundPosition) * CFrame.new(0, clone.Size.Y / 2, 0)
	clone.CollisionGroup = "IgnoreEntities"
	clone.Parent = rootPart
	table.insert(self._destroy_these, clone)
	TweenService:Create(clone, tweenInfo, {
		Size = script.DustPile.Size
	}):Play()
	local clone2 = script.Particles:Clone()
	clone2.Parent = clone
	table.insert(self._destroy_these, clone2)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone2.CFrame = CFrame.new(clone.Position + createVector(0, 1, 0))
	end)
	table.insert(self._connections, renderSteppedConnection)
	self:CreateSound("rbxassetid://118654142384127", 1.25, 0.95 + 0.1 * math.random(), clone2, true, 10)
	wait(1)
	renderSteppedConnection:Disconnect()

	for _, effect in pairs(clone2:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = false
		end
	end

	clone.Smoke.smoke1.Enabled = false
	clone.Smoke.smoke2.Enabled = false
	wait(1)
	clone2:Destroy()
	wait(1)
	TweenService:Create(clone, tweenInfo2, {
		Size = createVector(0, 0, 0)
	}):Play()
	wait(1)
end

function object:_Init() end

return object