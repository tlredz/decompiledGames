local CountDownLatch = {}
CountDownLatch.__index = CountDownLatch

function CountDownLatch.new(count: number)
	return (setmetatable({
		_count = count,
		_awaiting = {}
	}, CountDownLatch))
end

function CountDownLatch:countDown()
	if not (self._count > 0) then
		return
	end

	self._count -= 1

	if self._count ~= 0 then
		return
	end

	for _, callback in self._awaiting do
		task.spawn(callback)
	end

	table.clear(self._awaiting)
end

function CountDownLatch:getCount()
	return self._count
end

function CountDownLatch:await(duration: number?)
	if self._count == 0 then
		return true
	end

	local v = false
	local thread = coroutine.running()

	if duration then
		task.delay(duration, function()
			if not v then
				v = true
				task.spawn(thread)
			end
		end)
	end

	table.insert(self._awaiting, thread)
	coroutine.yield()
	local v2 = v
	v = true
	return not v2
end

return CountDownLatch