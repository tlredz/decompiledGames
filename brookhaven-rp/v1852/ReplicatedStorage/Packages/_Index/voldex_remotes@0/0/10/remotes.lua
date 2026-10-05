local Remotes = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("HttpService")
local Janitor = require(script.parent.Janitor)
local v = {}
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local v2 = {}

local function addComponentRemote(instance, parent)
	if v2[parent] and v2[parent][instance.Name] then
		warn(("Duplicate named remote %q, not added to cache"):format(instance.Name))
		return
	end

	local v3 = {
		RemoteEvent = instance:IsA("RemoteEvent") and instance,
		RemoteFunction = instance:IsA("RemoteFunction") and instance,
		UnreliableRemoteEvent = instance:IsA("UnreliableRemoteEvent") and instance,
		cleanupJanitor = Janitor.new()
	}
	v2[parent] = v2[parent] or {}
	v2[parent][instance.Name] = v3
end

local function removeComponentRemote(p, p2)
	local v3 = v2[p2] and v2[p2][p.Name]

	if v3 and (v3.RemoteEvent == p or v3.RemoteFunction == p) then
		v3.cleanupJanitor:Cleanup()

		for k, _ in pairs(v3) do
			v3[k] = nil
		end
	end

	v2[p2][p.Name] = nil

	if not next(v2[p2]) then
		v2[p2] = nil
	end
end

local function addRemote(descendant)
	if v[descendant.Name] and v[descendant.Name] ~= descendant then
		warn(("Duplicate named remote %q, not added to cache"):format(descendant.Name))
		return
	end

	local v3 = {
		RemoteEvent = descendant:IsA("RemoteEvent") and descendant,
		RemoteFunction = descendant:IsA("RemoteFunction") and descendant,
		UnreliableRemoteEvent = descendant:IsA("UnreliableRemoteEvent") and descendant,
		cleanupJanitor = Janitor.new()
	}
	v[descendant.Name] = v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeRemote(descendant)
	local v3 = v[descendant.Name]

	if v3 and (v3.RemoteEvent == descendant or v3.RemoteFunction == descendant) then
		v3.cleanupJanitor:Cleanup()

		for k, _ in pairs(v3) do
			v3[k] = nil
		end

		v[descendant.Name] = nil
	end
end

function Remotes.Setup()
	for _, descendant in pairs(remotes:GetDescendants()) do
		if not (descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") or descendant:IsA("UnreliableRemoteEvent")) then
			continue
		end

		addRemote(descendant)
	end

	remotes.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") or descendant:IsA("UnreliableRemoteEvent") then
			addRemote(descendant)
		end
	end)
	remotes.DescendantRemoving:Connect(function(descendant)
		if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") or descendant:IsA("UnreliableRemoteEvent") then
			removeRemote(descendant) -- equivalent call inferred; original call site unknown
		end
	end)
end

local function getRemote(p: string, p2: string)
	local lastTime = tick()
	local v3 = v[p]

	if not v3 then
		warn(("[Remotes] Remote %q not found, yielding for %d seconds"):format(p, 30))

		while not v3 and tick() - lastTime < 30 do
			task.wait()
			v3 = v[p]
		end
	end

	if not v3 then
		error(("No remote by name %q"):format(p))
	end

	if not v3[p2] then
		error(("Remote %q is not a %s"):format(p, p2))
	end

	return v3.RemoteEvent or v3.RemoteFunction or v3.UnreliableRemoteEvent
end

local function getComponentRemote(p: string, p2, p3: string)
	local lastTime = tick()
	local v3 = v2[p2] and v2[p2][p]

	if not v3 then
		warn(("[Remotes] Remote %q not found, yielding for %d seconds"):format(p, 30))

		while not v3 and tick() - lastTime < 30 do
			task.wait()
			v3 = v2[p2] and v2[p2][p]
		end
	end

	if not v3 then
		error(("No remote by name %q"):format(p))
	end

	if not v3[p3] then
		error(("Remote %q is not a %s"):format(p, p3))
	end

	return v3.RemoteEvent or v3.RemoteFunction or v3.UnreliableRemoteEvent
end

function Remotes.fireServerComponent(p, p2: string, ...)
	local componentRemote = getComponentRemote(p2, p, "RemoteEvent")

	if not componentRemote then
		error(("Remote %q not found"):format(p2))
	end

	componentRemote:FireServer(...)
