local class = {}
class.__index = class

function class.__tostring()
	return "Simple Signal"
end

local insert = table.insert
local remove = table.remove
local find = table.find
local v = {
	__simplesignalconnection = true
}
v.__index = v

function v.__tostring()
	return "Simple Signal Connection"
end

function v:Disconnect()
	if self.signal ~= nil then
		local index = find(self.signal, self)

		if index ~= nil then
			remove(self.signal, index)
		end
	end

	if self.lists ~= nil then
		local index = find(self.lists, self)

		if index ~= nil then
			remove(self.lists, index)
		end

		self.lists = nil
	end

	self.__simplesignalconnection = nil
	self.func = nil
	self.signal = nil
end

v.Destroy = v.Disconnect

function class:Connect(func, lists)
	if self.Destroying == true then
		return
	end

	local object = setmetatable({
		func = func,
		signal = self
	}, v)
	insert(self, object)

	if self.Queu ~= nil then
		for i = #self.Queu, 1, -1 do
			self:Fire(table.unpack(self.Queu[i]))
			self.Queu[i] = nil
		end

		table.clear(self.Queu)
		self.Queu = nil
	end

	if lists ~= nil and object.lists == nil then
		object.lists = lists
	end

	return object
end

function class.Once(instance, callback)
	if instance.Destroying == true then
		return
	end

	local connection = nil
	connection = setmetatable({
		func = function(...)
			callback(...)
			connection:Disconnect()
		end,
		signal = instance,
		Once = true
	}, v)
	insert(instance, connection)
	return connection
end

function class:Destroy()
	if self.Destroying then
		return
	end

	self.Destroying = true
	self:DisconnectAll()
	self.Destroying = nil
end

function class:DisconnectAll()
	for i = #self, 1, -1 do
		if self[i] == nil then
			continue
		end

		self[i]:Disconnect()
		self[i] = nil
	end
end

local thread = nil
local resume = coroutine.resume
local yield = coroutine.yield
local _ = coroutine.create

local function fn(callback, ...)
	if callback == nil then
		return true
	end

	local v2 = thread
	thread = nil
	callback(...)

	if thread ~= nil then
		return true
	end

	thread = v2
end

local function fn2()
	while not fn(yield()) do

	end
end

local error2 = error

function class:Fire(...)
	local count = #self

	while count > 0 do
		local v2 = self[count]

		if v2 == nil then
			continue
		end

		if thread == nil then
			thread = task.spawn(fn2)
		end

		local v3, v4 = resume(thread, v2.func, ...)

		if not v3 then
			task.spawn(error2, (`'{v4}'\n{debug.traceback(thread)}`))
			thread = nil
		end

		count -= 1
	end
end

function class.BasicFire(list, ...)
	local count = #list

	while count > 0 do
		local connection = list[count]

		if connection == nil then
			continue
		end

		connection.func(...)

		if connection.Once == true and connection.Disconnect then
			connection:Disconnect()
		end

		count -= 1
	end
end

function class:SafeFire(...)
	if #self > 0 then
		task.defer(self.BasicFire, self, ...)
		return
	end

	if self.Queu == nil then
		self.Queu = {}
	end

	table.insert(self.Queu, { ... })
end

function class:Wait(duration: number?)
	local thread2 = coroutine.running()
	local v2 = false
	local connection = nil
	local thread3 = nil
	connection = self:Connect(function(...)
		if not v2 then
			v2 = true
			connection:Disconnect()

			if thread3 then
				task.cancel(thread3)
				thread3 = nil
			end

			resume(thread2, ...)
		end
	end)

	if duration then
		thread3 = task.delay(duration, function()
			if not v2 then
				v2 = true
				connection:Disconnect()
				resume(thread2, nil)
			end
		end)
	end

	return coroutine.yield()
end

return {
	new = function()
		return (setmetatable({}, class))
	end
}