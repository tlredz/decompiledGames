local spawn = (task or require("@lune/task")).spawn
local yield = coroutine.yield
local thread = nil

local function deletedSignalError()
	error("Cannot fire a deleted signal", 2)
end

local v = {
	fire = deletedSignalError,
	connect = deletedSignalError,
	once = deletedSignalError,
	wait = deletedSignalError,
	disconnectAll = deletedSignalError
}

local function run(callback, ...)
	local v2 = thread
	thread = nil
	callback(...)
	thread = v2
end

local function yieldLoop()
	while true do
		run(yield())
	end
end

local class = {}
class.__index = class

local function constructor()
	return (setmetatable({}, class))
end

function class:connect(callback)
	table.insert(self, callback)
	return function()
		local index = table.find(self, callback)

		if index then
			table.remove(self, index)
		end
	end
end

function class.fire(list, ...)
	for i = #list, 1, -1 do
		local v2 = list[i]

		if not thread then
			thread = coroutine.create(yieldLoop)
			spawn(thread)
		end

		spawn(thread, v2, ...)
	end
end

function class:once(callback)
	local connection = nil
	connection = self:connect(function(...)
		connection()
		callback(...)
	end)
end

function class:wait()
	local thread2 = coroutine.running()
	self:once(function(...)
		assert(
			coroutine.status(thread2) == "suspended",
			":wait() called, then another thread resumed the waiting thread. Please dont do that :("
		)
		spawn(thread2, ...)
	end)
	return yield()
end

function class:disconnectAll()
	table.clear(self)
end

function class:delete()
	self:disconnectAll()
	setmetatable(self, v)
end

return constructor