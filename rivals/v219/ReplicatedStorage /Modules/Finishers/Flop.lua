local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage.Modules.BetterDebris)
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local Utility = require(ReplicatedStorage.Modules.Utility)
local v = { "rbxassetid://88375867455898", "rbxassetid://79484939092852", "rbxassetid://107671189154511" }
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayServer(...)
	Ragdoll.PlayServer(self, ...)

	if not self._is_humanoid then
		return
	end

	self:_InternalThread(task.spawn, function()
		while true do
			wait(0.25)

			if self._destroyed then
				break
			end

			Utility:Knockback(self._subject.RootPart, createVector(0, 20, 0))
			self:CreateSound(v[math.random(#v)], 1.25, 1 + 0.1 * math.random(), nil, true, 5)
			wait(0.5)

			if self._destroyed then
				break
			end
		end
	end)
end

function object:_Init() end

return object