local Semaphore = {}
Semaphore.__index = Semaphore

function Semaphore.new(permits: number)
	return (setmetatable({
		_permits = permits,
		_awaiting = {}
	}, Semaphore))
end

function Semaphore:release()
	self._permits += 1

	if self._permits < 1 or #self._awaiting == 0 then
		return
	end

	local v = self._awaiting[#self._awaiting]
	table.remove(self._awaiting, #self._awaiting)
	task.spawn(v)
end

function Semaphore:availablePermits()
	return self._permits
end

function Semaphore:acquire(duration: number?)
	if self._permits >= 1 then
		self._permits -= 1
		return true
	end

	local v = false
	local thread = coroutine.running()

	if duration then
		task.delay(duration, function()
			if not v then
				v = true
				local index = table.find(self._awaiting, thread)

				if index ~= nil then
					table.remove(self._awaiting, index)
				end

				task.spawn(thread)
			end
		end)
	end

	table.insert(self._awaiting, thread)
	coroutine.yield()

	if not v then
		self._permits -= 1
	end

	local index = table.find(self._awaiting, thread)

	if index ~= nil then
		table.remove(self._awaiting, index)
	end

	local v2 = v
	v = true
	return not v2
end

return Semaphore