local thread = nil
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("t"))

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

local function getOrCreateReusableRunnerThread(...)
	if not thread then
		thread = coroutine.create(runEventHandlerInFreeThread)
	end

	task.spawn(thread, ...)
end

local class = {}
class.__index = class

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
local class2 = {}
class2.__index = class2

function class2:_deployStickyBehavior(callback)
	local v = rawget(self, "_stickyBehavior")

	if not v then
		return
	end

	getOrCreateReusableRunnerThread(v, callback)
end

function class2.new(stickyBehavior)
	t.strict(t.optional(t.callback))(stickyBehavior)
	return (setmetatable({
		_handlerListHead = false,
		_proxyHandler = nil,
		_yieldedThreads = nil,
		_stickyBehavior = stickyBehavior
	}, class2))
end

function class2:Wrap()
	assert(
		typeof(self) == "RBXScriptSignal",
		"Argument #1 to Signal.Wrap must be a RBXScriptSignal; got " .. typeof(self)
	)
	local v = class2.new()
	v._proxyHandler = self:Connect(function(...)
		v:Fire(...)
	end)
	return v
end

function class2.Is(p)
	return type(p) == "table" and getmetatable(p) == class2
end

function class2:Connect(fn)
	local object2 = setmetatable({
		Connected = true,
		_signal = self,
		_fn = fn,
		_next = false
	}, class)

	if self._handlerListHead then
		object2._next = self._handlerListHead
	end

	self._handlerListHead = object2
	self:_deployStickyBehavior(fn)
	return object2
end

function class2:ConnectOnce(p)
	return self:Once(p)
end

function class2:Once(callback)
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

function class2:GetConnections()
	local _handlerListHead = self._handlerListHead
	local _handlerListHeads = {}

	while _handlerListHead do
		table.insert(_handlerListHeads, _handlerListHead)
		_handlerListHead = _handlerListHead._next
	end

	return _handlerListHeads
end

function class2:DisconnectAll()
	local _handlerListHead = self._handlerListHead

	while _handlerListHead do
		_handlerListHead.Connected = false
		_handlerListHead = _handlerListHead._next
	end

	self._handlerListHead = false
	local v = rawget(self, "_yieldedThreads")

	if v then
		for k in v do
			if coroutine.status(k) ~= "suspended" then
				continue
			end

			warn(debug.traceback(k, "signal disconnected; yielded thread cancelled", 2))
			task.cancel(k)
		end

		table.clear(self._yieldedThreads)
	end
end

function class2:Fire(...)
	local _handlerListHead = self._handlerListHead

	while _handlerListHead do
		if _handlerListHead.Connected then
			getOrCreateReusableRunnerThread(_handlerListHead._fn, ...)
		end

		_handlerListHead = _handlerListHead._next
	end
end

function class2:FireDeferred(...)
	local _handlerListHead = self._handlerListHead

	while _handlerListHead do
		local v = _handlerListHead
		task.defer(function(...)
			if v.Connected then
				v._fn(...)
			end
		end, ...)
		_handlerListHead = _handlerListHead._next
	end
end

function class2:Wait()
	local v = rawget(self, "_yieldedThreads")

	if not v then
		v = {}
		rawset(self, "_yieldedThreads", v)
	end

	local thread2 = coroutine.running()
	v[thread2] = true
	self:Once(function(...)
		v[thread2] = nil

		if coroutine.status(thread2) == "suspended" then
			task.spawn(thread2, ...)
		end
	end)
	return coroutine.yield()
end

function class2:Destroy(flag: boolean?)
	self:DisconnectAll()
	local connection = rawget(self, "_proxyHandler")

	if connection then
		connection:Disconnect()
	end

	if not flag then
		return
	end

	setmetatable(self, nil)
	table.clear(self)
end

setmetatable(class2, {
	__index = function(_, p)
		error(("Attempt to get Signal::%s (not a valid member)"):format((tostring(p))), 2)
	end,
	__newindex = function(_, p, _)
		error(("Attempt to set Signal::%s (not a valid member)"):format((tostring(p))), 2)
	end
})
return table.freeze({
	new = class2.new,
	Wrap = class2.Wrap,
	Is = class2.Is
})