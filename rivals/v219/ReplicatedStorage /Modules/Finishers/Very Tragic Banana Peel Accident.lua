local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object:PlayServer()
	if not self._is_humanoid then
		return
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://89773418199914"
	local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

	if success then
		result:Play(0)
	end

	local rootPart = self._subject.RootPart
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = createVector(0, 0, 0)
	bodyVelocity.MaxForce = createVector(10000, 10000, 10000)
	bodyVelocity.Parent = rootPart
	table.insert(self._destroy_these, bodyVelocity)
	BetterDebris:AddItem(bodyVelocity, 0.3)
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.CFrame = CFrame.new(createVector(0, 0, 0), rootPart.CFrame.LookVector * createVector(1, 0, 1))
	bodyGyro.MaxTorque = createVector(100000, 100000, 100000)
	bodyGyro.Parent = rootPart
	table.insert(self._destroy_these, bodyGyro)
	BetterDebris:AddItem(bodyGyro, 0.3)
	wait(0.3)
	bodyGyro:Destroy()
	bodyVelocity:Destroy()
	self:_Ragdoll()
	self:_AnchorModel()
end

function object:PlayClient()
	if not self._is_humanoid then
		return
	end

	local clone = script.Peel:Clone()
	clone.MeshPart1.CollisionGroup = "IgnoreEntities"
	clone.MeshPart2.CollisionGroup = "IgnoreEntities"
	clone.MeshPart3.CollisionGroup = "IgnoreEntities"
	clone.Primary.CollisionGroup = "IgnoreEntities"
	clone.Parent = workspace
	clone:PivotTo(self._subject.RootPart.CFrame * CFrame.new(-0.5, -2.5, -1))
	table.insert(self._destroy_these, clone)
	self:CreateSound("rbxassetid://8845788882", 2, 1, nil, true, 5)
	wait(0.075)
	clone.PrimaryPart.Anchored = false
	clone.PrimaryPart.Velocity = ((CFrame.new(self._subject.RootPart.Position, clone.PrimaryPart.Position).LookVector * createVector(
		1,
		0,
		1
	)).Unit + createVector(0, 2, 0)) * 20
	clone.PrimaryPart.RotVelocity = Random.new():NextUnitVector() * (15 + 60 * math.random())
end

function object:_Init() end

return object