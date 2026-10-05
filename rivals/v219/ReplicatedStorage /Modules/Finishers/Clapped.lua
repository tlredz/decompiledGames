local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Spring = require(ReplicatedStorage.Modules.Spring)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object.PlayServer(object2)
	object2:_AnchorModel(0)
	wait(0.3)
	object2:_HideBody()
end

function object:PlayClient()
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local cframe = CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
	local parent = self._is_humanoid and self._subject.Parent or self._subject
	parent.Archivable = true
	local clone = parent:Clone()
	table.insert(self._destroy_these, clone)
	local clone2 = script.Model:Clone()
	clone2.Parent = workspace
	table.insert(self._destroy_these, clone2)
	local inverse = clone2.Left:GetPivot():ToObjectSpace(clone2.PrimaryPart.CFrame):Inverse()
	local inverse2 = clone2.Right:GetPivot():ToObjectSpace(clone2.PrimaryPart.CFrame):Inverse()
	local v = Spring.new(rootPart.Position, 1, 10)
	local size = clone2.Right.Size
	local size2 = clone2.Left.Size
	local lastTime = tick()

	while tick() < lastTime + 0.3 do
		local v2 = math.clamp((tick() - lastTime) / 0.3, 0, 1) ^ 2
		v.Target = rootPart.Position
		clone2.PrimaryPart.CFrame = CFrame.new(v.Value) * cframe
		clone2.Right.Size = size * (v2 * 1 + 1)
		clone2.Left.Size = size2 * (v2 * 1 + 1)
		clone2.Right:PivotTo(clone2.PrimaryPart.CFrame * inverse2 * CFrame.Angles(0, 0, v2 * -2.356194490192345))
		clone2.Left:PivotTo(clone2.PrimaryPart.CFrame * inverse * CFrame.Angles(0, 0, v2 * 2.356194490192345))
		RunService.RenderStepped:Wait()
	end

	self:CreateSound("rbxassetid://100411689677104", 1.5, 1, clone2.Primary, true, 5)
	self:CreateSound("rbxassetid://92760487729234", 2.5, 1, clone2.Primary, true, 5)
	Utility:PlayParticles(clone2)
	local clone3 = script.Flattened:Clone()
	clone3.CFrame = CFrame.new(rootPart.Position) * cframe
	clone3.RotVelocity = createVector(0, 20, 0) + Random.new():NextUnitVector() * 5
	clone3.Parent = workspace
	table.insert(self._destroy_these, clone3)

	for _, part in pairs(self:_GetObjects(true)) do
		if not part:IsA("BasePart") then
			continue
		end

		local noCollisionConstraint = Instance.new("NoCollisionConstraint")
		noCollisionConstraint.Part0 = part
		noCollisionConstraint.Part1 = clone3
		noCollisionConstraint.Parent = clone3
	end

	local v2 = { cframe * CFrame.new(0, 0, 15), cframe * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(
			0,
			0,
			15
		) }

	for k, v3 in pairs(v2) do
		local camera = Instance.new("Camera")
		local v4 = clone3[k]
		v4.ViewportFrame.CurrentCamera = camera
		v4.Adornee = clone3
		v4.Parent = Players.LocalPlayer.PlayerGui
		local clone4 = clone:Clone()
		clone4:PivotTo(clone4:GetPivot().Rotation)
		clone4.Parent = v4.ViewportFrame
		camera.CFrame = CFrame.new(v3.Position, createVector(0, 0, 0))
		camera.FieldOfView = 30
		camera.Parent = v4.ViewportFrame
	end

	local pivot = clone2:GetPivot()
	local now = tick()

	while tick() < now + 0.1 do
		clone2:PivotTo(pivot + Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * math.random() * 1)
		RunService.RenderStepped:Wait()
	end

	for _, part in pairs(clone2:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
		end
	end
end

function object:_Init() end

return object