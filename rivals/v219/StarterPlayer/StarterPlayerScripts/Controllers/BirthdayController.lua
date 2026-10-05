local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BirthdayLibrary = require(ReplicatedStorage.Modules.BirthdayLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self:_Init()
	return self
end

function class:_ObjectAdded(p)
	p.Triggered:Connect(function()
		if not PlayerDataController:Get("BirthdaysWitnessed")[BirthdayLibrary.CURRENT_BIRTHDAY_STRING] then
			ReplicatedStorage.Remotes.Data.TakeCake:FireServer()
		end
	end)
end

function class:_Init()
	CollectionService:GetInstanceAddedSignal("BirthdayCakePrompt"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("BirthdayCakePrompt")) do
		task.defer(self._ObjectAdded, self, v)
	end
end

return class._new()