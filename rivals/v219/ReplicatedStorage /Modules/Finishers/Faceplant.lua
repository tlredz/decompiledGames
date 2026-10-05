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
	local rootPart = self._subject.RootPart
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = createVector(0, 0, 0)
	bodyVelocity.MaxForce = createVector(10000, 0, 10000)
	bodyVelocity.Parent = rootPart
	table.insert(self._destroy_these, bodyVelocity)
	BetterDebris:AddItem(bodyVelocity, 1.05)
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.CFrame = CFrame.new(createVector(0, 0, 0), rootPart.CFrame.LookVector * createVector(1, 0, 1))
	bodyGyro.MaxTorque = createVector(100000, 100000, 100000)
	bodyGyro.Parent = rootPart
	table.insert(self._destroy_these, bodyGyro)
	BetterDebris:AddItem(bodyGyro, 1.05)
	wait(1.05)
	self:_Ragdoll()
	self:_AnchorModel()
end

function object:PlayClient()
	if not self._is_humanoid then
		return
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://85156698673400"
	local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

	if success then
		result:Play(0)
	end
end

function object:_Init() end

return object