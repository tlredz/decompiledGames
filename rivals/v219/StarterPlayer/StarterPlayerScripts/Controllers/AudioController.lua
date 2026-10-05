game:GetService("CollectionService")
local Players = game:GetService("Players")
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._connections = {}
	self._local_fighter = nil
	self:_Init()
	return self
end

function class._ObjectAdded(_, instance)
	if not (SpectateController.CurrentSubject and SpectateController.CurrentSubject.FighterInterface) then
		return
	end

	if instance:IsDescendantOf(workspace) and instance.Parent:IsA("BasePart") then
		SpectateController.CurrentSubject.FighterInterface.AudioVisualizers:Create(
			instance,
			instance.RollOffMinDistance,
			instance.RollOffMaxDistance
		)
	end
end

function class:_UpdateEnabled()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
end

function class:_HookLocalFighter()
	self._local_fighter = FighterController:WaitForLocalFighter()
	self._local_fighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
		self:_UpdateEnabled()
	end)
	self._local_fighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_UpdateEnabled()
	end)
	self:_UpdateEnabled()
end

function class:_Init()
	PlayerDataController:GetSettingChangedSignal("Audio Visualizers"):Connect(function()
		self:_UpdateEnabled()
	end)
	self:_UpdateEnabled()
	task.defer(self._HookLocalFighter, self)
end

return class._new()