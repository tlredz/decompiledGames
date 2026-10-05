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

local class = {}
class.__index = class
local class2 = {}
class2.__index = class2

function class:Disconnect()
	if self.is_connected == false then
		return
	end

	local signal = self.signal
	self.is_connected = false
	signal.listener_count -= 1

	if signal.head == self then
		signal.head = self.next
		return
	end

	local head = signal.head

	while head ~= nil and head.next ~= self do
		head = head.next
	end

	if head ~= nil then
		head.next = self.next
	end
end

function class2.New()
	local v = {
		head = nil,
		listener_count = 0
	}
	setmetatable(v, class2)
	return v
end

function class2:Connect(listener)
	if type(listener) ~= "function" then
		error((`[{script.Name}]: "listener" must be a function; Received {typeof(listener)}`))
	end

	local head = {
		listener = listener,
		signal = self,
		next = self.head,
		is_connected = true
	}
	setmetatable(head, class)
	self.head = head
	self.listener_count += 1
	return head
end

function class2.GetListenerCount(p)
	return p.listener_count
end

function class2.Fire(p, ...)
	local head = p.head

	while head ~= nil do
		if head.is_connected == true then
			if not thread then
				thread = coroutine.create(RunEventHandlerInFreeThread)
			end

			task.spawn(thread, head.listener, ...)
		end

		head = head.next
	end
end

function class2:Wait()
	local thread2 = coroutine.running()
	local connection = nil
	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread2, ...)
	end)
	return coroutine.yield()
end

function class2.FireUntil(p, callback, ...)
	if type(callback) ~= "function" then
		error((`[{script.Name}]: "continue_callback" must be a function; Received {typeof(callback)}`))
	end

	local v = table.pack(...)
	local head = p.head
	local heads = {}

	while head ~= nil do
		table.insert(heads, head)
		head = head.next
	end

	task.spawn(function()
		for _, v2 in ipairs(heads) do
			if v2.is_connected ~= true then
				continue
			end

			v2.listener(table.unpack(v))

			if callback() ~= true then
				break
			end
		end
	end)
end

return table.freeze({
	New = class2.New
})