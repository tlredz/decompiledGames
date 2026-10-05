local Hook = {
	create = function()
		return {
			c = {},
			_t = debug.traceback()
		}
	end,
	disconnect = function(p, callback)
		for k, v in p.c do
			if v.fn == callback then
				table.remove(p.c, k)
			end
		end
	end
}

function Hook.hook(p, fn, name: string?)
	table.insert(p.c, {
		fn = fn,
		name = name
	})
	return function()
		Hook.disconnect(p, fn)
	end
end

function Hook.isConnected(p, callback)
	for _, v in p.c do
		if v.fn == callback then
			return true
		end
	end

	return false
end

function Hook.fire(p, ...)
	debug.profilebegin("Hook.fire")

	for k, v in p.c do
		debug.profilebegin((`Hook {k}`))
		local v2 = v.fn(...)
		debug.profileend()

		if not v2 then
			continue
		end

		debug.profileend()
		return true
	end

	debug.profileend()
	return false
end

function Hook.clear(p)
	table.clear(p.c)
end

return Hook