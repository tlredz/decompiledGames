local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
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
	local clone = script.Particles:Clone()
	clone.Parent = rootPart
	table.insert(self._destroy_these, clone)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone.CFrame = CFrame.new(rootPart.Position)
	end)
	table.insert(self._connections, renderSteppedConnection)
	self:CreateSound("rbxassetid://71853893910123", 2, 1, nil, true, 5)
	wait(3)
	renderSteppedConnection:Disconnect()

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = false
		end
	end
end

function object:_Init() end

return object