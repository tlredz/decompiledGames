local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Utility)
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(4.75, script.Name, ...), object)
	self:_Init()
	return self
end

function object:PlayClient(...)
	Emote.PlayClient(self, ...)
	local _SetupMultipleProps = self:_SetupMultipleProps(script.ShovelProp)
	self:_PlayAnimation("rbxassetid://113838171758638")
	local clone = script.Objects:GetChildren()[Random.new(self._serial and self._serial.Seed or self._seed):NextInteger(
		1,
		#script.Objects:GetChildren()
	)]:Clone()
	clone:PivotTo(_SetupMultipleProps.Item.CFrame * CFrame.Angles(
		math.random() * 3.141592653589793 * 2,
		math.random() * 3.141592653589793 * 2,
		math.random() * 3.141592653589793 * 2
	))
	clone.Parent = _SetupMultipleProps.Item

	for _, child in pairs(clone:GetChildren()) do
		child.CanCollide = false
		child.CanTouch = false
		child.CanQuery = false
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = child
		weldConstraint.Part1 = _SetupMultipleProps.Item
		weldConstraint.Parent = child
		child.Anchored = false
	end

	self:CreateSound("rbxassetid://109469242170265", 0.5, 1, nil, true, 10)
	wait(0.55)
	self:CreateSound("rbxassetid://121837464389656", 1, 1, nil, true, 10)
	wait(0.35)
	self:CreateSound("rbxassetid://83701499105576", 1, 1, nil, true, 10)
	wait(0.6)
	self:CreateSound("rbxassetid://83701499105576", 0.9, 1.1, nil, true, 10)
	wait(0.6)
	self:CreateSound("rbxassetid://83701499105576", 0.8, 1.2, nil, true, 10)
end

function object:_Init() end

return object