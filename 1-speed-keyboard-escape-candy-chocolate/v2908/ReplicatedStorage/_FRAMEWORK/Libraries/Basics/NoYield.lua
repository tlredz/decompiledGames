local function resultHandler(thread: thread, flag: boolean, ...)
	if not flag then
		local v = ...

		if typeof(v) == "string" then
			error(debug.traceback(thread, v), 2)
		else
			error(tostring(v), 2)
		end
	end

	if coroutine.status(thread) ~= "dead" then
		local traceback = debug.traceback(thread, "Attempted to yield inside a no-yield callback!")
		coroutine.close(thread)
		error(traceback, 2)
	end

	return ...
end

local function NoYield(callback, ...)
	local thread = coroutine.create(callback)
	return resultHandler(thread, coroutine.resume(thread, ...))
end

return NoYield