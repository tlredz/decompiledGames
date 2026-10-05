local v = {}
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local v2 = {
	Network = {},
	Machine = {}
}
local v3 = {}

local function count(items)
	local count2 = 0

	for _, _ in pairs(items) do
		count2 += 1
	end

	return count2
end

local function connect(eventListId, eventName, func, options)
	if func == nil then
		print("connecting nil func", eventName, nil)
	end

	local v4 = options or {}
	local blocking = v4.Blocking
	local returning = v4.Returning
	local v5 = v2[eventListId]
	local v6 = v5[eventName] or {
		Blocking = blocking,
		Returning = returning,
		Connections = {}
	}

	if v6.Blocking ~= blocking then
		error("Attempted to connect non-blocking func to blocking event " .. eventName)
	end

	if v6.Returning ~= returning then
		error("Attempted to connect non-returning func to returning event " .. eventName)
	end

	v5[eventName] = v6
	local v7 = {
		EventName = eventName,
		ConnectionId = HttpService:GenerateGUID(),
		EventListId = eventListId,
		func = func
	}
	v5[eventName].Connections[v7.ConnectionId] = v7
	return v7
end

local function fire(p, p2, ...)
	local v4 = v2[p][p2]

	if not v4 then
		return
	end

	if v4.Returning then
		local _, v5 = next(v4.Connections)

		if not v5.func then
			print(p2, "?")
		end

		return v5.func(...)
	else
		for _, connection in pairs(v4.Connections) do
			if v4.Blocking then
				connection.func(...)
			else
				local v6 = connection
				local v7 = { ... }
				task.spawn(function()
					v6.func(unpack(v7))
				end)
			end
		end
	end
end

function v.connect(eventName, func, p3)
	return (connect("Machine", eventName, func, p3))
end

function v.fire(p, ...)
	return fire("Machine", p, ...)
end

function v.disconnect(data)
	if data.ScheduledProcess then
		v3[data.ConnectionId] = nil
		return
	end

	local eventName = data.EventName
	local v4 = v2[data.EventListId]
	local connections = v4[eventName].Connections
	connections[data.ConnectionId] = nil
	local count2 = 0

	for _, _ in pairs(connections) do
		count2 += 1
	end

	if count2 == 0 then
		v4[eventName] = nil
	end
end

function v.remoteConnect(eventName, func, p3)
	return (connect("Network", eventName, func, p3))
end

function v.fireNetwork(p, ...)
	return fire("Network", p, ...)
end

function v.schedule(p, p2)
	local GUID = HttpService:GenerateGUID()
	local total = 0
	v3[GUID] = p == 0 and p2 or function(p3)
		total += p3

		if total < p then
			return
		end

		total = 0
		spawn(p2)
	end
	return {
		ConnectionId = GUID,
		ScheduledProcess = true
	}
end

function v.deschedule(p)
	v3[p] = nil
end

function v.forward(p, ...)
	local v4 = { ... }
	return v.connect(p, function(...)
		for _, v5 in pairs(v4) do
			v.fire(v5, ...)
		end
	end)
end

RunService.Heartbeat:connect(function(p)
	for _, v4 in pairs(v3) do
		v4(p)
	end
end)

if RunService:IsServer() then
	for _, child in pairs(script:GetChildren()) do
		child:destroy()
	end

	local remoteFunction = Instance.new("RemoteFunction", script)
	local remoteEvent = Instance.new("RemoteEvent", script)
	local unreliableRemoteEvent = Instance.new("UnreliableRemoteEvent", script)
	local unreliableRemoteEvent2 = Instance.new("UnreliableRemoteEvent", script)
	local remoteEvent2 = Instance.new("RemoteEvent", script)
	local remoteFunction2 = Instance.new("RemoteFunction", script)
	unreliableRemoteEvent2.Name = "FastUre"
	remoteFunction2.Name = "FastRf"
	remoteEvent2.Name = "FastRe"

	function v.remoteFire(player, p, ...)
		remoteEvent:FireClient(player, p, ...)
	end

	function v.unreliableRemoteFire(player, p, ...)
		unreliableRemoteEvent:FireClient(player, p, ...)
	end

	function v.fireAll(p, ...)
		remoteEvent:FireAllClients(p, ...)
	end

	function v.fastFireAll(p, ...)
		local GUID = HttpService:GenerateGUID()
		unreliableRemoteEvent2:FireAllClients(p, GUID, ...)
		remoteEvent2:FireAllClients(p, GUID, ...)
	end

	function v.firePlayers(items, p, ...)
		for _, player in pairs(items) do
			remoteEvent:FireClient(player, p, ...)
		end
	end

	function v.replicate(p, p2, ...)
		for _, v4 in pairs(game.Players:GetPlayers()) do
			if v4 ~= p then
				v.remoteFire(v4, p2, ...)
			end
		end
	end

	local function recServer(p, p2, ...)
		return fire("Network", p2, p, ...)
	end

	local v4 = {}

	local function fastRecServer(p, p2, p3, ...)
		if v4[p3] then
			return
		end

		v4[p3] = true
		task.delay(10, function()
			v4[p3] = nil
		end)
		recServer(p, p2, ...)
	end

	remoteFunction.OnServerInvoke = recServer
	unreliableRemoteEvent.OnServerEvent:Connect(recServer)
	remoteFunction2.OnServerInvoke = fastRecServer
	unreliableRemoteEvent2.OnServerEvent:Connect(fastRecServer)
	v.remoteConnect("//ping", function()
		return true
	end, {
		Blocking = true,
		Returning = true
	})
	return v
else
	local remoteFunction = script:WaitForChild("RemoteFunction")
	local remoteEvent = script:WaitForChild("RemoteEvent")
	local unreliableRemoteEvent = script:WaitForChild("UnreliableRemoteEvent")
	local fastUre = script:WaitForChild("FastUre")
	local fastRf = script:WaitForChild("FastRf")
	local fastRe = script:WaitForChild("FastRe")

	function v.remoteFire(p, ...)
		return remoteFunction:InvokeServer(p, ...)
	end

	function v.unreliableRemoteFire(p, ...)
		unreliableRemoteEvent:FireServer(p, ...)
	end

	function v.fastFire(p, ...)
		local GUID = HttpService:GenerateGUID()
		fastUre:FireServer(p, GUID, ...)
		fastRf:InvokeServer(p, GUID, ...)
	end

	function v.ping()
		local lastTime = os.clock()
		v.remoteFire("//ping")
		return os.clock() - lastTime
	end

	local function recClient(p, ...)
		fire("Network", p, ...)
	end

	local v4 = {}

	local function fastRecClient(p, p2, ...)
		if v4[p2] then
			return
		end

		v4[p2] = true
		task.delay(10, function()
			v4[p2] = nil
		end)
		recClient(p, ...)
	end

	remoteEvent.OnClientEvent:Connect(recClient)
	unreliableRemoteEvent.OnClientEvent:Connect(recClient)
	fastRe.OnClientEvent:Connect(fastRecClient)
	fastUre.OnClientEvent:Connect(fastRecClient)
	return v
end