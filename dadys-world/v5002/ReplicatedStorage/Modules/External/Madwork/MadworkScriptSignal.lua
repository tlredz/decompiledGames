local thread = nil

local function AcquireRunnerThreadAndCallEventHandler(callback, ...)
	local v = thread
	thread = nil
	callback(...)
	thread = v
end

local function RunEventHandlerInFreeThread(...)
	AcquireRunnerThreadAndCallEventHandler(...)

	while true do
		AcquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

local v = {
	Disconnect = function(state)
		local _listener = state._listener

		if _listener ~= nil then
			local _listener_table = state._listener_table
			local index = table.find(_listener_table, _listener)

			if index ~= nil then
				table.remove(_listener_table, index)
			end

			state._listener = nil
		end

		if state._disconnect_listener ~= nil then
			if not thread then
				thread = coroutine.create(RunEventHandlerInFreeThread)
			end

			task.spawn(thread, state._disconnect_listener, state._disconnect_param)
			state._disconnect_listener = nil
		end
	end
}
local MadworkScriptSignal = {
	NewArrayScriptConnection = function(listener_table, listener, disconnect_listener, disconnect_param)
		return {
			_listener = listener,
			_listener_table = listener_table,
			_disconnect_listener = disconnect_listener,
			_disconnect_param = disconnect_param,
			Disconnect = v.Disconnect
		}
	end
}
local class = {}
class.__index = class

function class:Disconnect()
	if self._is_connected == false then
		return
	end

	self._is_connected = false
	self._script_signal._listener_count -= 1

	if self._script_signal._head == self then
		self._script_signal._head = self._next
	else
		local _head = self._script_signal._head

		while _head ~= nil and _head._next ~= self do
			_head = _head._next
		end

		if _head ~= nil then
			_head._next = self._next
		end
	end

	if self._disconnect_listener ~= nil then
		if not thread then
			thread = coroutine.create(RunEventHandlerInFreeThread)
		end

		task.spawn(thread, self._disconnect_listener, self._disconnect_param)
		self._disconnect_listener = nil
	end
end

local class2 = {}
class2.__index = class2

function class2:Connect(listener, disconnect_listener, disconnect_param)
	local head = {
		_listener = listener,
		_script_signal = self,
		_disconnect_listener = disconnect_listener,
		_disconnect_param = disconnect_param,
		_next = self._head,
		_is_connected = true
	}
	setmetatable(head, class)
	self._head = head
	self._listener_count += 1
	return head
end

function class2:GetListenerCount()
	return self._listener_count
end

function class2:Fire(...)
	local _head = self._head

	while _head ~= nil do
		if _head._is_connected == true then
			if not thread then
				thread = coroutine.create(RunEventHandlerInFreeThread)
			end

			task.spawn(thread, _head._listener, ...)
		end

		_head = _head._next
	end
end

function class2:FireUntil(callback, ...)
	local _head = self._head

	while _head ~= nil do
		if _head._is_connected == true then
			_head._listener(...)

			if callback() ~= true then
				break
			end
		end

		_head = _head._next
	end
end

function MadworkScriptSignal.NewScriptSignal()
	return {
		_head = nil,
		_listener_count = 0,
		Connect = class2.Connect,
		GetListenerCount = class2.GetListenerCount,
		Fire = class2.Fire,
		FireUntil = class2.FireUntil
	}
end

return MadworkScriptSignal