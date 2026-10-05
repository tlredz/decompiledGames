local shared = require(script.Parent.Parent.Parent.Parent:WaitForChild("shared"))
local console = shared.console
local _ = {
	Disabled = "Disabled",
	Suspended = "Suspended",
	Enabled = "Enabled"
}
local SingleEventManager = {}
SingleEventManager.__index = SingleEventManager

function SingleEventManager.new(instance)
	return (setmetatable({
		_suspendedEventQueue = {},
		_connections = {},
		_listeners = {},
		_status = "Disabled",
		_isResuming = false,
		_instance = instance
	}, SingleEventManager))
end

function SingleEventManager:connectEvent(p, p2)
	self:_connect(p, self._instance[p], p2)
end

function SingleEventManager:connectPropertyChange(p, p2)
	local success, propertyChangedSignal = pcall(self._instance.GetPropertyChangedSignal, self._instance, p)

	if not success then
		error(string.format("Cannot get changed signal on property %q: %s", tostring(p), propertyChangedSignal), 0)
	end

	self:_connect("Change." .. p, propertyChangedSignal, p2)
end

function SingleEventManager:_connect(p, object, p2)
	if p2 == nil then
		if self._connections[p] ~= nil then
			self._connections[p]:Disconnect()
			self._connections[p] = nil
		end

		self._listeners[p] = nil
	else
		if self._connections[p] == nil then
			self._connections[p] = object:Connect(function(...)
				if self._status == "Enabled" then
					self._listeners[p](self._instance, ...)
				elseif self._status == "Suspended" then
					local v = select("#", ...)
					table.insert(self._suspendedEventQueue, { p, v, ... })
				end
			end)
		end

		self._listeners[p] = p2
	end
end

function SingleEventManager:suspend()
	self._status = "Suspended"
end

function SingleEventManager:resume()
	if self._isResuming then
		return
	end

	self._isResuming = true

	for _, list in self._suspendedEventQueue do
		local _listener = self._listeners[list[1]]
		local v = list[2]

		if _listener == nil then
			continue
		end

		local thread = coroutine.create(_listener)
		local v2, v3 = coroutine.resume(thread, self._instance, unpack(list, 3, 2 + v))

		if not v2 then
			console.warn("%s", v3)
		end
	end

	self._isResuming = false
	self._status = "Enabled"
	table.clear(self._suspendedEventQueue)
end

return SingleEventManager