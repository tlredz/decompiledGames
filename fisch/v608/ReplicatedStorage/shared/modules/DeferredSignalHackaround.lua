local v = {}
local v2 = {}
task.spawn(function()
	while true do
		for _, connections in v do
			connections[3] = connections[1]:Connect(connections[2])
		end

		for _, connections in v2 do
			connections[3] = connections[1]:Once(connections[2])
		end

		table.clear(v)
		table.clear(v2)
		task.wait()
	end
end)
local DeferredSignalHackaround = {}

function DeferredSignalHackaround:Connect(callback)
	assert(typeof(self) == "RBXScriptSignal", "argument #1 must be an RBXScriptSignal")
	assert(typeof(callback) == "function", "argument #2 must be a function")
	table.insert(v, { self, callback, nil })
end

function DeferredSignalHackaround.ConnectAsync(p, callback)
	assert(typeof(p) == "RBXScriptSignal", "argument #1 must be an RBXScriptSignal")
	assert(typeof(callback) == "function", "argument #2 must be a function")
	local v3 = { p, callback, nil }
	table.insert(v, v3)

	while not v3[3] do
		task.wait()
	end

	return v3[3]
end

function DeferredSignalHackaround:Once(callback)
	assert(typeof(self) == "RBXScriptSignal", "argument #1 must be an RBXScriptSignal")
	assert(typeof(callback) == "function", "argument #2 must be a function")
	table.insert(v2, { self, callback, nil })
end

function DeferredSignalHackaround.OnceAsync(p, callback)
	assert(typeof(p) == "RBXScriptSignal", "argument #1 must be an RBXScriptSignal")
	assert(typeof(callback) == "function", "argument #2 must be a function")
	local v3 = { p, callback, nil }
	table.insert(v2, v3)

	while not v3[3] do
		task.wait()
	end

	return v3[3]
end

return DeferredSignalHackaround