local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local heartbeat = RunService.Heartbeat
local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"
Signal.totalConnections = 0

function Signal.new(p)
	local self = setmetatable({}, Signal)

	if p then
		self.connectionsChanged = Signal.new()
	end

	self.connections = {}
	self.totalConnections = 0
	self.waiting = {}
	self.totalWaiting = 0
	return self
end

function Signal:Fire(...)
	for _, connection in pairs(self.connections) do
		connection.Handler(...)
	end

	if self.totalWaiting > 0 then
		local v = table.pack(...)

		for k, _ in pairs(self.waiting) do
			self.waiting[k] = v
		end
	end
end

Signal.fire = Signal.Fire

function Signal:Connect(handler)
	if type(handler) ~= "function" then
		error(("connect(%s)"):format((typeof(handler))), 2)
	end

	local GUID = HttpService:GenerateGUID(false)
	local v = {
		Connected = true,
		ConnectionId = GUID,
		Handler = handler
	}
	self.connections[GUID] = v

	function v.Disconnect(_)
		self.connections[GUID] = nil
		v.Connected = false
		self.totalConnections -= 1

		if self.connectionsChanged then
			self.connectionsChanged:Fire(-1)
		end
	end

	v.Destroy = v.Disconnect
	v.destroy = v.Disconnect
	v.disconnect = v.Disconnect
	self.totalConnections += 1

	if self.connectionsChanged then
		self.connectionsChanged:Fire(1)
	end

	return v
end

Signal.connect = Signal.Connect

function Signal:Wait()
	local GUID = HttpService:GenerateGUID(false)
	self.waiting[GUID] = true
	self.totalWaiting += 1

	repeat
		heartbeat:Wait()
	until self.waiting[GUID] ~= true

	self.totalWaiting -= 1
	local v = self.waiting[GUID]
	self.waiting[GUID] = nil
	return unpack(v)
end

Signal.wait = Signal.Wait

function Signal:Destroy()
	if self.bindableEvent then
		self.bindableEvent:Destroy()
		self.bindableEvent = nil
	end

	if self.connectionsChanged then
		self.connectionsChanged:Fire(-self.totalConnections)
		self.connectionsChanged:Destroy()
		self.connectionsChanged = nil
	end

	self.totalConnections = 0

	for k, _ in pairs(self.connections) do
		self.connections[k] = nil
	end
end

Signal.destroy = Signal.Destroy
Signal.Disconnect = Signal.Destroy
Signal.disconnect = Signal.Destroy
return Signal