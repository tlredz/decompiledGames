local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local Utility = require(ReplicatedStorage.Modules.Utility)
local v = CFrame.Angles(0, 3.141592653589793, 0) * CFrame.Angles(1.5707963267948966, 0, 1.5707963267948966) * CFrame.Angles(
	0,
	-1.5707963267948966,
	0
)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object:PlayServer(...)
	Finisher.PlayServer(self, ...);
	(self._is_humanoid and self._subject.RootPart or self._subject).Anchored = true
	wait(3.15)

	for _, part in pairs(self:_GetObjects(true)) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CollisionGroup = "Noclip"
	end
end

function object:PlayClient()
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject

	if self._is_humanoid then
		pcall(function()
			local animation = Instance.new("Animation")
			animation.AnimationId = "rbxassetid://102021872417441"
			self._subject:LoadAnimation(animation):Play()
		end)
	end

	local clone = nil
	local clone2 = script:WaitForChild("Sign"):Clone()
	clone2.Parent = workspace
	table.insert(self._destroy_these, clone2)
	self:CreateSound("rbxassetid://8970814778", 1, 0.9, nil, true, 5)
	local cframe = CFrame.new(0, 256, 0)
	local identity = CFrame.identity
	local _ = clone2.Size
	local lastTime = tick()
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v2 = math.clamp((tick() - lastTime) / 3.15, 0, 1) ^ 2
		local _ = math.clamp((tick() - (lastTime + 3.15)) / 4, 0, 1) ^ 2
		local position = clone and clone.Position or rootPart.Position
		local v3 = CFrame.new(position) * cframe:Lerp(identity, v2) + Vector3.new(0, clone2.Size.X / 2, 0)
		local cframe2 = CFrame.new(
			v3.Position * createVector(1, 0, 1),
			workspace.CurrentCamera.CFrame.Position * createVector(1, 0, 1)
		)
		clone2:PivotTo(v3 * (cframe2.LookVector == cframe2.LookVector and cframe2.Rotation or CFrame.identity) * v)
	end)
	table.insert(self._connections, renderSteppedConnection)
	wait(3.15)
	self:CreateSound("rbxassetid://105824621418784", 1.25, 1, nil, true, 5)
	self:CreateSound("rbxassetid://89635888410432", 1.25, 1, nil, true, 5)
	local camera = Instance.new("Camera")
	clone = script.Flattened:Clone()
	clone.CFrame = CFrame.new(rootPart.Position)
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, 3)
		end
	end

	Utility:PlayParticles(clone)
	local surfaceGui = clone.SurfaceGui
	surfaceGui.ViewportFrame.CurrentCamera = camera
	surfaceGui.Adornee = clone
	surfaceGui.Parent = Players.LocalPlayer.PlayerGui
	table.insert(self._destroy_these, surfaceGui)
	local parent = self._is_humanoid and self._subject.Parent or self._subject
	parent.Archivable = true
	local clone3 = parent:Clone()
	clone3:PivotTo(clone3:GetPivot().Rotation)
	clone3.Parent = surfaceGui.ViewportFrame
	camera.CFrame = CFrame.new(createVector(0, 15, 0), createVector(0, 0, 0)) * CFrame.Angles(0, 0, 3.141592653589793)
	camera.FieldOfView = 30
	camera.Parent = surfaceGui.ViewportFrame

	for _, descendant in pairs(parent:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = 1
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("Decal") then
			descendant:Destroy()
		end
	end

	wait(2)
	clone.CanCollide = false
	wait(2)
	renderSteppedConnection:Disconnect()
	clone2:Destroy()
end

function object:_Init() end

return object