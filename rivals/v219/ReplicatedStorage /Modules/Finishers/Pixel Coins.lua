local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object.PlayServer(object2)
	object2:_AnchorModel(0)
end

function object:PlayClient()
	local position = (self._is_humanoid and self._subject.RootPart or self._subject).Position
	local parent = self._is_humanoid and self._subject.Parent or self._subject
	local parent2 = parent.Parent
	self:CreateSound("rbxassetid://111721022295307", 1.25, 0.95 + 0.1 * math.random(), position, true, 10)

	for _ = 1, 6 do
		parent.Parent = parent2
		wait(0.07)
		parent.Parent = nil
		wait(0.07)
	end

	self:CreateSound("rbxassetid://122871435090543", 1.5, 0.9 + 0.2 * math.random(), position, true, 10)
	self:CreateSound("rbxassetid://11188024605", 1, 0.9 + 0.2 * math.random(), position, true, 10)
	local clone = script.Model:Clone()
	clone:PivotTo(CFrame.new(position) * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0))
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	local success, result = pcall(clone.AnimationController.LoadAnimation, clone.AnimationController, clone.Animation)

	if success then
		result:Play(0)

		if result.IsPlaying then
			result.Stopped:Wait()
		end
	end

	clone:Destroy()
end

function object:_Init() end

return object