local thread = nil

local function passer(callback, ...)
	local v = thread
	thread = nil
	callback(...)
	thread = v
end

local function yielder()
	while true do
		passer(coroutine.yield())
	end
end

return function(callback, ...)
	if thread == nil then
		thread = coroutine.create(yielder)
		task.spawn(thread)
	end

	task.spawn(thread, callback, ...)
end