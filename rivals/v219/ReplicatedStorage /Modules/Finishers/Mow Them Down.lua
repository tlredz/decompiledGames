local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
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
	wait(0.794)
	self:_HideBody({ rootPart })
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local parent = self._is_humanoid and self._subject.Parent or self._subject
	parent.Archivable = true
	local clone = parent:Clone()
	table.insert(self._destroy_these, clone)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local _GetGroundPosition = self:_GetGroundPosition(rootPart.Position, self:_GetObjects(true))
	local clone2 = script.Model:Clone()
	clone2.Parent = workspace
	table.insert(self._destroy_these, clone2)
	local descendants = {}

	for _, descendant in pairs(clone2:GetDescendants()) do
		if not (descendant:IsA("BasePart") or descendant:IsA("ParticleEmitter") or descendant:IsA("Beam")) then
			continue
		end

		table.insert(descendants, descendant)
	end

	local position = nil
	local unit = (Random.new():NextUnitVector() * createVector(1, 0, 1)).Unit
	local lastTime = tick()
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v = math.clamp((tick() - lastTime) / 1, 0, 1) ^ 3
		local localTransparencyModifier = (1 - math.sin(3.141592653589793 * v)) ^ 10

		if not position or v < 0.4 then
			position = rootPart.Position
		end

		clone2:PivotTo(CFrame.new(position.X, _GetGroundPosition.Y, position.Z) * CFrame.new(
			createVector(0, 0, 0),
			-unit
		).Rotation * CFrame.new(0, 0, v * 32 + -16) * CFrame.Angles(0, -1.5707963267948966, 0))

		for _, v3 in pairs(descendants) do
			v3.LocalTransparencyModifier = localTransparencyModifier
		end
	end)
	table.insert(self._connections, renderSteppedConnection)
	self:CreateSound("rbxassetid://70481114201477", 1, 1 + 0.25 * math.random(), clone2:GetChildren()[1], true, 10)
	self:CreateSound("rbxassetid://96644061235295", 1, 1 + 0.25 * math.random(), clone2:GetChildren()[1], true, 10)
	wait(0.5940000000000001)
	self:CreateSound("rbxassetid://88391131441060", 1, 1 + 0.25 * math.random(), clone2:GetChildren()[1], true, 10)
	wait(0.2)
	local camera = Instance.new("Camera")
	local clone3 = script.Flattened:Clone()
	clone3.CFrame = CFrame.new(self:_GetGroundPosition(rootPart.Position, self:_GetObjects(true)))
	clone3.Parent = workspace
	table.insert(self._destroy_these, clone3)

	for _, v in pairs({ clone2:GetDescendants(), self:_GetObjects(true) }) do
		for _, part in pairs(v) do
			if not part:IsA("BasePart") then
				continue
			end

			local noCollisionConstraint = Instance.new("NoCollisionConstraint")
			noCollisionConstraint.Part0 = part
			noCollisionConstraint.Part1 = clone3
			noCollisionConstraint.Parent = clone3
		end
	end

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, 2)
		end
	end

	Utility:PlayParticles(clone3)
	local surfaceGui = clone3.SurfaceGui
	surfaceGui.ViewportFrame.CurrentCamera = camera
	surfaceGui.Adornee = clone3
	surfaceGui.Parent = Players.LocalPlayer.PlayerGui
	table.insert(self._destroy_these, surfaceGui)
	local clone4 = clone:Clone()
	clone4:PivotTo(clone4:GetPivot().Rotation)
	clone4.Parent = surfaceGui.ViewportFrame
	camera.CFrame = CFrame.new(createVector(0, 15, 0), createVector(0, 0, 0)) * CFrame.Angles(0, 0, 3.141592653589793)
	camera.FieldOfView = 30
	camera.Parent = surfaceGui.ViewportFrame
	wait(0.20599999999999996)
	renderSteppedConnection:Disconnect()
	wait(3)
	clone2:Destroy()
end

function object:_Init() end

return object