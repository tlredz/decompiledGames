local Players = game:GetService("Players")
local v = {}
local v2 = {}
local MockRemotes = {}

function MockRemotes.createMockRemoteEvent(name: string)
	if v[name] then
		return v[name]
	end

	local v3 = {
		Name = name,
		OnClientEvent = {},
		OnServerEvent = {}
	}
	local v4 = {}
	local v5 = {}

	function v3.OnClientEvent.Connect(_, callback)
		v4[callback] = true
		return {
			Connected = true,
			Disconnect = function(p2)
				p2.Connected = false
				v4[callback] = nil
			end
		}
	end

	function v3.OnServerEvent.Connect(_, callback)
		v5[callback] = true
		return {
			Connected = true,
			Disconnect = function(p2)
				p2.Connected = false
				v5[callback] = nil
			end
		}
	end

	function v3.FireClient(_, _, ...)
		for k in v4 do
			k(...)
		end
	end

	function v3.FireAllClients(_, ...)
		for k in v4 do
			k(...)
		end
	end

	function v3.FireServer(_, ...)
		for k in v5 do
			k(Players.LocalPlayer or {}, ...)
		end
	end

	function v3.Destroy(_)
		v[name] = nil
		table.clear(v4)
		table.clear(v5)
	end

	v[name] = v3
	return v3
end

function MockRemotes.createMockRemoteFunction(name: string)
	if v2[name] then
		return v2[name]
	end

	local v3 = {
		Name = name,
		OnClientInvoke = function() end,
		OnServerInvoke = function() end,
		InvokeClient = function(p2, _, ...)
			return p2.OnClientInvoke(...)
		end,
		InvokeServer = function(p2, ...)
			return p2.OnServerInvoke(Players.LocalPlayer or {}, ...)
		end
	}

	function v3.Destroy(_)
		v2[name] = nil

		v3.OnClientInvoke = function() end

		v3.OnServerInvoke = function() end
	end

	v2[name] = v3
	return v3
end

function MockRemotes.getMockRemoteEvent(p: string)
	return v[p]
end

function MockRemotes.getMockRemoteFunction(p: string)
	return v2[p]
end

function MockRemotes.destroyAll()
	table.clear(v)
	table.clear(v2)
end

return MockRemotes