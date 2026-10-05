local v = {}
local Threads = {}

function Threads.Run(_, p, callback, ...)
	assert(p ~= nil, "ThreadManager: Key cannot be nil")
	assert(type(callback) == "function", "ThreadManager: Callback must be a function")

	if not v[p] then
		v[p] = {}
	end

	local thread = nil
	thread = coroutine.create(function(...)
		callback(...)

		if v[p] and v[p][thread] then
			v[p][thread] = nil

			if next(v[p]) == nil then
				v[p] = nil
			end
		end
	end)
	v[p][thread] = true
	task.spawn(thread, table.unpack({ ... }))
	return thread
end

function Threads.CancelKey(_, p)
	local v2 = v[p]

	if v2 then
		for k in pairs(v2) do
			if coroutine.status(k) ~= "dead" then
				pcall(task.cancel, k)
			end
		end

		v[p] = nil
	end
end

function Threads.CancelThread(_, p)
	if typeof(p) ~= "thread" then
		return
	end

	if coroutine.status(p) ~= "dead" then
		pcall(task.cancel, p)
	end

	for k, v2 in pairs(v) do
		if not v2[p] then
			continue
		end

		v2[p] = nil

		if next(v2) ~= nil then
			break
		end

		v[k] = nil
		break
	end
end

function Threads.CancelAll(_)
	for k, v2 in pairs(v) do
		for k2 in pairs(v2) do
			if coroutine.status(k2) ~= "dead" then
				pcall(task.cancel, k2)
			end
		end

		v[k] = nil
	end
end

function Threads.Count(_, p)
	local count = 0

	if v[p] then
		for _ in pairs(v[p]) do
			count += 1
		end
	end

	return count
end

return Threads