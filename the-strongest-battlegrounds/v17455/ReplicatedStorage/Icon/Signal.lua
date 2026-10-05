local Signal = {}
Signal.__index = Signal
local class = {}
class.__index = class
local thread = nil

local function RunHandlerInFreeThread(callback, ...)
	local v = thread
	thread = nil
	callback(...)
	thread = v
end

local function CreateFreeThread()
	thread = coroutine.running()

	while true do
		RunHandlerInFreeThread(coroutine.yield())
	end
end

function Signal.new()
	return (setmetatable({
		_active = true,
		_head = nil
	}, Signal))
end

function Signal.Is(p)
	return typeof(p) == "table" and getmetatable(p) == Signal
end

function Signal:IsActive()
	return self._active == true
end

function Signal:Connect(handler)
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

function Signal:ConnectOnce(callback)
	assert(typeof(callback) == "function", "Must be function")
	local connection = nil
	connection = self:Connect(function(...)
		connection:Disconnect()
		callback(...)
	end)
end

function Signal:Wait()
	local thread2 = coroutine.running()
	local connection = nil
	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread2, ...)
	end)
	return coroutine.yield()
end

function Signal:Fire(...)
	local _head = self._head

	while _head ~= nil do
		if _head._connection ~= nil then
			if thread == nil then
				task.spawn(CreateFreeThread)
			end

			task.spawn(thread, _head._handler, ...)
		end

		_head = _head._next
	end
end

function Signal:DisconnectAll()
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

function Signal:Destroy()
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

class.destroy = class.Disconnect
class.Destroy = class.Disconnect
class.disconnect = class.Disconnect
Signal.destroy = Signal.Destroy
Signal.Disconnect = Signal.Destroy
Signal.disconnect = Signal.Destroy
Signal.connect = Signal.Connect
Signal.wait = Signal.Wait
Signal.fire = Signal.Fire
return Signal