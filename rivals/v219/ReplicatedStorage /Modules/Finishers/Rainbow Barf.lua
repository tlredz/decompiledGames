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
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
	bodyVelocity.Velocity = (CFrame.new(createVector(0, 0, 0), createVector(0, 1, 0)) * CFrame.Angles(
		0,
		0,
		math.random() * 3.141592653589793 * 2
	) * CFrame.Angles(0, 0.7853981633974483 * (math.random() - 0.5), 0)).LookVector * 100
	bodyVelocity.Parent = rootPart
	BetterDebris:AddItem(bodyVelocity, 0.25)
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local head = self._is_humanoid and self._subject.Parent.Head or self._subject
	local clone = script.Particles:Clone()
	clone.CollisionGroup = "IgnorePlayers"
	clone.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(-1.5707963267948966, 0, 0) - createVector(0, 3, 0)
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	local cFrame = nil
	local total = 0
	local lastTime = tick()
	local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		total += dt
		clone.Finish.Puddle.Size = NumberSequence.new(total * 5 + 1)

		if not cFrame then
			clone.Start.WorldCFrame = head.CFrame
			return
		end

		local v = tick() - lastTime - 0.5
		local v2 = cFrame.Position + (clone.Finish.WorldPosition - cFrame.Position).Unit * math.clamp(
			v * 64,
			0,
			(clone.Finish.WorldPosition - cFrame.Position).Magnitude
		)
		clone.Start.WorldCFrame = CFrame.new(v2) * cFrame.Rotation
	end)
	table.insert(self._connections, renderSteppedConnection)
	self:CreateSound("rbxassetid://93843878451088", 1.5, 1, nil, true, 5)
	self:CreateSound("rbxassetid://108905869931161", 2, 1, nil, true, 5)
	wait(0.5)
	cFrame = head.CFrame
	wait((cFrame.Position - clone.Finish.WorldPosition).Magnitude / 64)
	renderSteppedConnection:Disconnect()

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = effect.Name == "Puddle"
		end
	end

	wait(2)
	clone.Finish.Puddle.Enabled = false
	wait(3)
end

function object:_Init() end

return object