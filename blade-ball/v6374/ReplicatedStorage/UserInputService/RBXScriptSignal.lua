local class = {}
class.__index = class
local thread = nil

local function acquireRunnerThreadAndCallEventHandler(callback, ...)
	local v = thread
	thread = nil
	callback(...)
	thread = v
end

local function runEventHandlerInFreeThread()
	while true do
		acquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

function class:Connect(p2)
	local v, v2 = debug.info(2, "sl")
	local parts = v:split(".")
	local formatted = `{parts[#parts] or v}:{v2}`
	return self._original:Connect(function(...)
		local lastTime = os.clock()
		debug.profilebegin((`{self.name} | {formatted}`))

		if not thread then
			thread = coroutine.create(runEventHandlerInFreeThread)
			coroutine.resume(thread)
		end

		task.spawn(thread, p2, ...)
		local v3 = os.clock() - lastTime

		if v3 > 0.005 then
			warn((`[{formatted}] took {math.round(v3 * 100000) / 100}ms to execute {self.name}!`))
		end

		debug.profileend()
	end)
end

class.connect = class.Connect

function class:ConnectParallel(on_original)
	return self._original:ConnectParallel(on_original)
end

function class:Once(p2)
	local v = debug.info(2, "s")
	local v2 = debug.info(2, "l")
	local parts = v:split(".")
	local formatted = `{parts[#parts] or v}:{v2}`
	return self._original:Once(function(...)
		local lastTime = os.clock()
		debug.profilebegin((`{self.name} | {formatted}`))

		if not thread then
			thread = coroutine.create(runEventHandlerInFreeThread)
			coroutine.resume(thread)
		end

		task.spawn(thread, p2, ...)
		local v3 = os.clock() - lastTime

		if v3 > 0.005 then
			warn((`[{formatted}] took {math.round(v3 * 100000) / 100}ms to execute {self.name}!`))
		end

		debug.profileend()
	end)
end

function class:Wait()
	return self._original:Wait()
end

return {
	mock = function(original)
		return (setmetatable({
			name = tostring(original),
			_connections = {},
			_original = original
		}, {
			__index = class
		}))
	end
}