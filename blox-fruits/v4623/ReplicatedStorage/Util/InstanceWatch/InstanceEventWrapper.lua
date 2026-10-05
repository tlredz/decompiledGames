local InstanceEventWrapper = {
	objects = {}
}

local function noyieldspawn(callback, ...)
	local _ = coroutine.status(task.spawn(callback, ...)) == "dead"
end

function InstanceEventWrapper:CheckExisting(p2, p3)
	for _, child in pairs(self.instance:GetChildren()) do
		if child.Name == p2 then
			noyieldspawn(p3, child)
		end
	end
end

function InstanceEventWrapper:ChildAdded(p, p2)
	self.__ChildAdded[p] = p2
	self:CheckExisting(p, p2)
end

function InstanceEventWrapper:ChildRemoved(p2, p3)
	self.__ChildRemoved[p2] = p3
end

local v = {
	__index = InstanceEventWrapper
}

function InstanceEventWrapper.Get(instance)
	local object = InstanceEventWrapper.objects[instance]

	if object then
		return object
	end

	local childRemoved = {}
	local childAdded = {}
	local v4 = {
		__ChildAdded = childAdded,
		__ChildRemoved = childRemoved,
		instance = instance
	}
	instance.ChildAdded:Connect(function(child)
		local v5 = childAdded[child.Name]

		if v5 then
			noyieldspawn(v5, child)
		end
	end)
	instance.ChildRemoved:Connect(function(child)
		local v5 = childRemoved[child.Name]

		if v5 then
			noyieldspawn(v5, child)
		end
	end)
	setmetatable(v4, v)
	return v4
end

return InstanceEventWrapper