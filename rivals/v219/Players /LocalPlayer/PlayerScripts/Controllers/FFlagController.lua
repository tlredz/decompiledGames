local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local object = setmetatable({}, ReplicatedClass)
object.__index = object

function object._new()
	local self = setmetatable(ReplicatedClass.new(), object)
	self:_Init()
	return self
end

function object:GetFFlag(p)
	return self:Get(p)
end

function object:SetFFlag(p, p2)
	self:SetReplicate(p, p2)
end

function object:IsFreeWeaponsActive()
	for k in pairs(ItemLibrary.Statuses) do
		if self:GetFFlag("FreeToUse" .. k .. "Weapons") then
			return true
		end
	end
end

function object:_Fetch()
	local v = ReplicatedStorage.Remotes.Misc.RequestFFlags:InvokeServer()

	for k, v2 in pairs(v) do
		self:SetFFlag(k, v2)
	end
end

function object:_Init()
	ReplicatedStorage.Remotes.Misc.UpdateFFlag.OnClientEvent:Connect(function(...)
		self:SetFFlag(...)
	end)
	task.defer(self._Fetch, self)
end

return object._new()