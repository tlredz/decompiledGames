local thread = false

local function AcquireThread(callback, ...)
	local v = thread
	thread = nil
	callback(...)
	thread = v
end

local function CreateThreadTask(...)
	AcquireThread(...)

	while true do
		AcquireThread(coroutine.yield())
	end
end

return {
	New = function(p, ...)
		if not thread then
			thread = coroutine.create(CreateThreadTask)
		end

		task.spawn(thread, p, ...)
	end
}