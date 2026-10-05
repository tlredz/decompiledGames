require(script.Parent.TypeDefinitions)
local TestService = game:GetService("TestService")
local Table = require(script.Parent.Table)
local Signal = {}
Signal.__index = Signal
Signal.__type = "Signal"
local class = {}
class.__index = class
class.__type = "SignalConnection"

function Signal.new(name: string)
	return (setmetatable({
		Name = name,
		Connections = {},
		YieldingThreads = {}
	}, Signal))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function NewConnection(signal, delegate)
	return (setmetatable({
		Signal = signal,
		Delegate = delegate,
		Index = -1
	}, class))
end

local function ThreadAndReportError(delegate, list, name: string)
	local thread = coroutine.create(function()
		delegate(unpack(list))
	end)
	local v, v2 = coroutine.resume(thread)

	if not v then
		TestService:Error(string.format("Exception thrown in your %s event handler: %s", name, v2))
		TestService:Checkpoint(debug.traceback(thread))
	end
end

function Signal.Connect(signal, delegate)
	assert(
		getmetatable(signal) == Signal,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"Connect",
			"Signal.new()"
		)
	)
	local newConnection = NewConnection(signal, delegate) -- equivalent call inferred; original call site unknown
	newConnection.Index = #signal.Connections + 1
	Table.insert(signal.Connections, newConnection.Index, newConnection)
	return newConnection
end

function Signal.Fire(p, ...)
	assert(
		getmetatable(p) == Signal,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"Fire",
			"Signal.new()"
		)
	)
	local pack = Table.pack(...)
	local connections = p.Connections
	local yieldingThreads = p.YieldingThreads

	for i = 1, #connections do
		local connection = connections[i]

		if connection.Delegate ~= nil then
			ThreadAndReportError(connection.Delegate, pack, connection.Signal.Name)
		end
	end

	for i = 1, #yieldingThreads do
		local yieldingThread = yieldingThreads[i]

		if yieldingThread ~= nil then
			coroutine.resume(yieldingThread, ...)
		end
	end
end

function Signal.FireSync(p, ...)
	assert(
		getmetatable(p) == Signal,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"FireSync",
			"Signal.new()"
		)
	)
	local pack = Table.pack(...)
	local connections = p.Connections
	local yieldingThreads = p.YieldingThreads

	for i = 1, #connections do
		local connection = connections[i]

		if connection.Delegate ~= nil then
			connection.Delegate(unpack(pack))
		end
	end

	for i = 1, #yieldingThreads do
		local yieldingThread = yieldingThreads[i]

		if yieldingThread ~= nil then
			coroutine.resume(yieldingThread, ...)
		end
	end
end

function Signal.Wait(p)
	assert(
		getmetatable(p) == Signal,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"Wait",
			"Signal.new()"
		)
	)
	local thread = coroutine.running()
	Table.insert(p.YieldingThreads, thread)
	local v = { coroutine.yield() }
	Table.removeObject(p.YieldingThreads, thread)
	return unpack(v)
end

function Signal:Dispose()
	assert(
		getmetatable(self) == Signal,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"Dispose",
			"Signal.new()"
		)
	)
	local connections = self.Connections

	for i = 1, #connections do
		connections[i]:Disconnect()
	end

	self.Connections = {}
	setmetatable(self, nil)
end

function class:Disconnect()
	assert(
		getmetatable(self) == class,
		("Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"):format(
			"Disconnect",
			"private function NewConnection()"
		)
	)
	Table.remove(self.Signal.Connections, self.Index)
	self.SignalStatic = nil
	self.Delegate = nil
	self.YieldingThreads = {}
	self.Index = -1
	setmetatable(self, nil)
end

return Signal