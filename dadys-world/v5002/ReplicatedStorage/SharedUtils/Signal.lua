local class = {}
class.__index = class

function class.new(signal, conn)
	return (setmetatable({
		_signal = signal,
		_conn = conn,
		Connected = true
	}, class))
end

function class:Disconnect()
	if self._conn then
		self._conn:Disconnect()
		self._conn = nil
	end

	if not self._signal then
		return
	end

	self.Connected = false
	local _connections = self._signal._connections
	local index = table.find(_connections, self)

	if index then
		local count = #_connections
		_connections[index] = _connections[count]
		_connections[count] = nil
	end

	self._signal = nil
end

function class:IsConnected()
	if self._conn then
		return self._conn.Connected
	end

	return false
end

class.Destroy = class.Disconnect
local Signal = {}
Signal.__index = Signal

function Signal.new(maid)
	local self = setmetatable({
		_bindable = Instance.new("BindableEvent"),
		_connections = {},
		_args = {},
		_threads = 0,
		_id = 0
	}, Signal)

	if maid then
		maid:GiveTask(self)
	end

	return self
end

function Signal.Proxy(p, p2)
	assert(typeof(p) == "RBXScriptSignal", "Argument #1 must be of type RBXScriptSignal")
	local v = Signal.new(p2)
	v:_setProxy(p)
	return v
end

function Signal.Is(p)
	return type(p) == "table" and getmetatable(p) == Signal
end

function Signal:_setProxy(object2)
	assert(typeof(object2) == "RBXScriptSignal", "Argument #1 must be of type RBXScriptSignal")
	self:_clearProxy()
	self._proxyHandle = object2:Connect(function(...)
		self:Fire(...)
	end)
end

function Signal:_clearProxy()
	if self._proxyHandle then
		self._proxyHandle:Disconnect()
		self._proxyHandle = nil
	end
end

function Signal:Fire(...)
	local v = #self._connections + self._threads

	if v == 0 then
		return
	end

	local _id = self._id
	self._id += 1
	self._args[_id] = {
		v,
		{
			n = select("#", ...),
			...
		}
	}
	self._threads = 0
	self._bindable:Fire(_id)
end

function Signal:Wait()
	self._threads += 1
	local v = self._bindable.Event:Wait()
	local _arg = self._args[v]
	_arg[1] -= 1

	if _arg[1] <= 0 then
		self._args[v] = nil
	end

	return table.unpack(_arg[2], 1, _arg[2].n)
end

function Signal:Connect(callback)
	local v = class.new(self, self._bindable.Event:Connect(function(p)
		local _arg = self._args[p]
		_arg[1] -= 1

		if _arg[1] <= 0 then
			self._args[p] = nil
		end

		callback(table.unpack(_arg[2], 1, _arg[2].n))
	end))
	table.insert(self._connections, v)
	return v
end

function Signal:DisconnectAll()
	for _, _connection in ipairs(self._connections) do
		if _connection._conn then
			_connection._conn:Disconnect()
		end
	end

	self._connections = {}
	self._args = {}
end

function Signal:Destroy()
	self:DisconnectAll()
	self:_clearProxy()
	self._bindable:Destroy()
end

return Signal