local createVector = vector.create
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

function object:PlayServer(...)
	Ragdoll.PlayServer(self, ...)
	local head = self._is_humanoid and self._subject.Parent.Head or self._subject
	Utility:Knockback(head, Random.new():NextUnitVector() * createVector(1, 0, 1) * 50 + createVector(0, 25, 0))
	self:CreateSound("rbxassetid://127579435864391", 1, 1.5 + 0.25 * math.random(), nil, true, 5)
end

function object:_Init() end

return object