local NexusInstance = require(script.Parent:WaitForChild("Packages"):WaitForChild("NexusInstance"))
local class = {}
class.__index = class

function class:__new(wrappedInstance)
	local disabledReplicationProperties = {}
	self.WrappedInstance = wrappedInstance
	self.DisabledReplicationProperties = disabledReplicationProperties
	local metatable = getmetatable(self)
	local __index = metatable.__index

	function metatable.__index(p, p2)
		local v2 = __index(p, p2)

		if v2 ~= nil then
			return v2
		end

		if disabledReplicationProperties[p2] then
			return nil
		end

		local v3 = wrappedInstance[p2]

		if typeof(v3) == "function" then
			return function(_, ...)
				return v3(wrappedInstance, ...)
			end
		end

		return v3
	end

	self:OnAnyPropertyChanged(function(p, p2)
		if disabledReplicationProperties[p] then
			return
		end

		wrappedInstance[p] = p2
	end)

	if typeof(wrappedInstance) == "Instance" then
		wrappedInstance.Changed:Connect(function(p)
			if disabledReplicationProperties[p] then
				return
			end

			if __index(self, p) ~= nil then
				self[p] = wrappedInstance[p]
				return
			end

			self.Changed:Fire(p)
			local propertyChangedEvent = self.PropertyChangedEvents[p]

			if propertyChangedEvent then
				propertyChangedEvent:Fire()
			end
		end)
	end
end

function class.DisableChangeReplication(p, p2: string)
	p.DisabledReplicationProperties[p2] = true
end

function class.GetWrappedInstance(p)
	return p.WrappedInstance
end

function class:Destroy()
	if typeof(self.WrappedInstance) ~= "Instance" then
		return
	end

	self.WrappedInstance:Destroy()
end

return (NexusInstance.ToInstance(class))