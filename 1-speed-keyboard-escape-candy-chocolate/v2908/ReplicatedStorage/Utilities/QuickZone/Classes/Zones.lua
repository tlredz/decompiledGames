require(script.Parent.Parent.Types)
local Zones = {}
Zones.__index = Zones

function Zones.new(data)
	local isDynamic

	if data and data.isDynamic ~= nil then
		isDynamic = data.isDynamic
	else
		isDynamic = false
	end

	local metadata

	if data then
		metadata = data.metadata
	end

	local autoSync

	if data and data.autoSync ~= nil then
		autoSync = data.autoSync
	else
		autoSync = false
	end

	return (setmetatable({
		dynamic = isDynamic,
		metadata = metadata,
		autoSync = autoSync,
		zones = {},
		observers = {},
		onDestroyObserverCleanups = {},
		onDestroyZoneCleanups = {}
	}, Zones))
end

function Zones:attach(object2)
	if self.observers[object2] then
		return self
	end

	self.observers[object2] = true
	self.onDestroyObserverCleanups[object2] = object2:onDestroy(function()
		self:detach(object2)
	end)

	for k, _ in self.zones do
		object2:attach(k)
	end

	return self
end

function Zones:detach(object)
	if not self.observers[object] then
		return self
	end

	self.observers[object] = nil
	local onDestroyObserverCleanup = self.onDestroyObserverCleanups[object]

	if onDestroyObserverCleanup then
		onDestroyObserverCleanup()
		self.onDestroyObserverCleanups[object] = nil
	end

	for k, _ in self.zones do
		object:detach(k)
	end

	return self
end

function Zones:sync()
	if not self.dynamic then
		return self
	end

	for k, _ in self.zones do
		k:sync()
	end

	return self
end

function Zones.getZones(p)
	local result = {}

	for k, _ in p.zones do
		table.insert(result, k)
	end

	return result
end

function Zones:isDynamic()
	return self.dynamic
end

function Zones:isPointInside(vector: Vector3)
	for k, _ in self.zones do
		if k:isPointInside(vector) then
			return true
		end
	end

	return false
end

function Zones:setAutoSync(autoSync: boolean)
	if self.autoSync == autoSync then
		return self
	end

	self.autoSync = autoSync

	for k, _ in self.zones do
		k:setAutoSync(autoSync)
	end

	return self
end

function Zones:setDynamic(dynamic: boolean)
	if self.dynamic == dynamic then
		return self
	end

	self.dynamic = dynamic

	for k, _ in self.zones do
		k:setDynamic(dynamic)
	end

	return self
end

function Zones:setMetadata(metadata)
	self.metadata = metadata

	for k, _ in self.zones do
		k:setMetadata(metadata)
	end

	return self
end

function Zones:getMetadata()
	return self.metadata
end

function Zones.contains(p, p2)
	return p.zones[p2] == true
end

function Zones.iterZones(p)
	local v = nil
	return function()
		v = next(p.zones, v)
		return v
	end
end

function Zones.getReferences(p)
	local references = {}

	for k, _ in p.zones do
		local reference = k:getReference()

		if reference then
			table.insert(references, reference)
		end
	end

	return references
end

function Zones.iterReferences(p)
	local v = nil
	return function()
		while true do
			v = next(p.zones, v)

			if not v then
				break
			end

			local reference = v:getReference()

			if reference then
				return reference, v
			end
		end

		return nil, nil
	end
end

function Zones:onDestroy(callback)
	if not self.onDestroyCallbacks then
		self.onDestroyCallbacks = {}
	end

	table.insert(self.onDestroyCallbacks, callback)
	return function()
		local index = table.find(self.onDestroyCallbacks, callback)

		if index then
			table.remove(self.onDestroyCallbacks, index)
		end
	end
end

function Zones:destroy()
	if self.onDestroyCallbacks then
		for _, callback in self.onDestroyCallbacks do
			task.spawn(callback)
		end

		table.clear(self.onDestroyCallbacks)
	end

	for _, onDestroyObserverCleanup in self.onDestroyObserverCleanups do
		onDestroyObserverCleanup()
	end

	for k, onDestroyZoneCleanup in self.onDestroyZoneCleanups do
		onDestroyZoneCleanup()
		k:destroy()
	end

	table.clear(self.zones)
	table.clear(self.observers)
	table.clear(self.onDestroyObserverCleanups)
	table.clear(self.onDestroyZoneCleanups)
	setmetatable(self, nil)
end

function Zones:add(object2)
	if self.zones[object2] then
		return
	end

	if self.metadata ~= nil and object2:getMetadata() == nil then
		object2:setMetadata(self.metadata)
	end

	if self.dynamic and not object2:isDynamic() then
		object2:setDynamic(true)
	end

	if self.autoSync then
		object2:setAutoSync(true)
	end

	self.zones[object2] = true
	self.onDestroyZoneCleanups[object2] = object2:onDestroy(function()
		self:remove(object2)
	end)

	for k, _ in self.observers do
		k:attach(object2)
	end
end

function Zones.remove(data, p)
	if not data.zones[p] then
		return
	end

	data.zones[p] = nil
	local onDestroyZoneCleanup = data.onDestroyZoneCleanups[p]

	if onDestroyZoneCleanup then
		onDestroyZoneCleanup()
		data.onDestroyZoneCleanups[p] = nil
	end

	for k, _ in data.observers do
		k:detach(p)
	end
end

return Zones