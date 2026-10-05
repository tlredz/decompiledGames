local v = table.create(500)

local function RunFunction(callback, thread: thread, ...)
	callback(...)
	table.insert(v, thread)
end

local function Yield()
	while true do
		RunFunction(coroutine.yield())
	end
end

local function FastDefer(callback, ...)
	local count = #v
	local thread

	if count > 0 then
		thread = v[count]
		v[count] = nil
	else
		thread = coroutine.create(Yield)
		coroutine.resume(thread)
	end

	return task.defer(thread, callback, thread, ...)
end

return FastDefer