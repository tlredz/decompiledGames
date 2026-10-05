local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Utility = require(ReplicatedStorage.Modules.Utility)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._objects = {}
	self:_Init()
	return self
end

function class:Update(_)
	for k, _object in pairs(self._objects) do
		if not Utility:IsUIElementVisible(k) then
			continue
		end

		local v

		if _object.IsDoubleFlash then
			v = tick() * 0.25 * 8 % 6

			if not (v < 1) then
				v = not (v < 2) and 0 or v - 1
			end
		else
			v = tick() * 0.25 % 1
		end

		local v2 = (math.sin(6.283185307179586 * (v - 0.5)) + 6.283185307179586 * (v - 0.5)) / 6.283185307179586 + 0.5
		_object.Gradient.Offset = Vector2.new((v2 - 0.5) * 2, 0)
	end
end

function class:_ObjectRemoved(p2)
	if not self._objects[p2] then
		return
	end

	self._objects[p2] = nil
end

function class:_ObjectAdded(instance)
	self:_ObjectRemoved(instance)
	self._objects[instance] = {
		Gradient = instance:WaitForChild("UIGradient"),
		IsDoubleFlash = instance:GetAttribute("IsDoubleFlash")
	}
end

function class:_Init()
	CollectionService:GetInstanceRemovedSignal("UIShinyText"):Connect(function(p)
		self:_ObjectRemoved(p)
	end)
	CollectionService:GetInstanceAddedSignal("UIShinyText"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("UIShinyText")) do
		task.spawn(self._ObjectAdded, self, v)
	end
end

return class._new()