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

function object:PlayServer(...)
	Ragdoll.PlayServer(self, ...)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local humanoidRootPart = self._eliminator and self._eliminator.Character and self._eliminator.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(10000, 10000, 10000)
	bodyVelocity.Velocity = CFrame.new(humanoidRootPart.Position, rootPart.Position).LookVector * 100
	bodyVelocity.Parent = rootPart
	BetterDebris:AddItem(bodyVelocity, 3)
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local humanoidRootPart = self._eliminator and self._eliminator.Character and self._eliminator.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local clone = script.Particles:Clone()
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	self:CreateSound("rbxassetid://87269038986811", 1.25, 0.95 + 0.1 * math.random(), rootPart, true, 10)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local cframe = CFrame.new(humanoidRootPart.Position, rootPart.Position)
		clone.Hit.WorldCFrame = CFrame.new(rootPart.Position) * cframe.Rotation
		clone.Start.WorldCFrame = cframe * CFrame.new(0, 0, -1)
	end)
	table.insert(self._connections, renderSteppedConnection)
	local v = {}

	for _, beam in pairs(clone:GetDescendants()) do
		if beam:IsA("Beam") then
			v[beam] = { beam.Width0, beam.Width1 }
		end
	end

	Utility:RenderstepForLoop(0, 1, 0.01, function(p)
		local v2 = 1 - p ^ 4

		for k, v3 in pairs(v) do
			k.Width0 = v3[1] * v2
			k.Width1 = v3[2] * v2
		end
	end)

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = false
		end
	end

	wait(1)
	renderSteppedConnection:Disconnect()
end

function object:_Init() end

return object