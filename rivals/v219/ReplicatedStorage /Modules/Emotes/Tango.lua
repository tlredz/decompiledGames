local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(nil, script.Name, ...), object)
	self:_Init()
	return self
end

function object:PlayClient(...)
	Emote.PlayClient(self, ...)
	self:_PlayAnimation("rbxassetid://88145538779312", "rbxassetid://96300514550662", 1.2)
	local createSound = self:CreateSound("rbxassetid://139966463950646", 1, 1, nil, true)
	createSound.Looped = true
	local head = self._humanoid and self._humanoid.Parent and self._humanoid.Parent:FindFirstChild("Head")
	local clone = script.Rose:Clone()
	clone:PivotTo(head.CFrame)
	clone.Parent = head
	table.insert(self._destroy_these, clone)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = head
	weldConstraint.Part1 = clone.Primary
	weldConstraint.Parent = clone
end

function object:_Init() end

return object