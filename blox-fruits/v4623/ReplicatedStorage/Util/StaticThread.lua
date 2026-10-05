local StaticThread = {
	Stop = function(p)
		if p._InternalCoroutine and coroutine.status(p._InternalCoroutine) ~= "dead" then
			if p._InternalCoroutine == coroutine.running() then
				task.defer(function()
					task.cancel(p._InternalCoroutine)
				end)
			end

			p._InternalCoroutine = nil
		end
	end,
	Start = function(state)
		if not state._InternalCoroutine or coroutine.status(state._InternalCoroutine) == "dead" then
			state._InternalCoroutine = coroutine.create(state._closure)
			task.spawn(state._InternalCoroutine)
		end
	end
}

function StaticThread.new(callback, timeBetweenTicks: number)
	local v = nil

	local function fn()
		while true do
			local now = tick()

			if callback(now - v._LastTickTime) == true then
				break
			end

			v._LastTickTime = now
			task.wait(v._TimeBetweenTicks)
		end

		task.defer(StaticThread.Stop, v)
	end

	v = {
		_LastTickTime = tick(),
		_TimeBetweenTicks = timeBetweenTicks,
		_closure = fn
	}
	return (setmetatable(v, {
		__index = StaticThread
	}))
end

return StaticThread