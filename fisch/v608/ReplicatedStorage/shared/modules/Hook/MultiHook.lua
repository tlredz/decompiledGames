require("../Hook")
local class = {}
class.__index = class

function class.new(priority: number?, callback, hook, subConnections)
	return (setmetatable({
		_hook = hook,
		_subConnections = subConnections,
		_priority = priority,
		_callback = callback,
		Connected = true
	}, class))
end

function class:Disconnect()
	for _, _subConnection in self._subConnections do
		_subConnection:Disconnect()
	end

	table.clone(self._subConnections)
	local index = table.find(self._hook._connections, self)

	if index then
		table.remove(self._hook._connections, index)
	end

	self.Connected = false
	self._hook = nil
	self._callback = nil
	self._priority = nil
end

class.Destroy = class.Disconnect
local MultiHook = {}
MultiHook.__index = MultiHook

function MultiHook.new(hooks)
	assert(typeof(hooks) == "table", "MultiHook.new requires a table of Hook objects")
	return (setmetatable({
		_hooks = hooks,
		_connections = {},
		_destroyed = false
	}, MultiHook))
end

function MultiHook:BindAtPriority(value, callback)
	assert(typeof(value) == "number" or value == nil, "MultiHook:BindAtPriority(): priority must be a number!")
	assert(typeof(callback) == "function", "MultiHook:BindAtPriority(): callback must be a function!")
	assert(not self._destroyed, "Requested MultiHook has been destroyed")
	local v = table.create(#self._hooks)

	for i, _hook in ipairs(self._hooks) do
		v[i] = _hook:BindAtPriority(value, callback)
	end

	local v2 = class.new(value, callback, self, v)
	table.insert(self._connections, v2)
	return v2
end

function MultiHook:Bind(p)
	return self:BindAtPriority(nil, p)
end

function MultiHook:AddHook(object)
	assert(not table.isfrozen(self._hooks), "This MultiHook cannot have more Hooks added")
	table.insert(self._hooks, object)

	for _, _connection in ipairs(self._connections) do
		if _connection.Connected then
			table.insert(
				_connection._subConnections,
				object:BindAtPriority(_connection._priority, _connection._callback)
			)
		end
	end
end

function MultiHook:DisconnectAll()
	for _, _connection in ipairs(self._connections) do
		_connection:Disconnect()
	end

	table.clear(self._connections)
end

function MultiHook:Destroy()
	self:DisconnectAll()
	self._hooks = nil
	self._destroyed = true
end

return MultiHook