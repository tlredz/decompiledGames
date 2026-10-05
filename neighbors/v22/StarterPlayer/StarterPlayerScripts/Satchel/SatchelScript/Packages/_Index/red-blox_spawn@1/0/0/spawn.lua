local thread = nil

local function FunctionPasser(callback, ...)
	local v = thread
	thread = nil
	callback(...)
	thread = v
end

local function Yielder()
	while true do
		FunctionPasser(coroutine.yield())
	end
end

return function(callback, ...)
	if not thread then
		thread = coroutine.create(Yielder)
		coroutine.resume(thread)
	end

	task.spawn(thread, callback, ...)
end