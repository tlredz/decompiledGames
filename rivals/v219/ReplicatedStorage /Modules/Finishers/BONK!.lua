local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
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

function object.PlayServer(object2, ...)
	Ragdoll.PlayServer(object2, ...)
	wait(1.0833333333333333)

	for _, part in pairs(object2:_GetObjects(true)) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CollisionGroup = "Noclip"
	end
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local cframe = CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
	local clone = script.Model:Clone()
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone:PivotTo(CFrame.new(rootPart.Position) * cframe - createVector(0, 1.5, 0))
	end)
	table.insert(self._connections, renderSteppedConnection)
	self:CreateSound("rbxassetid://85156927480464", 2, 0.75, nil, true, 5)
	local success, result = pcall(clone.AnimationController.LoadAnimation, clone.AnimationController, clone.Animation)

	if success then
		result:Play(0)
		wait(1.0833333333333333)
		self:CreateSound("rbxassetid://4164190231", 1, 1 + 0.1 * math.random(), nil, true, 5)
		local camera = Instance.new("Camera")
		local clone2 = script.Flattened:Clone()
		clone2.CFrame = CFrame.new(rootPart.Position)
		clone2.Parent = workspace
		table.insert(self._destroy_these, clone2)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				Utility:ScaleParticleEmitter(emitter, 2)
			end
		end

		Utility:PlayParticles(clone2)
		local surfaceGui = clone2.SurfaceGui
		surfaceGui.ViewportFrame.CurrentCamera = camera
		surfaceGui.Adornee = clone2
		surfaceGui.Parent = Players.LocalPlayer.PlayerGui
		table.insert(self._destroy_these, surfaceGui)
		local parent = self._is_humanoid and self._subject.Parent or self._subject
		parent.Archivable = true
		local clone3 = parent:Clone()
		clone3:PivotTo(clone3:GetPivot().Rotation)
		clone3.Parent = surfaceGui.ViewportFrame
		camera.CFrame = CFrame.new(createVector(0, 15, 0), createVector(0, 0, 0)) * CFrame.Angles(
			0,
			0,
			3.141592653589793
		)
		camera.FieldOfView = 30
		camera.Parent = surfaceGui.ViewportFrame

		for _, descendant in pairs(parent:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Transparency = 1
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("Decal") then
				descendant:Destroy()
			end
		end

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