local LogService = game:GetService("LogService")
local class = {}
class.__index = class

function class.new(node)
	return (setmetatable({
		_node = node,
		Connected = true
	}, class))
end

function class:Disconnect()
	if not self._node then
		return
	end

	local _node = self._node
	local next = _node.next

	if next then
		next.prev = _node.prev
		_node.next = nil
	end

	local prev = _node.prev

	if prev then
		prev.next = next
		_node.prev = nil
	end

	_node.callback = nil
	self._node = nil
	self.Connected = false
end

class.Destroy = class.Disconnect
local Hook = {}
Hook.__index = Hook

function Hook.new(p)
	return (setmetatable({
		init = p or function(...)
			return ...
		end,
		next = nil,
		prev = nil,
		_destroyed = false,
		_cancelCondition = nil
	}, Hook))
end

Hook.direct = Hook.new

function Hook.BindAtPriority(next, value, callback)
	assert(typeof(value) == "number" or value == nil, "Hook:BindAtPriority(): priority must be a number!")
	assert(typeof(callback) == "function", "Hook:BindAtPriority(): callback must be a function!")
	assert(not next._destroyed, "Requested Hook has been destroyed")
	local v = {
		priority = value or 0,
		callback = callback,
		next = nil,
		prev = nil,
		_trace = debug.traceback("Binding traceback:", value == nil and 3 or 2)
	}
	local v2 = value or 0

	while next.next and next.next.priority < v2 do
		next = next.next
	end

	v.next = next.next

	if next.next then
		next.next.prev = v
	end

	next.next = v
	v.prev = next
	local connection = class.new(v)
	v.connection = connection
	return connection
end

function Hook:Bind(p)
	return self:BindAtPriority(nil, p)
end

function Hook:BindOnceAtPriority(p, callback)
	local connection = nil
	connection = self:BindAtPriority(p, function(...)
		if not connection then
			error("this shouldnt happen.....")
		end

		connection:Disconnect()
		connection = nil
		return callback(...)
	end)
end

function Hook:BindOnce(_, p)
	return self:BindOnceAtPriority(nil, p)
end

function Hook:InvokeAsync(...)
	assert(not self._destroyed, "Requested Hook has been destroyed")
	local next = self.next
	local v = { self.init(...) }

	while next do
		if self._cancelCondition ~= nil and self._cancelCondition(table.unpack(v)) then
			return table.unpack(v)
		end

		local next2 = next.next
		local v2 = { next.callback(table.unpack(v)) }

		if #v2 == #v then
			v = v2
		end

		next = next2
	end

	return table.unpack(v)
end

function Hook:InvokePcallAsync(...)
	assert(not self._destroyed, "Requested Hook has been destroyed")
	local next = self.next
	local v = { self.init(...) }

	while next do
		if self._cancelCondition ~= nil and self._cancelCondition(table.unpack(v)) then
			return table.unpack(v)
		end

		local next2 = next.next
		local success, result = pcall(function()
			return { next.callback(table.unpack(v)) }
		end)

		if success and #result == #v then
			v = result
		elseif not success then
			LogService:Warn(`Invocation handler failed: {result}`, {
				invokeTraceback = debug.traceback("Invocation traceback:", 2),
				bindTrace = next._trace
			})
		end

		next = next2
	end

	return table.unpack(v)
end

function Hook:SetCancelCondition(cancelCondition)
	assert(
		typeof(cancelCondition) == "function" or cancelCondition == nil,
		"Cancel condition callback must be a function or nil"
	)
	self._cancelCondition = cancelCondition
	return self
end

function Hook.DisconnectAll(p)
	while p do
		local next = p.next
		p.next = nil
		p.prev = nil
		p.callback = nil
		p = next
	end
end

function Hook:Destroy()
	self:DisconnectAll()
	self._destroyed = true
end

return Hook