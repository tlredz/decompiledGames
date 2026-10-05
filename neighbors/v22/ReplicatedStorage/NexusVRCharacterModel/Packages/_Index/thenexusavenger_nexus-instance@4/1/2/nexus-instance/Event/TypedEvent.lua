local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TypedEventConnection = require(script.Parent:WaitForChild("TypedEventConnection"))
local TypedEvent = {
	LastArguments = {},
	QueuedClearArguments = {}
}
TypedEvent.__index = TypedEvent

function TypedEvent.new()
	return (setmetatable({
		BindableEvent = Instance.new("BindableEvent"),
		Connections = {},
		CurrentWaits = 0
	}, TypedEvent))
end

function TypedEvent:Connect(callback)
	local v = TypedEventConnection.new(self, callback)
	local eventConnection = self.BindableEvent.Event:Connect(function(p)
		v:Fire(table.unpack(self.LastArguments[p]))
	end)
	self.Connections[v] = eventConnection
	return v
end

function TypedEvent:Once(callback)
	local connection = nil
	connection = self:Connect(function(...)
		if connection then
			connection:Disconnect()
		end

		callback(...)
	end)
end

function TypedEvent:Wait()
	self.CurrentWaits += 1
	local v = self.BindableEvent.Event:Wait()
	self.CurrentWaits -= 1
	return table.unpack(self.LastArguments[v])
end

function TypedEvent:Fire(...)
	if next(self.Connections) == nil and self.CurrentWaits <= 0 then
		return
	end

	local GUID = HttpService:GenerateGUID()
	local v = table.pack(...)
	self.LastArguments[GUID] = v
	task.defer(function()
		TypedEvent.QueuedClearArguments[GUID] = true
	end)
	self.BindableEvent:Fire(GUID)
end

function TypedEvent.Disconnected(p, p2)
	if not p.Connections[p2] then
		return
	end

	p.Connections[p2]:Disconnect()
	p.Connections[p2] = nil
end

function TypedEvent:Destroy()
	local connections = self.Connections
	self.Connections = {}
	self.CurrentWaits = 0

	for connection, _ in connections do
		connection:Disconnect()
	end

	self.BindableEvent:Destroy()
end

RunService.Heartbeat:Connect(function()
	local queuedClearArguments = TypedEvent.QueuedClearArguments
	TypedEvent.QueuedClearArguments = {}

	for k, _ in queuedClearArguments do
		TypedEvent.LastArguments[k] = nil
	end
end)
return TypedEvent