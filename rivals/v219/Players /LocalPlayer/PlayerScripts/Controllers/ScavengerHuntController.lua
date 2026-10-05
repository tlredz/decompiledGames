local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ScavengerHuntLibrary = require(ReplicatedStorage.Modules.ScavengerHuntLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local CollectEffect = require(Players.LocalPlayer.PlayerScripts.Modules.Functions.CollectEffect)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._collected = {}
	self:_Init()
	return self
end

function class:_UpdateObject(folder, p2)
	if self._collected[folder] then
		return
	end

	local scavengerHuntName = folder:GetAttribute("ScavengerHuntName")
	local v = ScavengerHuntLibrary.Info[scavengerHuntName]
	local v2 = PlayerDataController:Get("ScavengerHunts")[scavengerHuntName]

	if v2 and table.find(v2, folder:GetAttribute("ObjectName")) then
		self._collected[folder] = true
		task.defer(folder.Destroy, folder)

		if not p2 then
			CollectEffect(folder:GetPivot().Position, v.Color, "rbxassetid://129198689909472")
		end
	else
		local localTransparencyModifier = (CameraController:GetPublicState() == CameraController.CameraState.States.CustomFreecam or CONSTANTS.IS_PRIVATE_HUB_SERVER and not v.AllowedInPrivateServers) and 1 or 0

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("BasePart") or descendant:IsA("ParticleEmitter") then
				descendant.LocalTransparencyModifier = localTransparencyModifier
			end
		end
	end
end

function class:_UpdateAllObjects(p2)
	for _, v in pairs(CollectionService:GetTagged("ScavengerHunt")) do
		task.defer(self._UpdateObject, self, v, p2)
	end
end

function class:_Init()
	PlayerDataController:GetDataChangedSignal("ScavengerHunts"):Connect(function()
		self:_UpdateAllObjects()
	end)
	CollectionService:GetInstanceAddedSignal("ScavengerHunt"):Connect(function(p)
		self:_UpdateObject(p, true)
	end)
	CameraController.CustomFreecamStateChanged:Connect(function()
		self:_UpdateAllObjects()
	end)
	self:_UpdateAllObjects(true)
end

return class._new()