end

function Remotes.fireServerComponentUnreliable(p, p2: string, ...)
	local componentRemote = getComponentRemote(p2, p, "UnreliableRemoteEvent")

	if not componentRemote then
		error(("Remote %q not found"):format(p2))
	end

	componentRemote:FireServer(...)
end

function Remotes.invokeServerComponent(p, p2: string, ...)
	local componentRemote = getComponentRemote(p2, p, "RemoteFunction")

	if not componentRemote then
		error(("Remote %q not found"):format(p2))
	end

	return componentRemote:InvokeServer(...)
end

function Remotes.fireServer(p: string, ...)
	if not RunService:IsClient() then
		error("Client Only")
	end

	getRemote(p, "RemoteEvent"):FireServer(...)
end

function Remotes.fireServerUnreliable(p: string, ...)
	if not RunService:IsClient() then
		error("Client Only")
	end

	getRemote(p, "UnreliableRemoteEvent"):FireServer(...)
end

function Remotes.invokeServer(p: string, ...)
	if not RunService:IsClient() then
		error("Client Only")
	end

	return getRemote(p, "RemoteFunction"):InvokeServer(...)
end

function Remotes.fireClientComponent(p, p2: string, player, ...)
	local componentRemote = getComponentRemote(p2, p, "RemoteEvent")

	if not componentRemote then
		error(("Remote %q not found"):format(p2))
	end

	componentRemote:FireClient(player, ...)
end

function Remotes.fireClientComponentUnreliable(p, p2: string, player, ...)
	local componentRemote = getComponentRemote(p2, p, "UnreliableRemoteEvent")

	if not componentRemote then
		error(("Remote %q not found"):format(p2))
	end

	componentRemote:FireClient(player, ...)
end

function Remotes.fireAllClientsComponent(player, p: string, ...)
	local componentRemote = getComponentRemote(p, player, "RemoteEvent")

	if not componentRemote then
		error(("Remote %q not found"):format(p))
	end

	for _, v3 in Players:GetPlayers() do
		componentRemote:FireClient(player, p, v3, ...)
	end
end

function Remotes.invokeClientComponent(p, p2: string, player, ...)
	local componentRemote = getComponentRemote(p2, p, "RemoteFunction")

	if not componentRemote then
		error(("Remote %q not found"):format(p2))
	end

	return componentRemote:InvokeClient(player, ...)
end

function Remotes.fireClient(p: string, player, ...)
	if not RunService:IsServer() then
		error("Server Only")
	end

	getRemote(p, "RemoteEvent"):FireClient(player, ...)
end

function Remotes.fireClientUnreliable(p: string, player, ...)
	if not RunService:IsServer() then
		error("Server Only")
	end

	getRemote(p, "UnreliableRemoteEvent"):FireClient(player, ...)
end

function Remotes.fireClients(p: string, items, ...)
	for _, item in pairs(items) do
		Remotes.fireClient(p, item, ...)
	end
end

function Remotes.fireAllClients(p: string, ...)
	for _, v3 in Players:GetPlayers() do
		Remotes.fireClient(p, v3, ...)
	end
end

function Remotes.invokeClient(p: string, player, ...)
	if not RunService:IsServer() then
		error("Server Only")
	end

	return getRemote(p, "RemoteFunction"):InvokeClient(player, ...)
end

function Remotes.createComponentRemoteEvent(name: string, parent)
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = name
	remoteEvent:AddTag("TrackComponentRemote")
	addComponentRemote(remoteEvent, parent)
	remoteEvent.Destroying:Once(function()
		removeComponentRemote(remoteEvent, parent)
	end)
	remoteEvent.Parent = parent
	return remoteEvent
end

function Remotes.createComponentUnreliableRemoteEvent(name: string, parent)
	local unreliableRemoteEvent = Instance.new("UnreliableRemoteEvent")
	unreliableRemoteEvent.Name = name
	unreliableRemoteEvent:AddTag("TrackComponentRemote")
	addComponentRemote(unreliableRemoteEvent, parent)
	unreliableRemoteEvent.Destroying:Once(function()
		removeComponentRemote(unreliableRemoteEvent, parent)
	end)
	unreliableRemoteEvent.Parent = parent
	return unreliableRemoteEvent
end

