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

function class.new(signal, fn)
	return (setmetatable({
		_connected = true,
		_signal = signal,
		_fn = fn,
		_next = false
	}, class))
end

function class:Disconnect()
	self._connected = false

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
	__newindex = function(_, p)
		error(("Attempt to set Connection::%s (not a valid member)"):format((tostring(p))), 2)
	end
})
local GoodSignal = {}
GoodSignal.__index = GoodSignal

function GoodSignal.new()
	return (setmetatable({
		_handlerListHead = false
	}, GoodSignal))
end

function GoodSignal:Connect(p2)
	local handlerListHead = class.new(self, p2)

	if not self._handlerListHead then
		self._handlerListHead = handlerListHead
		return handlerListHead
	end

	handlerListHead._next = self._handlerListHead
	self._handlerListHead = handlerListHead
	return handlerListHead
end

function GoodSignal:DisconnectAll()
	self._handlerListHead = false
end

function GoodSignal:Fire(...)
	local _handlerListHead = self._handlerListHead

	while _handlerListHead do
		if _handlerListHead._connected then
			if not thread then
				thread = coroutine.create(runEventHandlerInFreeThread)
				coroutine.resume(thread)
			end

			task.spawn(thread, _handlerListHead._fn, ...)
		end

		_handlerListHead = _handlerListHead._next
	end
end

function GoodSignal:Wait()
	local thread2 = coroutine.running()
	local connection = nil
	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread2, ...)
	end)
	return coroutine.yield()
end

function GoodSignal:Once(callback)
	local connection = nil
	connection = self:Connect(function(...)
		if connection._connected then
			connection:Disconnect()
		end

		callback(...)
	end)
	return connection
end

setmetatable(GoodSignal, {
	__index = function(_, p)
		error(("Attempt to get Signal::%s (not a valid member)"):format((tostring(p))), 2)
	end,
	__newindex = function(_, p)
		error(("Attempt to set Signal::%s (not a valid member)"):format((tostring(p))), 2)
	end
})
return GoodSignal