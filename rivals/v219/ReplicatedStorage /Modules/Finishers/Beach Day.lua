local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

	self:_AnchorModel(false, 0)
	local clone = script.Model:Clone()
	clone:SetPrimaryPartCFrame(self._subject.RootPart.CFrame)
	clone.PrimaryPart.Anchored = true
	clone.Parent = self._subject
	table.insert(self._destroy_these, clone)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = clone.PrimaryPart
	weldConstraint.Part1 = self._subject.RootPart
	weldConstraint.Parent = clone
	clone.PrimaryPart.Anchored = false
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://72904319869602"
	table.insert(self._destroy_these, animation)
	local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

	if success then
		table.insert(self._destroy_these, result)
		result:Play(0)
	end

	self._subject.RootPart.Velocity = Random.new():NextUnitVector() * (24 + 8 * math.random())
	self._subject.RootPart.RotVelocity = createVector(0, 1, 0) * (0 + 36 * math.random())
end

function object:PlayClient()
	if not self._is_humanoid then
		return
	end

	self:CreateSound("rbxassetid://88366458741976", 1, 1 + 0.25 * math.random(), self._subject.RootPart, true, 10)
end

function object:_Init() end

return object