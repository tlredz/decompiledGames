local Connections = {}
local v = {}
local v2 = {}

function Connections:Connect(p, object, callback)
	assert(p ~= nil, "ConnectionsManager: Key cannot be nil")
	assert(typeof(object) == "RBXScriptSignal", "ConnectionsManager: Expected RBXScriptSignal")
	assert(type(callback) == "function", "ConnectionsManager: Callback must be a function")

	if not v[p] then
		v[p] = {}
	end

	local connection = object:Connect(callback)
	v[p][connection] = true
	v2[connection] = p
	return connection
end

function Connections:Once(p, object, callback)
	assert(p ~= nil, "ConnectionsManager: Key cannot be nil")
	local fn

	fn = function(...)
		if v2[fn] then
			Connections:DisconnectConnection(fn)
		end

		callback(...)
	end

	if not v[p] then
		v[p] = {}
	end

	local connection = nil
	connection = object:Once(function(...)
		if v2[connection] then
			v[p][connection] = nil
			v2[connection] = nil

			if next(v[p]) == nil then
				v[p] = nil
			end
		end

		callback(...)
	end)
	v[p][connection] = true
	v2[connection] = p
	return connection
end

function Connections.Add(_, p, p2)
	assert(p ~= nil, "ConnectionsManager: Key cannot be nil")
	assert(typeof(p2) == "RBXScriptConnection", "ConnectionsManager: Expected RBXScriptConnection")

	if not v[p] then
		v[p] = {}
	end

	if v2[p2] then
		local v3 = v2[p2]

		if v[v3] then
			v[v3][p2] = nil

			if next(v[v3]) == nil then
				v[v3] = nil
			end
		end
	end

	v[p][p2] = true
	v2[p2] = p
end

function Connections.DisconnectKey(_, p)
	local v3 = v[p]

	if v3 then
		for connection in pairs(v3) do
			if connection.Connected then
				connection:Disconnect()
			end

			v2[connection] = nil
		end

		v[p] = nil
	end
end

function Connections:DisconnectConnection(connection)
	if typeof(connection) ~= "RBXScriptConnection" then
		return
	end

	if connection.Connected then
		connection:Disconnect()
	end

	local v3 = v2[connection]

	if v3 and v[v3] then
		v[v3][connection] = nil
		v2[connection] = nil

		if next(v[v3]) == nil then
			v[v3] = nil
		end
	end
end

function Connections.DisconnectAll(_)
	for k, v3 in pairs(v) do
		for connection in pairs(v3) do
			if connection.Connected then
				connection:Disconnect()
			end

			v2[connection] = nil
		end

		v[k] = nil
	end
end

function Connections.Count(_, p)
	local count = 0

	if v[p] then
		for _ in pairs(v[p]) do
			count += 1
		end
	end

	return count
end

return Connections