local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self._stored_objects = {}
	self:_Init()
	return self
end

function object:_CheckParent(p2)
	task.defer(function()
		local v = ServerOsTime:Get()
		local _stored_object = self._stored_objects[p2]
		local v2

		if _stored_object.StartTime <= v then
			v2 = v < _stored_object.EndTime
		else
			v2 = false
		end

		if _stored_object.Inverse then
			v2 = not v2
		end

		local parent

		if v2 then
			parent = _stored_object.OriginalParent
		end

		p2.Parent = parent
	end)
end

function object:_DelayedCheck(p2, duration)
	if duration > 0 and duration < 1e999 then
		task.delay(duration, self._CheckParent, self, p2)
	end
end

function object:_ObjectAdded(instance)
	if self._stored_objects[instance] then
		return
	end

	local v = {
		OriginalParent = instance.Parent,
		StartTime = instance:GetAttribute("StartTime") or 0,
		EndTime = instance:GetAttribute("EndTime") or 1e999,
		Inverse = instance:GetAttribute("Inverse") or false
	}
	self._stored_objects[instance] = v
	self:_DelayedCheck(instance, v.StartTime - ServerOsTime:Get())
	self:_DelayedCheck(instance, v.EndTime - ServerOsTime:Get())
	self:_CheckParent(instance)
end

function object:_Init()
	CollectionService:GetInstanceAddedSignal("LobbyOnlyAppearWhen"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LobbyOnlyAppearWhen")) do
		task.spawn(self._ObjectAdded, self, v)
	end
end

return object._new()