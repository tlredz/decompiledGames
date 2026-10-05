local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ToyTrainPath = require(Players.LocalPlayer.PlayerScripts.Modules.ToyTrainPath)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self.Objects = {}
	self:_Init()
	return self
end

function object:Update(p2)
	for _, object2 in pairs(self.Objects) do
		object2:Update(p2)
	end
end

function object:_ObjectAdded(p2)
	local v = ToyTrainPath.new(p2)
	table.insert(self.Objects, v)
end

function object:_Init()
	CollectionService:GetInstanceAddedSignal("LobbyToyTrainPath"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LobbyToyTrainPath")) do
		task.defer(self._ObjectAdded, self, v)
	end
end

return object._new()