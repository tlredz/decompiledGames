local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._objects = {}
	self:_Init()
	return self
end

function class:_ObjectAdded(instance)
	local soundID = instance:GetAttribute("SoundID")
	local volume = instance:GetAttribute("Volume")
	local v = {
		Connections = {},
		Cooldowns = {}
	}
	table.insert(v.Connections, instance.Touched:Connect(function(otherPart)
		local assemblyRootPart = otherPart.AssemblyRootPart or otherPart
		local fighter = assemblyRootPart and FighterController:GetFighter(assemblyRootPart.Parent)

		if not fighter or not fighter:IsAlive() or tick() < (v.Cooldowns[assemblyRootPart] or 0) then
			return
		end

		v.Cooldowns[assemblyRootPart] = tick() + 1
		Utility:CreateSound(soundID, volume or 1, 0.95 + 0.1 * math.random(), instance, true, 10)
	end))
	self._objects[instance] = v
end

function class:_ObjectRemoved(p2)
	local _object = self._objects[p2]

	if not _object then
		return
	end

	for _, connection in pairs(_object.Connections) do
		connection:Disconnect()
	end

	self._objects[p2] = nil
end

function class:_Init()
	CollectionService:GetInstanceAddedSignal("SoundTrigger"):Connect(function(p)
		self:_ObjectAdded(p)
	end)
	CollectionService:GetInstanceRemovedSignal("SoundTrigger"):Connect(function(p)
		self:_ObjectRemoved(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("SoundTrigger")) do
		task.defer(self._ObjectAdded, self, v)
	end
end

return class._new()