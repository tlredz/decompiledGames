local function pack(...)
	return {
		n = select("#", ...),
		...
	}
end

local v = {
	__index = {}
}

function v.__index:Disconnect()
	if self.conn then
		self.conn:Disconnect()
		self.conn = nil
	end

	if not self.signal then
		return
	end

	self.Connected = false
	local connections = self.signal.connections

	for i = 1, #connections do
		if connections[i] ~= self then
			continue
		end

		table.remove(connections, i)
		break
	end

	self.signal:destruct()
	self.signal = nil
end

function v.__index.IsConnected(p)
	if p.conn then
		return p.conn.Connected
	end

	return false
end

local v2 = {
	__index = {}
}

function v2.__index:Connect(callback)
	local signal = self.signal
	signal:construct()
	local object = setmetatable({
		signal = signal,
		conn = signal.usignal.Event:Connect(function(p2)
			local arg = signal.args[p2]
			arg[1] -= 1

			if arg[1] <= 0 then
				signal.args[p2] = nil
			end

			callback(unpack(arg[2], 1, arg[2].n))
		end),
		Connected = true
	}, v)
	table.insert(signal.connections, object)
	return object
end

local v3 = {
	__index = {}
}

function v3.__index.GetEvent(p)
	return p.event
end

function v3.__index:Connect(...)
	return self.event:Connect(...)
end

function v3.__index:Fire(...)
	local nextID = self.nextID
	self.nextID += 1
	self.args[nextID] = { #self.connections + self.threads, pack(...) }
	self.threads = 0
	self.usignal:Fire(nextID)
end

function v3.__index:Wait()
	self.threads += 1
	local v4 = self.usignal.Event:Wait()
	local arg = self.args[v4]
	arg[1] -= 1

	if arg[1] <= 0 then
		self.args[v4] = nil
	end

	return unpack(arg[2], 1, arg[2].n)
end

function v3.__index:Destroy()
	self.usignal:Destroy()
	self.usignal = Instance.new("BindableEvent")
	local connections = self.connections

	for i = #connections, 1, -1 do
		local connection = connections[i]
		connection.signal = nil
		connection.conn = nil
		connection.Connected = false
		connections[i] = nil
	end

	self.threads = 0
	self:destruct()
end

function v3.__index:construct()
	if #self.connections > 0 then
		return
	end

	if self.ctor and not self.ctorData then
		self.ctorData = pack(self.ctor(self))
	end
end

function v3.__index:destruct()
	if #self.connections > 0 then
		return
	end

	if self.dtor and self.ctorData then
		self.dtor(self, unpack(self.ctorData, 1, self.ctorData.n))
		self.ctorData = nil
	end
end

function Signal(ctor, callback2)
	local signal = {
		ctor = ctor,
		dtor = callback2,
		ctorData = nil,
		args = {},
		nextID = 0,
		connections = {},
		usignal = Instance.new("BindableEvent"),
		threads = 0
	}
	signal.event = setmetatable({
		signal = signal
	}, v2)
	signal.Event = signal.event
	return (setmetatable(signal, v3))
end

return Signal