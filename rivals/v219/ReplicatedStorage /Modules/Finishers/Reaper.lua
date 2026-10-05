local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("Players")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayServer(...)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	rootPart.Anchored = true
	wait(0.9)
	rootPart.Anchored = false
	local waist = self._is_humanoid and self._subject.Parent:FindFirstChild("Waist", true)

	if waist then
		waist:Destroy()
	end

	Ragdoll.PlayServer(self, ...)
	local upperTorso = self._is_humanoid and self._subject.Parent:FindFirstChild("UpperTorso")

	if upperTorso then
		upperTorso.Velocity = (Random.new():NextUnitVector() * createVector(1, 0, 1) + Vector3.new(0, math.random(), 0)) * (50 + 150 * math.random())
	end
end

function object:PlayClient()
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local cframe = CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)

	if self._is_humanoid then
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://4769412289"
		local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

		if success then
			result:Play(0)
			result:AdjustSpeed(0.16666666666666666)
		end
	end

	local clone = script.Model:Clone()
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone:PivotTo(CFrame.new(rootPart.Position) * cframe)
	end)
	table.insert(self._connections, renderSteppedConnection)
	local success, result = pcall(clone.AnimationController.LoadAnimation, clone.AnimationController, clone.Animation)

	if success then
		result:Play(0)
		self:CreateSound("rbxassetid://85156927480464", 2, 1, nil, true, 5)
		wait(0.7)
		self:CreateSound("rbxassetid://14111617408", 2, 1, nil, true, 5)
		self:CreateSound("rbxassetid://14111617269", 1.5, 1, nil, true, 5)
		wait(0.2)
		Utility:PlayParticles(clone.HumanoidRootPart.Particles)

		if result.IsPlaying then
			result.Stopped:Wait()
		end

		clone:Destroy()
		wait(3)
	end

	renderSteppedConnection:Disconnect()
end

function object:_Init() end

return object