function Remotes.createComponentRemoteFunction(name: string, parent)
	local remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Name = name
	remoteFunction:AddTag("TrackComponentRemote")
	addComponentRemote(remoteFunction, parent)
	remoteFunction.Destroying:Once(function()
		removeComponentRemote(remoteFunction, parent)
	end)
	remoteFunction.Parent = parent
end

function Remotes.createUnreliableRemoteEvent(name: string)
	local unreliableRemoteEvent = Instance.new("UnreliableRemoteEvent")
	unreliableRemoteEvent.Name = name
	unreliableRemoteEvent.Parent = remotes
end

function Remotes.createRemoteEvent(name: string)
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = name
	remoteEvent.Parent = remotes
	return remoteEvent
end

function Remotes.createRemoteFunction(name: string)
	local remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Name = name
	remoteFunction.Parent = remotes
	return remoteFunction
end

function Remotes.connectComponentRemote(p, p2: string, callback)
	local componentRemote = getComponentRemote(p2, p, "RemoteEvent")

	if not componentRemote then
		error(("Remote %q not found"):format(p2))
	end

	if RunService:IsServer() then
		return componentRemote.OnServerEvent:Connect(function(p3, ...)
			callback(p3, ...)
		end)
	end

	if RunService:IsClient() then
		return componentRemote.OnClientEvent:Connect(function(...)
			callback(...)
		end)
	end
end

function Remotes.connectComponentRemoteUnreliable(p, p2: string, callback)
	local componentRemote = getComponentRemote(p2, p, "UnreliableRemoteEvent")

	if not componentRemote then
		error(("Remote %q not found"):format(p2))
	end

	if RunService:IsServer() then
		return componentRemote.OnServerEvent:Connect(function(p3, ...)
			callback(p3, ...)
		end)
	end

	if RunService:IsClient() then
		return componentRemote.OnClientEvent:Connect(function(...)
			callback(...)
		end)
	end
end

function Remotes.connectComponentRemoteFunction(p, p2: string, callback)
	local componentRemote = getComponentRemote(p2, p, "RemoteFunction")

	if not componentRemote then
		error(("Remote %q not found"):format(p2))
	end

	if RunService:IsServer() then
		componentRemote.OnServerInvoke = function(p3, ...)
			local v3 = table.pack(...)
			local success, result = pcall(function()
				return table.pack(callback(p3, table.unpack(v3)))
			end)

			if not success then
				error(("Error invoking remote function %q: %s"):format(p2, (tostring(result))))
			end

			return table.unpack(result)
		end
	end

	if RunService:IsClient() then
		componentRemote.OnClientInvoke = function(...)
			return callback(...)
		end
	end
end

function Remotes.connect(p: string, callback)
	local remote = getRemote(p, "RemoteEvent")

	if RunService:IsServer() then
		return remote.OnServerEvent:Connect(function(p2, ...)
			callback(p2, ...)
		end)
	end

	if RunService:IsClient() then
		return remote.OnClientEvent:Connect(function(...)
			callback(...)
		end)
	end
end

function Remotes.connectUnreliable(p: string, callback)
	local remote = getRemote(p, "UnreliableRemoteEvent")

	if RunService:IsServer() then
		return remote.OnServerEvent:Connect(function(p2, ...)
			callback(p2, ...)
		end)
	end

	if RunService:IsClient() then
		return remote.OnClientEvent:Connect(function(...)
			callback(...)
		end)
	end
end

function Remotes.onInvoke(p: string, callback)
	local remote = getRemote(p, "RemoteFunction")

	if RunService:IsServer() then
		remote.OnServerInvoke = function(p2, ...)
			local v3 = table.pack(...)
			local success, result = pcall(function()
				return table.pack(callback(p2, table.unpack(v3)))
			end)

			if not success then
				error(("Error invoking remote function %q: %s"):format(p, (tostring(result))))
			end

			return table.unpack(result)
		end
	end

	if RunService:IsClient() then
		remote.OnClientInvoke = function(...)
			return callback(...)
		end
	end
end

function Remotes.trackComponentRemote(p)
	addComponentRemote(p, p.Parent)
end

function Remotes.trackComponentRemoteRemoval(p, p2)
	local v3 = p2 or p.Parent

	if v3 == nil then
		return
	end

	removeComponentRemote(p, v3)
end

Remotes.Setup()
return Remotes