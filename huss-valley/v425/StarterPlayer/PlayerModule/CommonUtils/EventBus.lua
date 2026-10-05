local EventBus = {}
EventBus.__index = EventBus

function EventBus.new()
	local self = setmetatable({}, EventBus)
	self._events = {}
	return self
end

function EventBus:_getOrCreate(name: string)
	if not self._events[name] then
		local bindableEvent = Instance.new("BindableEvent")
		bindableEvent.Name = name
		self._events[name] = bindableEvent
	end

	return self._events[name]
end

function EventBus:publish(p: string, ...)
	self:_getOrCreate(p):Fire(...)
end

function EventBus:subscribe(p: string)
	return self:_getOrCreate(p).Event
end

return EventBus