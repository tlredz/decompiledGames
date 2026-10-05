local TypedEventConnection = {}
TypedEventConnection.__index = TypedEventConnection

function TypedEventConnection.new(parentEvent, connectionFunction)
	return (setmetatable({
		Connected = true,
		ParentEvent = parentEvent,
		ConnectionFunction = connectionFunction
	}, TypedEventConnection))
end

function TypedEventConnection.Fire(p, ...)
	if not p.Connected then
		return
	end

	p.ConnectionFunction(...)
end

function TypedEventConnection:Disconnect()
	if not self.Connected then
		return
	end

	self.Connected = false
	self.ParentEvent:Disconnected(self)
end

function TypedEventConnection:Destroy()
	self:Disconnect()
end

return TypedEventConnection