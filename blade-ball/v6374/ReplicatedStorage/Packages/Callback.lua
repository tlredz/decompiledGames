local Callback = {
	create = function()
		return {
			i = {},
			d = {},
			_t = debug.traceback()
		}
	end,
	disconnect = function(p, p2)
		local index = table.find(p.i, p2)

		if index then
			table.remove(p.i, index)
		end

		local index2 = table.find(p.d, p2)

		if index2 then
			table.remove(p.d, index2)
		end
	end
}

function Callback.connectImmediate(p, p2)
	table.insert(p.i, p2)
	return function()
		Callback.disconnect(p, p2)
	end
end

function Callback.connectDeferred(p, p2)
	table.insert(p.d, p2)
	return function()
		Callback.disconnect(p, p2)
	end
end

function Callback.connect(p, p2)
	warn(debug.traceback(
		"Callback.connect is deprecated, use Callback.connectImmediate or Callback.connectDeferred instead",
		2
	))
	return Callback.connectDeferred(p, p2)
end

function Callback.isConnected(p, p2)
	return table.find(p.i, p2) ~= nil or table.find(p.d, p2) ~= nil
end

function Callback.once(p, callback)
	local flag = false
	local v = nil
	v = Callback.connectImmediate(p, function(...)
		if flag then
			return
		end

		flag = true
		v()

		if type(callback) == "function" then
			callback(...)
		else
			task.spawn(callback, ...)
		end
	end)
	return v
end

function Callback.wait(p)
	local thread = coroutine.running()
	Callback.once(p, function(...)
		assert(coroutine.status(thread) == "suspended", "Callback.wait expected a suspended thread")
		task.spawn(thread, ...)
	end)
	return coroutine.yield()
end

function Callback.fire(p, ...)
	debug.profilebegin("Callback.fire immediate")

	for k, v in table.clone(p.i) do
		debug.profilebegin((`Callback {k}`))

		if type(v) == "thread" then
			if coroutine.status(v) == "suspended" then
				task.spawn(v, ...)
			end
		else
			task.spawn(v, ...)
		end

		debug.profileend()
	end

	debug.profileend()
	debug.profilebegin("Callback.fire deferred")

	for k, v in table.clone(p.d) do
		debug.profilebegin((`Callback {k}`))

		if type(v) == "thread" then
			if coroutine.status(v) == "suspended" then
				task.defer(v, ...)
			end
		else
			task.defer(v, ...)
		end

		debug.profileend()
	end

	debug.profileend()
end

function Callback.clear(p)
	table.clear(p.i)
	table.clear(p.d)
end

return Callback