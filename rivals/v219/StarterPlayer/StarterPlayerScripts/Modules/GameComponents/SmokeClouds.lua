local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.BetterDebris)
require(ReplicatedStorage.Modules.Utility)
require(ReplicatedStorage.Modules.Spring)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local SmokeCloud = require(Players.LocalPlayer.PlayerScripts.Modules.SmokeCloud)
Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("Misc"):WaitForChild("SmokeClouds")
local smokeClouds = Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("SmokeClouds")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._smoke_clouds = {}
	self:_Init()
	return self
end

function class:Update(p2)
	local v = {}

	for k, _smoke_cloud in pairs(self._smoke_clouds) do
		if _smoke_cloud:IsDestroyed() then
			v[k] = true
		elseif SpectateController:IsRendered(_smoke_cloud.EnvironmentID) then
			_smoke_cloud:Update(p2)
		end
	end

	for k in pairs(v) do
		self._smoke_clouds[k] = nil
	end
end

function class:_ObjectRemoved(p2)
	local _smoke_cloud = self._smoke_clouds[p2]

	if not _smoke_cloud then
		return
	end

	_smoke_cloud:Clear()
end

function class:_ObjectAdded(p)
	if self._smoke_clouds[p] then
		self._smoke_clouds[p]:Destroy()
		self._smoke_clouds[p] = nil
	end

	self._smoke_clouds[p] = (smokeClouds:FindFirstChild(p.Name) and require(smokeClouds[p.Name]) or SmokeCloud).new(p)
	self._smoke_clouds[p].Model.Parent = workspace
	self:Update(0)
end

function class:_Init()
	CollectionService:GetInstanceRemovedSignal("SmokeCloud"):Connect(function(p)
		self:_ObjectRemoved(p)
	end)
	CollectionService:GetInstanceAddedSignal("SmokeCloud"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("SmokeCloud")) do
		task.spawn(self._ObjectAdded, self, v)
	end
end

return class._new()