local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"

function Signal.new()
	local self = setmetatable({}, Signal)
	self._connections = {}
	self._bind = Instance.new("BindableEvent")
	self._params = nil
	return self
end

function Signal:Connect(callback)
	local eventConnection = self._bind.Event:Connect(function()
		callback(unpack(self._params))
	end)
	table.insert(self._connections, eventConnection)
	return eventConnection
end

function Signal:Fire(...)
	self._params = { ... }
	self._bind:Fire()
	self._params = nil
end

function Signal:Wait()
	return self._bind.Event:Wait()
end

function Signal:Clear()
	for _, _connection in pairs(self._connections) do
		_connection:Dsiconnect()
	end

	self._connections = {}
end

function Signal:Destroy()
	self:Clear()
	self._bind:Destroy()
	self._bind = nil
end

return Signal