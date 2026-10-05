local class = {}
class.__index = class

function class:awaitResult()
	if self.result then
		return unpack(self.result)
	end

	if self.error then
		if self.Unsafe then
			return nil
		else
			error(self.error)
		end
	end

	table.insert(self.waiting, coroutine.running())
	return coroutine.yield()
end

function class.isFinished(p)
	return p.result ~= nil or p.error ~= nil
end

function class:asBoolean()
	local v = self:awaitResult()
	return v ~= nil and v ~= false
end

function class.awaitResultTimeout(data, duration: number, p)
	if data.result then
		return unpack(data.result)
	end

	if data.error then
		if data.Unsafe then
			return nil
		else
			error(data.error)
		end
	end

	local thread = coroutine.running()
	local flag = false
	table.insert(data.waiting, coroutine.create(function(...)
		if flag then
			return
		end

		task.spawn(thread, ...)
	end))
	task.delay(duration, function()
		if flag then
			return
		end

		task.spawn(thread, p)
	end)
	local v = { coroutine.yield() }
	flag = true
	return unpack(v)
end

function class:unsafe()
	self.Unsafe = true
	return self
end

return function(callback, ...)
	local v = {
		waiting = {}
	}
	setmetatable(v, class)
	local traceback = debug.traceback()
	v.thread = coroutine.create(function(...)
		local success, result = pcall(function(...)
			v.result = { callback(...) }
		end, ...)

		if not success then
			v.error = result
			task.spawn(error, tostring(result) .. traceback)
		end

		for _, callback2 in v.waiting do
			task.spawn(callback2, unpack(v.result or {}))
		end
	end)
	task.spawn(v.thread, ...)
	return v
end