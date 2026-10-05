local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._connections = {}
	self:_Init()
	return self
end

function class:_ObjectRemoved(p2)
	if self._connections[p2] then
		self._connections[p2]:Disconnect()
		self._connections[p2] = nil
	end
end

function class:_ObjectAdded(p)
	self:_ObjectRemoved(p)
	self._connections[p] = p.Triggered:Connect(function()
		ReplicatedStorage.Remotes.Replication.Fighter.SnowballGrab:FireServer(p)
	end)
end

function class:_Init()
	CollectionService:GetInstanceAddedSignal("LobbySnowballSource"):Connect(function(p)
		self:_ObjectAdded(p)
	end)
	CollectionService:GetInstanceRemovedSignal("LobbySnowballSource"):Connect(function(p)
		self:_ObjectRemoved(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LobbySnowballSource")) do
		task.spawn(self._ObjectAdded, self, v)
	end
end

return class._new()