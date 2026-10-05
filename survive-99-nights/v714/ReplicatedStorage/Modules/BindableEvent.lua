local BindableEvent = {}
BindableEvent.__index = BindableEvent
local class = {}
class.__index = class

function class:Disconnect()
	if not self.Connected then
		return
	end

	self.Connected = false
	local _signal = self._signal

	if _signal._head == self then
		_signal._head = self._next
	else
		local _head = _signal._head

		while _head and _head._next ~= self do
			_head = _head._next
		end

		if _head then
			_head._next = self._next
		end
	end

	self._signal = nil
	self._fn = nil
end

class.Destroy = class.Disconnect

function BindableEvent.new()
	return (setmetatable({
		_head = nil,
		Destroyed = false
	}, BindableEvent))
end

function BindableEvent:Connect(fn)
	if self.Destroyed then
		return (setmetatable({
			Connected = false
		}, class))
	end

	local object = setmetatable({
		Connected = true,
		_signal = self,
		_fn = fn,
		_next = self._head
	}, class)
	self._head = object
	return object
end

function BindableEvent:Fire(...)
	if self.Destroyed then
		return
	end

	local _head = self._head

	while _head do
		local _next = _head._next

		if _head.Connected then
			task.spawn(_head._fn, ...)
		end

		_head = _next
	end
end

function BindableEvent:Wait(...)
	if self.Destroyed then
		return
	end

	local thread = coroutine.running()
	local connection = nil
	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread, ...)
	end)
	return coroutine.yield()
end

function BindableEvent:Destroy()
	self.Destroyed = true
	local _head = self._head

	while _head do
		_head.Connected = false
		_head = _head._next
	end

	self._head = nil
end

return BindableEvent