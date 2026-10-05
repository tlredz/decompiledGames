require(script.Types)
local thread = nil

local function acquireRunnerThreadAndCallEventHandler(callback, ...)
	local v = thread
	thread = nil
	callback(...)
	thread = v
end

local function runEventHandlerInFreeThread()
	while true do
		acquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

local v = {
	Disconnect = function(self)
		self._signal._connections[self] = nil
		self.Connected = false
	end,
	Reconnect = function(p)
		p._signal._connections[p] = true
		p.Connected = true
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function connection_new(signal, fn)
	return (setmetatable({
		_signal = signal,
		_fn = fn,
		Connected = true
	}, {
		__index = v,
		__metatable = "LOCKED!"
	}))
end

local v2 = {
	Destroy = function(self)
		self:DisconnectAll()
	end,
	Connect = function(self, fn)
		local v3 = connection_new(self, fn) -- equivalent call inferred; original call site unknown
		self._connections[v3] = true
	end,
	Once = function(self, callback)
		local connection = nil
		connection = self:Connect(function(...)
			connection:Disconnect()
			callback(...)
		end)
	end,
	DisconnectAll = function(self)
		for connection in self._connections do
			connection:Disconnect()
		end
	end,
	Fire = function(p, ...)
		for k in p._connections do
			if not thread then
				thread = coroutine.create(runEventHandlerInFreeThread)
				coroutine.resume(thread)
			end

			task.spawn(thread, k._fn, ...)
		end
	end,
	Wait = function(self)
		local thread2 = coroutine.running()
		local connection = nil
		connection = self:Connect(function(...)
			connection:Disconnect()

			if coroutine.status(thread2) ~= "suspended" then
				return
			end

			task.spawn(thread2, ...)
		end)
		return coroutine.yield()
	end
}

local function signal_new()
	return (setmetatable({
		_connections = {}
	}, {
		__index = v2,
		__metatable = "LOCKED!"
	}))
end

return {
	new = signal_new
}