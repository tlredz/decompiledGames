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
	self:_BreakJoints()
	self:_InternalThread(task.delay, 0.25, self._BreakJoints, self)
	self:_AnchorModel()

	for _, part in pairs(self:_GetObjects()) do
		if part:IsA("BasePart") then
			part.AssemblyLinearVelocity += Vector3.new(math.random() - 0.5, math.random(), math.random() - 0.5) * 10
		end
	end
end

function object.PlayClient(object2)
	object2:CreateSound("rbxassetid://79348298352567", 1.25, 1 + 0.1 * math.random(), nil, true)
end

function object:_Init() end

return object