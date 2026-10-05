local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local Utility = require(ReplicatedStorage.Modules.Utility)
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayClient()
	self:_HideBody()
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local clone = script.Particles:Clone()
	clone.CFrame = rootPart.CFrame
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	Utility:PlayParticles(clone)
	self:CreateSound("rbxassetid://91581971640099", 1, 1, nil, true, 5)
	self:CreateSound("rbxassetid://90656022565955", 1.5, 1, nil, true, 5)
	self:CreateSound("rbxassetid://108364426842582", 1.5, 1, nil, true, 5)
	wait(3)
end

function object:_Init() end

return object