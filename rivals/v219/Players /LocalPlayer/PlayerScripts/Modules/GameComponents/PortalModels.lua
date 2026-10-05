local CollectionService = game:GetService("CollectionService")
local PortalModel = require(script:WaitForChild("PortalModel"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._portal_models = {}
	self:_Init()
	return self
end

function class:Update(p2)
	for _, _portal_model in pairs(self._portal_models) do
		_portal_model:Update(p2)
	end
end

function class:_ObjectRemoved(p2)
	if self._portal_models[p2] then
		self._portal_models[p2]:Destroy()
		self._portal_models[p2] = nil
	end
end

function class:_ObjectAdded(p)
	self:_ObjectRemoved(p)
	local v = PortalModel.new(p)
	self._portal_models[p] = v
end

function class:_Init()
	CollectionService:GetInstanceRemovedSignal("PortalModel"):Connect(function(p)
		self:_ObjectRemoved(p)
	end)
	CollectionService:GetInstanceAddedSignal("PortalModel"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("PortalModel")) do
		task.spawn(self._ObjectAdded, self, v)
	end
end

return class._new()