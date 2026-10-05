local thread = nil

local function acquireRunnerThreadAndCallEventHandler(callback, ...)
	local v = thread
	thread = nil
	callback(...)
	thread = v
end

local function runEventHandlerInFreeThread(...)
	acquireRunnerThreadAndCallEventHandler(...)

	while true do
		acquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

local class = {}
class.__index = class

function class.new(signal, fn)
	return (setmetatable({
		_connected = true,
		_signal = signal,
		_fn = fn,
		_next = false
	}, class))
end

function class:Disconnect()
	assert(self._connected, "Can't disconnect a connection twice.", 2)
	self._connected = false
	local _signal = self._signal

	if _signal._handlerListHead == self then
		_signal._handlerListHead = self._next
	else
		local _handlerListHead = _signal._handlerListHead

		while _handlerListHead and _handlerListHead._next ~= self do
			_handlerListHead = _handlerListHead._next
		end

		if _handlerListHead then
			_handlerListHead._next = self._next
		end
	end

	if _signal.connectionsChanged then
		_signal.totalConnections -= 1
		_signal.connectionsChanged:Fire(-1)
	end
end

setmetatable(class, {
	__index = function(_, p)
		error(("Attempt to get Connection::%s (not a valid member)"):format((tostring(p))), 2)
	end,
	__newindex = function(_, p, _)
		error(("Attempt to set Connection::%s (not a valid member)"):format((tostring(p))), 2)
	end
})
local Signal = {}
Signal.__index = Signal

function Signal.new(p)
	local self = setmetatable({
		_handlerListHead = false
	}, Signal)

	if p then
		self.totalConnections = 0
		self.connectionsChanged = Signal.new()
	end

	return self
end

function Signal:Connect(p)
	local handlerListHead = class.new(self, p)

	if self._handlerListHead then
		handlerListHead._next = self._handlerListHead
	end

	self._handlerListHead = handlerListHead

	if self.connectionsChanged then
		self.totalConnections += 1
		self.connectionsChanged:Fire(1)
	end

	return handlerListHead
end

function Signal:DisconnectAll()
	self._handlerListHead = false

	if self.connectionsChanged then
		self.connectionsChanged:Fire(-self.totalConnections)
		self.connectionsChanged:Destroy()
		self.connectionsChanged = nil
		self.totalConnections = 0
	end
end

Signal.Destroy = Signal.DisconnectAll
Signal.destroy = Signal.DisconnectAll

function Signal:Fire(...)
	local _handlerListHead = self._handlerListHead

	while _handlerListHead do
		if _handlerListHead._connected then
			if not thread then
				thread = coroutine.create(runEventHandlerInFreeThread)
			end

			task.spawn(thread, _handlerListHead._fn, ...)
		end

		_handlerListHead = _handlerListHead._next
	end
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

return Signal