local defer

if script:GetAttribute("Deferred") then
	defer = task.defer
else
	defer = task.spawn
end

local v = {}

local function reusableThreadCall(callback, p, ...)
	callback(...)
	table.insert(v, p)
end

local function reusableThread()
	while true do
		reusableThreadCall(coroutine.yield())
	end
end

local function disconnect(state)
	if not state.Connected then
		return
	end

	state.Connected = nil
	local signal = state.Signal
	local previous = state.Previous
	local next = state.Next

	if previous then
		previous.Next = next
	else
		signal.Tail = next
	end

	if next then
		next.Previous = previous
	else
		signal.Head = previous
	end
end

local class = {}
class.__index = class

function class:Connect(callback)
	local head = self.Head
	local v2 = {
		Signal = self,
		Previous = head,
		Callback = callback,
		Connected = true,
		Disconnect = disconnect
	}

	if head then
		head.Next = v2
	else
		self.Tail = v2
	end

	self.Head = v2
	return v2
end

function class:Once(callback)
	local head = self.Head
	local v2 = nil
	v2 = {
		Signal = self,
		Previous = head,
		Callback = function(...)
			if not v2.Connected then
				return
			end

			v2.Connected = false
			local previous = v2.Previous
			local next = v2.Next

			if previous then
				previous.Next = next
			else
				self.Tail = next
			end

			if next then
				next.Previous = previous
			else
				self.Head = previous
			end

			callback(...)
		end,
		Connected = true,
		Disconnect = disconnect
	}

	if head then
		head.Next = v2
	else
		self.Tail = v2
	end

	self.Head = v2
	return v2
end

function class:Wait()
	local thread = coroutine.running()
	local head = self.Head
	local v2 = nil
	v2 = {
		Previous = head,
		Callback = function(...)
			v2.Connected = false
			local previous = v2.Previous
			local next = v2.Next

			if previous then
				previous.Next = next
			else
				self.Tail = next
			end

			if next then
				next.Previous = previous
			else
				self.Head = previous
			end

			if coroutine.status(thread) == "suspended" then
				task.spawn(thread, ...)
			end
		end
	}

	if head then
		head.Next = v2
	else
		self.Tail = v2
	end

	self.Head = v2
	return coroutine.yield()
end

function class.Fire(p, ...)
	local tail = p.Tail

	while tail do
		local count = #v

		if count == 0 then
			local thread = coroutine.create(reusableThread)
			coroutine.resume(thread)
			defer(thread, tail.Callback, thread, ...)
		else
			local v2 = v[count]
			v[count] = nil
			defer(v2, tail.Callback, v2, ...)
		end

		tail = tail.Next
	end
end

function class:DisconnectAll()
	local tail = self.Tail

	while tail do
		local next = tail.Next
		tail.Connected = nil
		tail.Next = nil
		tail.Previous = nil
		tail = next
	end

	self.Tail = nil
	self.Head = nil
end

function class:Destroy()
	local tail = self.Tail

	while tail do
		local next = tail.Next
		tail.Connected = nil
		tail.Next = nil
		tail.Previous = nil
		tail = next
	end

	self.Tail = nil
	self.Head = nil
	setmetatable(self, nil)
end

return function()
	return (setmetatable({}, class))
end