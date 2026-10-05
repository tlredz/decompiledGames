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

local v = {}
local v2 = {
	__index = v
}

function v:Disconnect()
	local _signal = self._signal
	_signal._connections[self] = nil
	_signal._connectionCount -= 1
	setmetatable(self, nil)
	table.clear(self)
	self.Connected = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function connection_new(state, fn)
	return (setmetatable({
		_signal = state,
		_fn = fn,
		Connected = true
	}, v2))
end

local v3 = {}
local v4 = {
	__index = v3
}

function v3:Destroy()
	self:DisconnectAll()
	setmetatable(self, nil)
	table.clear(self)
end

function v3:Connect(fn)
	local v5 = connection_new(self, fn) -- equivalent call inferred; original call site unknown
	self._connections[v5] = true
	self._connectionCount += 1
	return v5
end

function v3:Once(callback)
	local connection = nil
	connection = self:Connect(function(...)
		connection:Disconnect()
		callback(...)
	end)
	return connection
end

function v3:DisconnectAll()
	for connection in self._connections do
		connection:Disconnect()
	end
end

function v3:Fire(...)
	for k in self._connections do
		if not thread then
			thread = coroutine.create(runEventHandlerInFreeThread)
			coroutine.resume(thread)
		end

		task.spawn(thread, k._fn, ...)
	end
end

function v3:Wait()
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

local function signal_new()
	return (setmetatable({
		_connections = {},
		_connectionCount = 0
	}, v4))
end

return {
	new = signal_new
}