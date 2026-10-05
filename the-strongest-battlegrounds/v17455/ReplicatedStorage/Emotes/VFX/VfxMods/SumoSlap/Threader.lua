return function()
	local thread = nil

	local function functionPasser(callback, ...)
		local v = thread
		thread = nil
		callback(...)
		thread = v
	end

	local function yielder()
		while true do
			functionPasser(coroutine.yield())
		end
	end

	local function runner(p, ...)
		if not thread then
			thread = coroutine.create(yielder)
			coroutine.resume(thread)
		end

		task.spawn(thread, p, ...)
	end

	return {
		Thread = thread,
		RunFunction = runner
	}
end