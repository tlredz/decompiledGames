local Deferred = {}
Deferred.__index = Deferred
local class = {}
class.__index = class

function Deferred.new()
	return (setmetatable({
		_active = true,
		_head = nil
	}, Deferred))
end

function Deferred.Is(p)
	return typeof(p) == "table" and getmetatable(p) == Deferred
end

function Deferred:IsActive()
	return self._active == true
end

function Deferred:Connect(handler)
	assert(typeof(handler) == "function", "Must be function")

	if self._active ~= true then
		return (setmetatable({
			Connected = false,
			_node = nil
		}, class))
	end

	local _head = self._head
	local v = {
		_signal = self,
		_connection = nil,
		_handler = handler,
		_next = _head,
		_prev = nil
	}

	if _head ~= nil then
		_head._prev = v
	end

	self._head = v
	local object = setmetatable({
		Connected = true,
		_node = v
	}, class)
	v._connection = object
	return object
end

function Deferred:Once(callback)
	assert(typeof(callback) == "function", "Must be function")
	local connection = nil
	connection = self:Connect(function(...)
		if connection == nil then
			return
		end

		connection:Disconnect()
		connection = nil
		callback(...)
	end)
	return connection
end

Deferred.ConnectOnce = Deferred.Once

function Deferred:Wait()
	local thread = coroutine.running()
	local connection = nil
	connection = self:Connect(function(...)
		if connection == nil then
			return
		end

		connection:Disconnect()
		connection = nil
		task.spawn(thread, ...)
	end)
	return coroutine.yield()
end

function Deferred:Fire(...)
	local _head = self._head

	while _head ~= nil do
		task.defer(_head._handler, ...)
		_head = _head._next
	end
end

function Deferred:DisconnectAll()
	local _head = self._head

	while _head ~= nil do
		local _connection = _head._connection

		if _connection ~= nil then
			_connection.Connected = false
			_connection._node = nil
			_head._connection = nil
		end

		_head = _head._next
	end

	self._head = nil
end

function Deferred:Destroy()
	if self._active ~= true then
		return
	end

	self:DisconnectAll()
	self._active = false
end

function class:Disconnect()
	if self.Connected ~= true then
		return
	end

	self.Connected = false
	local _node = self._node
	local _prev = _node._prev
	local _next = _node._next

	if _next ~= nil then
		_next._prev = _prev
	end

	if _prev == nil then
		_node._signal._head = _next
	else
		_prev._next = _next
	end

	_node._connection = nil
	self._node = nil
end

class.Destroy = class.Disconnect
return Deferred