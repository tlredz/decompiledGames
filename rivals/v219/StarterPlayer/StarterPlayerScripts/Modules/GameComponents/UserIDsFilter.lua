local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self:_Init()
	return self
end

function class:_Parse(value)
	local v = ""
	local result = {}

	for i = 1, #value do
		local v2 = string.sub(value, i, i)

		if v2 == "," or i == #value then
			if i == #value then
				v ..= v2
			end

			table.insert(result, (tonumber(v)))
			v = ""
		else
			v ..= v2
		end
	end

	return result
end

function class:_ObjectAdded(instance)
	if table.find(self:_Parse(instance:GetAttribute("UserIDs")), Players.LocalPlayer.UserId) then
		return
	end

	task.defer(instance.Destroy, instance)
end

function class:_Init()
	CollectionService:GetInstanceAddedSignal("UserIDsShow"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("UserIDsShow")) do
		task.defer(self._ObjectAdded, self, v)
	end
end

return class._new()