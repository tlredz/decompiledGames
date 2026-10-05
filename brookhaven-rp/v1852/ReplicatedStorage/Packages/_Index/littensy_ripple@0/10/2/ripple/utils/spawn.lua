local v = nil

local function run(thread: thread, callback, ...)
	v = nil
	callback(...)
	v = thread
end

local function runner()
	while true do
		run(coroutine.yield())
	end
end

local function spawn(callback, ...)
	local v2 = v or task.spawn(runner)
	task.spawn(v2, v2, callback, ...)
end

local function call(callback, ...)
	callback(...)
end

if not task then
	spawn = call
end

return spawn