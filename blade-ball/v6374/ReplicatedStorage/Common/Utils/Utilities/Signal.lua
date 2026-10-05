local Signal = {}
Signal.__index = Signal
local class = {}
class.__index = class
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

function class.new(signal, fn)
	return (setmetatable({
		Connected = true,
		_signal = signal,
		_fn = fn
	}, class))
end

function class:Disconnect()
	if not self.Connected then
		return
	end

	local _signal = self._signal
	self.Connected = false

	if _signal._handlerListHead == self then
		_signal._handlerListHead = self._next
		return
	end

	local _handlerListHead = _signal._handlerListHead

	while _handlerListHead and _handlerListHead._next ~= self do
		_handlerListHead = _handlerListHead._next
	end

	if _handlerListHead then
		_handlerListHead._next = self._next
	end
end

class.Destroy = class.Disconnect

function Signal.new()
	return (setmetatable({
		_handlerListHead = nil,
		_proxyHandler = nil
	}, Signal))
end

function Signal:Wrap()
	local v = Signal.new()
	v._proxyHandler = self:Connect(function(...)
		v:Fire(...)
	end)
	return v
end

function Signal.Is(p)
	return type(p) == "table" and getmetatable(p) == Signal
end

function Signal:Connect(callback)
	local handlerListHead = class.new(self, callback)

	if not self._handlerListHead then
		self._handlerListHead = handlerListHead
		return handlerListHead
	end

	handlerListHead._next = self._handlerListHead
	self._handlerListHead = handlerListHead
	return handlerListHead
end

function Signal:Once(callback)
	local connection = nil
	local flag = false
	connection = self:Connect(function(...)
		if flag then
			return
		end

		flag = true
		connection:Disconnect()
		callback(...)
	end)
	return connection
end

function Signal:GetConnections()
	local _handlerListHead = self._handlerListHead
	local _handlerListHeads = {}

	while _handlerListHead do
		table.insert(_handlerListHeads, _handlerListHead)
		_handlerListHead = _handlerListHead._next
	end

	return _handlerListHeads
end

function Signal:DisconnectAll()
	local _handlerListHead = self._handlerListHead

	while _handlerListHead do
		_handlerListHead.Connected = false
		_handlerListHead = _handlerListHead._next
	end

	self._handlerListHead = nil
end

function Signal:Fire(...)
	local _handlerListHead = self._handlerListHead

	while _handlerListHead do
		if _handlerListHead.Connected then
			if not thread then
				thread = coroutine.create(runEventHandlerInFreeThread)
			end

			task.spawn(assert(thread), _handlerListHead._fn, ...)
		end

		_handlerListHead = _handlerListHead._next
	end
end

function Signal:FireDeferred(...)
	local _handlerListHead = self._handlerListHead

	while _handlerListHead do
		task.defer(_handlerListHead._fn, ...)
		_handlerListHead = _handlerListHead._next
	end
end

function Signal:Wait()
	local thread2 = coroutine.running()
	self:Once(function(...)
		task.spawn(thread2, ...)
	end)
	return coroutine.yield()
end

function Signal:Destroy()
	local _proxyHandler = self._proxyHandler
	self:DisconnectAll()

	if _proxyHandler then
		_proxyHandler:Disconnect()
	end
end

function Signal:On(p, callback)
	return self:Connect(function(...)
		if ... == p then
			callback(select(2, ...))
		end
	end)
end

return Signal