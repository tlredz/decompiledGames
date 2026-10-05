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
	wait(0.5)
	self:_HideBody({ rootPart })
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local parent = self._is_humanoid and self._subject.Parent or self._subject
	parent.Archivable = true
	local clone = parent:Clone()
	table.insert(self._destroy_these, clone)
	local clone2 = self:_GetTemplate():Clone()
	clone2.Parent = workspace
	table.insert(self._destroy_these, clone2)
	local broken = clone2:FindFirstChild("Broken")

	if broken then
		for _, part in pairs(broken:GetDescendants()) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 1
			end
		end
	end

	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local cframe = CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
	local lastTime = tick()
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		local cframe2 = CFrame.new(rootPart.Position)
		local v, v2, v3

		if tick() < lastTime + 0.5 then
			v = math.clamp((tick() - lastTime) / 0.5, 0, 1)
			v2 = cframe2 * (cframe * CFrame.Angles(0, 3.141592653589793, 0):Lerp(CFrame.identity, v ^ 6))
			v3 = createVector(0, 128, 0)
		else
			local v4 = math.clamp((tick() - lastTime - 0.5) / 0.5, 0, 1)
			v = 1 - math.abs(math.sin(4.71238898038469 * v4) * (1 - v4))
			v2 = cframe2 * (cframe * CFrame.identity:Lerp(CFrame.Angles(0, 2.827433388230814, 0), 1 - (1 - v4) ^ 6))
			v3 = createVector(0, 12, 0)
		end

		clone2:PivotTo(v2 + v3:Lerp(createVector(0, 0, 0), v))
	end)
	table.insert(self._connections, heartbeatConnection)
	wait(0.5)

	if broken then
		clone2.Normal:Destroy()

		for _, part in pairs(broken:GetDescendants()) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 0
			end
		end
	end

	local camera = Instance.new("Camera")
	local clone3 = script.Flattened:Clone()
	clone3.CFrame = CFrame.new(rootPart.Position)
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
	self:CreateSound("rbxassetid://122470995632560", 1, 1, nil, true, 5)
	self:CreateSound("rbxassetid://88491524279903", 1, 1, nil, true, 5)

	if clone2.Name == "Piano" then
		self:CreateSound("rbxassetid://129097983310355", 1, 0.75 + 0.5 * math.random(), nil, true, 5)
	end

	wait(0.5)
	heartbeatConnection:Disconnect()
	wait(3)
end

function object:_GetSortedChildren()
	local children = script.Models:GetChildren()
	table.sort(children, function(a, b)
		return Utility:StringLessThan(a.Name, b.Name)
	end)
	return children
end

function object:_GetTemplate()
	local _GetSortedChildren = self:_GetSortedChildren()
	return _GetSortedChildren[Random.new(self._serial and self._serial.Seed or self._seed):NextInteger(
		1,
		#_GetSortedChildren
	)]
end

function object:_Init() end

return object