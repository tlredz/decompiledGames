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
		Connected = true,
		_signal = signal,
		_fn = fn,
		_next = false
	}, class))
end

function class:Disconnect()
	if not self.Connected then
		return
	end

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

class.Destroy = class.Disconnect
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

function Signal.new()
	return (setmetatable({
		_handlerListHead = false,
		_proxyHandler = nil
	}, Signal))
end

function Signal:Wrap()
	assert(
		typeof(self) == "RBXScriptSignal",
		"Argument #1 to Signal.Wrap must be a RBXScriptSignal; got " .. typeof(self)
	)
	local v = Signal.new()
	v._proxyHandler = self:Connect(function(...)
		v:Fire(...)
	end)
	return v
end

function Signal.Is(p)
	return type(p) == "table" and getmetatable(p) == Signal
end

function Signal:Connect(p2)
	local handlerListHead = class.new(self, p2)

	if not self._handlerListHead then
		self._handlerListHead = handlerListHead
		return handlerListHead
	end

	handlerListHead._next = self._handlerListHead
	self._handlerListHead = handlerListHead
	return handlerListHead
end

function Signal:ConnectOnce(callback)
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

	self._handlerListHead = false
end

function Signal:Fire(...)
	local _handlerListHead = self._handlerListHead

	while _handlerListHead do
		if _handlerListHead.Connected then
			if not thread then
				thread = coroutine.create(runEventHandlerInFreeThread)
			end

			task.spawn(thread, _handlerListHead._fn, ...)
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
	local connection = nil
	local flag = false
	connection = self:Connect(function(...)
		if flag then
			return
		end

		flag = true
		connection:Disconnect()
		task.spawn(thread2, ...)
	end)
	return coroutine.yield()
end

function Signal:Destroy()
	self:DisconnectAll()
	local connection = rawget(self, "_proxyHandler")

	if connection then
		connection:Disconnect()
	end
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