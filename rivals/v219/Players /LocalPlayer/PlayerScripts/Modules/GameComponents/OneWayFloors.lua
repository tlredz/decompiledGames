local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._one_way_floors = {}
	self._enabled = false
	self:_Init()
	return self
end

function class:Update(_)
	if not self._enabled then
		return
	end

	local position = SpectateController.CurrentSubject and SpectateController.CurrentSubject.Entity and SpectateController.CurrentSubject.Entity.RootPart and SpectateController.CurrentSubject.Entity.RootPart.Position

	for k in pairs(self._one_way_floors) do
		local v = position and position.Y < k.Position.Y + 2
		k.LocalTransparencyModifier = v and 1 or 0
		k.CanCollide = not v
	end
end

function class:_CheckEnabled()
	self._enabled = next(self._one_way_floors) ~= nil
end

function class:_ObjectRemoved(p)
	self._one_way_floors[p] = nil
	self:_CheckEnabled()
end

function class:_ObjectAdded(p)
	self._one_way_floors[p] = true
	self:_CheckEnabled()
end

function class:_Init()
	CollectionService:GetInstanceRemovedSignal("OneWayFloor"):Connect(function(p)
		self:_ObjectRemoved(p)
	end)
	CollectionService:GetInstanceAddedSignal("OneWayFloor"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("OneWayFloor")) do
		task.spawn(self._ObjectAdded, self, v)
	end
end

return class._new()