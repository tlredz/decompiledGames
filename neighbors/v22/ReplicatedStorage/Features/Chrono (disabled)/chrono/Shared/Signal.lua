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

local class = {}
class.__index = class

function class.new(signal, fn, p3)
	return (setmetatable({
		_type_ = "Connection",
		Connected = true,
		_signal = signal,
		_fn = fn,
		_next = false,
		_defer = p3 or false,
		_binCleanup = class.Disconnect
	}, class))
end

function class:Disconnect()
	self.Connected = false

	if self._signal._handlerListHead == self then
		self._signal._handlerListHead = self._next
		return
	end

	local _handlerListHead = self._signal._handlerListHead

	while _handlerListHead and _handlerListHead._next ~= self do
		_handlerListHead = _handlerListHead._next
	end

	if _handlerListHead then
		_handlerListHead._next = self._next
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
local class2 = {}
class2.__index = class2

function class2.new()
	return (setmetatable({
		_type_ = "Event",
		_handlerListHead = false
	}, class2))
end

function class2:Connect(p2, p3)
	local handlerListHead = class.new(self, p2, p3)

	if not self._handlerListHead then
		self._handlerListHead = handlerListHead
		return handlerListHead
	end

	handlerListHead._next = self._handlerListHead
	self._handlerListHead = handlerListHead
	return handlerListHead
end

function class2:Wait(p)
	local thread2 = coroutine.running()
	local connection = nil
	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread2, ...)
	end, p)
	return coroutine.yield()
end

function class2:Once(callback, p)
	local connection = nil
	connection = self:Connect(function(...)
		if connection.Connected then
			connection:Disconnect()
		end

		callback(...)
	end, p)
	return connection
end

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return (setmetatable({
		_type_ = "Signal",
		Event = class2.new(),
		_binCleanup = Signal.DisconnectAll
	}, Signal))
end

function Signal.DisconnectAll(p)
	p.Event._handlerListHead = false
end

function Signal.Fire(p, ...)
	local _handlerListHead = p.Event._handlerListHead
	debug.profilebegin("Signal.Fire")

	while _handlerListHead do
		if _handlerListHead.Connected then
			if _handlerListHead._defer then
				task.defer(_handlerListHead._fn, ...)
			else
				if not thread then
					thread = coroutine.create(runEventHandlerInFreeThread)
					coroutine.resume(thread)
				end

				task.spawn(thread, _handlerListHead._fn, ...)
			end
		end

		_handlerListHead = _handlerListHead._next
	end

	debug.profileend()
end

setmetatable(Signal, {
	__index = function(_, p)
		error(("Attempt to get Signal::%s (not a valid member)"):format((tostring(p))), 2)
	end,
	__newindex = function(_, p, _)
		error(("Attempt to set Signal::%s (not a valid member)"):format((tostring(p))), 2)
	end
})
return Signal