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

local function Cleanup(connection, ...)
	local typeName = typeof(connection)

	if typeName == "function" then
		connection(...)
	elseif typeName == "RBXScriptConnection" then
		connection:Disconnect()
	elseif typeName == "Instance" then
		connection:Destroy()
	elseif typeName == "table" then
		if type(connection.Destroy) == "function" then
			connection:Destroy()
		elseif type(connection.Disconnect) == "function" then
			connection:Disconnect()
		end
	end
end

local function CleanupInThread(...)
	if not thread then
		thread = coroutine.create(RunEventHandlerInFreeThread)
	end

	task.spawn(assert(thread), Cleanup, ...)
end

local class = {}
class.__index = class

function class.New(maid, object)
	local v = {
		maid = maid,
		object = object
	}
	setmetatable(v, class)
	return v
end

function class:Destroy()
	self.maid.tokens[self] = nil
end

function class:Cleanup(...)
	if self.object == nil then
		return
	end

	self.maid.tokens[self] = nil
	CleanupInThread(self.object, ...)
	self.object = nil
end

local Maid = {}
Maid.__index = Maid

function Maid.New(p)
	local v = {
		tokens = {},
		is_cleaned = false,
		key = p
	}
	setmetatable(v, Maid)
	return v
end

function Maid.IsActive(p)
	return not p.is_cleaned
end

function Maid.Add(p, p2)
	if p.is_cleaned == true then
		CleanupInThread(p2)
	end

	local typeName = typeof(p2)

	if typeName == "table" then
		if type(p2.Destroy) ~= "function" and type(p2.Disconnect) ~= "function" then
			error((`[{script.Name}]: Received table as cleanup object, but couldn't detect a :Destroy() or :Disconnect() method`))
		end
	elseif typeName ~= "function" and typeName ~= "RBXScriptConnection" and typeName ~= "Instance" then
		error((`[{script.Name}]: Cleanup of type "{typeName}" not supported`))
	end

	local v = class.New(p, p2)
	p.tokens[v] = true
	return v
end

function Maid:Cleanup(...)
	if self.key ~= nil then
		error((`[{script.Name}]: "Cleanup()" is locked for this Maid`))
	end

	self.is_cleaned = true

	for k in pairs(self.tokens) do
		k:Cleanup(...)
	end
end

function Maid:Unlock(p2)
	if self.key ~= nil and self.key ~= p2 then
		error((`[{script.Name}]: Invalid lock key`))
	end

	self.key = nil
end

return Maid